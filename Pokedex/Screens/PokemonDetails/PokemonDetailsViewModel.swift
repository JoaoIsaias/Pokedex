import Foundation
import CoreData

class PokemonDetailsViewModel: ObservableObject {
    private var apiClient: APIClientProtocol
    private var pokemonDataService: PokemonDataServiceProtocol
    
    init(apiClient: APIClientProtocol = APIClient(), pokemonDataService: PokemonDataServiceProtocol = PokemonDataService()) {
        self.apiClient = apiClient
        self.pokemonDataService = pokemonDataService
    }
    
    // Fetch Pokemon Data from Core Data
    func fetchPokemonData(context: NSManagedObjectContext, pokemonId: Int) async throws -> PokemonData? {        
        do {
            let pokemonData = try await pokemonDataService.fetchPokemonById(context: context, id: Int16(pokemonId))
            return pokemonData
        } catch {
            print("No Pokemon found with ID \(pokemonId) in CoreData: \(error.localizedDescription)")
            throw error
        }
    }
    
    // Fetch Pokemon Details from API
    func loadPokemonDetails(context: NSManagedObjectContext, pokemonDetailsUrl: String) async throws -> Pokemon {
        let pokemon: Pokemon? = try await apiClient.request(pokemonDetailsUrl, method: .get, parameters: nil)
        
        guard let pokemon = pokemon else {
            throw DefaultError("No Pokemon details found")
        }
        return pokemon
    }
    
    // Fetch Evolution Chain from API
    func getEvolutionChain(context: NSManagedObjectContext, pokemonSpeciesUrl: String) async throws -> EvolutionChain {
        let pokemonSpecie: PokemonSpecies? = try await apiClient.request(pokemonSpeciesUrl, method: .get, parameters: nil)
        
        guard let species = pokemonSpecie else {
            throw DefaultError("No species data found")
        }
        
        let evolutionChain: EvolutionChain? = try await apiClient.request(species.evolutionChain.url, method: .get, parameters: nil)
        
        guard let evolutionChain = evolutionChain else {
            throw DefaultError("No evolution chain found")
        }
        return evolutionChain
    }
}
