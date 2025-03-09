import Foundation
import CoreData

class ItemsDetailsViewModel: ObservableObject {
    private var apiClient: APIClientProtocol
    private var pokemonDataService: PokemonDataServiceProtocol
    
    init(apiClient: APIClientProtocol = APIClient(), pokemonDataService: PokemonDataServiceProtocol = PokemonDataService()) {
        self.apiClient = apiClient
        self.pokemonDataService = pokemonDataService
    }
    
    func loadItemDetails(context: NSManagedObjectContext, itemDetailsUrl: String) async throws -> Item {
        let item: Item? = try await apiClient.request(itemDetailsUrl, method: .get, parameters: nil)
        guard let item = item else { throw DefaultError("No item data found") }
        return item
    }
    
    func findPokemonNames(in text: String, context: NSManagedObjectContext) async throws -> [String] {
        do {
            let pokemonList = try await pokemonDataService.fetchAllPokemon(context: context)
            
            // Extract just the names
            let pokemonNames = pokemonList.compactMap { $0.name?.lowercased() }
            
            // Check which names appear in the text
            let foundPokemon = pokemonNames.filter { text.localizedCaseInsensitiveContains($0) }
            
            return foundPokemon
        } catch {
            print("(thrown from function: \(#function)) -> Failed to fetch Pokemon names: \(error.localizedDescription)")
            throw error
        }
    }
    
    func getEvolutionNodes(in pokemonList: [String], context: NSManagedObjectContext) async throws -> [EvolutionNode] {
        do {
            var pokemonSpeciesUrlMap: [String: String] = [:]
            for pokemon in pokemonList {
                let pokemonSpecies: PokemonSpecies = try await apiClient.request(Constants.pokemonDefaultSpeciesUrl+pokemon, method: .get, parameters: nil)
                pokemonSpeciesUrlMap[pokemon] = pokemonSpecies.evolutionChain.url
            }
            
            // Step 1: Group pokemon by their speciesUrl
            let groupedPokemonSpeciesUrlMap = Dictionary(grouping: pokemonSpeciesUrlMap.keys, by: { pokemonSpeciesUrlMap[$0]! })

            // Step 2: Create pairs
            let pokemonNamesGroupedBySpeciesList: [(String,String)] = groupedPokemonSpeciesUrlMap.values.compactMap { group in
                guard group.count > 1 else { return nil }
                return (group[0], group[1])
            }
            
            // Step 3: Order pair names by pokemon ID
            let pokemonDataArray = try await pokemonDataService.fetchPokemonByListOfNames(context: context, pokemonNames: pokemonList)
            let pokemonIdDict = Dictionary(uniqueKeysWithValues: pokemonDataArray.map { ($0.name?.lowercased() ?? "", Int($0.id)) })

            // Sort each pair based on Pokémon ID
            let sortedPokemonByIdList = pokemonNamesGroupedBySpeciesList.map { pair -> (String, String) in
                let id1 = pokemonIdDict[pair.0.lowercased()] ?? Int.max  // Default to max if not found
                let id2 = pokemonIdDict[pair.1.lowercased()] ?? Int.max

                return id1 < id2 ? pair : (pair.1, pair.0)  // Ensure the smaller ID is first
            }
            
            // Step 4: Create the evolution node for each pair
            var evolutionNodeList: [EvolutionNode] = []
            for pokemonNamePair in sortedPokemonByIdList {
                let firstPokemonImageUrl = pokemonDataArray.first(where: {$0.name == pokemonNamePair.0})?.image
                let secondPokemonImageUrl = pokemonDataArray.first(where: {$0.name == pokemonNamePair.1})?.image
                
                // Step 4.5: Get the evolution method for each pair
                let evolutionChainUrl = pokemonSpeciesUrlMap[pokemonNamePair.1] ?? ""
                let pokemonEvolutionChain: EvolutionChain = try await apiClient.request(evolutionChainUrl, method: .get, parameters: nil)
                let pokemonEvolutionMethod = await getEvolutionMethod(evolutionChainLink: pokemonEvolutionChain.chain, pokemonName: pokemonNamePair.1)
                
                let evolutionNode = EvolutionNode(
                    species: pokemonNamePair.0,
                    defaultSpriteUrl: firstPokemonImageUrl,
                    evolutionMethod: nil,
                    evolvesFrom: nil,
                    evolvesTo: [EvolutionNode(species: pokemonNamePair.1,
                                              defaultSpriteUrl: secondPokemonImageUrl,
                                              evolutionMethod: pokemonEvolutionMethod,
                                              evolvesFrom: pokemonNamePair.0,
                                              evolvesTo: [])
                        
                    ])
                evolutionNodeList.append(evolutionNode)
            }
            return evolutionNodeList
        } catch {
            print("(thrown from function: \(#function)) -> Failed to get Pokemon evolution chains: \(error.localizedDescription)")
            throw error
        }
    }
    
    private func getEvolutionMethod(evolutionChainLink: EvolutionChainLink, pokemonName: String) async -> (Constants.EvolutionTrigger, String)? {
        if evolutionChainLink.species.name == pokemonName {
            // TODO: Add the missing evolution method + REFACTOR THIS HERE AND IN POKEMONDETAILS
            if let evolutionDetails = evolutionChainLink.evolutionDetails.first,
               let evolutionTrigger = Constants.EvolutionTrigger(evolutionDetails.trigger.name) {
                var evolutionMethod: (Constants.EvolutionTrigger, String)? = nil
                switch evolutionTrigger {
                case .levelUp:
                    let minLevel = evolutionDetails.minLevel ?? 0
                    var heldItemText = ""
                    if let itemName = evolutionDetails.heldItem?.name {
                        heldItemText = " w/ " + itemName
                    }
                    evolutionMethod = (evolutionTrigger, "Level " + String(minLevel) + heldItemText)
                case .useItem:
                    let itemName = evolutionDetails.item?.name ?? ""
                    evolutionMethod = (evolutionTrigger, "Use " + String(itemName))
                case .trade:
                    var heldItemText = ""
                    if let itemName = evolutionDetails.heldItem?.name {
                        heldItemText = " w/ " + itemName
                    }
                    evolutionMethod = (evolutionTrigger, "Trade" + heldItemText)
                default:
                    print("Evolution trigger not yet supported: \(evolutionTrigger)")
                }
                return evolutionMethod
            }
        } else if evolutionChainLink.evolvesTo.count > 0 {
            let children = await withTaskGroup(of: (Constants.EvolutionTrigger, String)?.self) { group in
                for evolvesTo in evolutionChainLink.evolvesTo {
                    group.addTask {
                        await self.getEvolutionMethod(evolutionChainLink: evolvesTo, pokemonName: pokemonName)
                    }
                }
                
                var childNodes: [(Constants.EvolutionTrigger, String)?] = []
                for await child in group {
                    childNodes.append(child)
                }
                return childNodes
            }
            
            return children.first(where: { $0 != nil }) ?? nil

        }
        return nil
    }
}
