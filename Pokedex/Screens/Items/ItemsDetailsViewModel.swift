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
    
    func findEvolutionChains(in pokemonList: [String], context: NSManagedObjectContext) async throws -> [EvolutionChain] {
        do {
            var pokemonSpeciesUrlMap: [String: String] = [:]
            for pokemon in pokemonList {
                let pokemonSpecies: PokemonSpecies = try await apiClient.request("\(Constants.pokemonDefaultSpeciesUrl+pokemon)", method: .get, parameters: nil)
                pokemonSpeciesUrlMap[pokemon] = pokemonSpecies.evolutionChain.url
            }
            
            // Step 1: Group pokemon by their speciesUrl
            let groupedPokemonSpeciesUrlMap = Dictionary(grouping: pokemonSpeciesUrlMap.keys, by: { pokemonSpeciesUrlMap[$0]! })

            // Step 2: Create pairs
            var pokemonNamesGroupedBySpeciesList: [(String,String)] = groupedPokemonSpeciesUrlMap.values.compactMap { group in
                guard group.count > 1 else { return nil }
                return (group[0], group[1])
            }
            
            print(pokemonNamesGroupedBySpeciesList)
            //CONTINUE TO GET EVOLUTIONCHAINS
            
            return []
        } catch {
            print("(thrown from function: \(#function)) -> Failed to get Pokemon evolution chains: \(error.localizedDescription)")
            throw error
        }
    }
}
