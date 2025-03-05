import Foundation
import CoreData

class PokemonDetailsViewModel: ObservableObject {
    private var apiClient: APIClientProtocol
    
    init() {
        self.apiClient = APIClient()
    }
    
    // Fetch Pokémon Data from Core Data
    func fetchPokemonData(context: NSManagedObjectContext, pokemonId: Int) async throws -> PokemonData {
        let fetchRequest: NSFetchRequest<PokemonData> = PokemonData.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \PokemonData.id, ascending: true)]
        fetchRequest.predicate = NSPredicate(format: "id == %d", pokemonId)
        let coreDataPokemonList = try context.fetch(fetchRequest)
        
        guard let fetchedPokemon = coreDataPokemonList.first else {
            throw NSError(domain: "No Pokémon found", code: -1, userInfo: nil)
        }
        return fetchedPokemon
    }
    
    // Fetch Pokémon Details from API
    func loadPokemonDetails(context: NSManagedObjectContext, pokemonDetailsUrl: String) async throws -> Pokemon {
        let pokemon: Pokemon? = try await apiClient.request(pokemonDetailsUrl, method: .get, parameters: nil)
        
        guard let pokemon = pokemon else {
            throw NSError(domain: "No Pokémon details found", code: -1, userInfo: nil)
        }
        return pokemon
    }
    
    // Fetch Evolution Chain from API
    func getEvolutionChain(context: NSManagedObjectContext, pokemonSpeciesUrl: String) async throws -> EvolutionChain {
        let pokemonSpecie: PokemonSpecies? = try await apiClient.request(pokemonSpeciesUrl, method: .get, parameters: nil)
        
        guard let species = pokemonSpecie else {
            throw NSError(domain: "No species data found", code: -1, userInfo: nil)
        }
        
        let evolutionChain: EvolutionChain? = try await apiClient.request(species.evolutionChain.url, method: .get, parameters: nil)
        
        guard let evolutionChain = evolutionChain else {
            throw NSError(domain: "No evolution chain found", code: -1, userInfo: nil)
        }
        return evolutionChain
    }
}
