import Foundation
import CoreData

class MovesDetailsViewModel: ObservableObject {
    private var apiClient: APIClientProtocol
    private var pokemonDataService: PokemonDataServiceProtocol
    
    init(apiClient: APIClientProtocol = APIClient(), pokemonDataService: PokemonDataServiceProtocol = PokemonDataService()) {
        self.apiClient = apiClient
        self.pokemonDataService = pokemonDataService
    }
    
    func loadMovesDetails(context: NSManagedObjectContext, moveDetailsUrl: String) async throws -> Move {
        let move: Move? = try await apiClient.request(moveDetailsUrl, method: .get, parameters: nil)
        guard let move = move else { throw DefaultError("No move data") }
        return move
    }
    
    func fetchPokemonList(context: NSManagedObjectContext, pokemonNames: [String]) async throws -> [PokemonData] {        
        do {
            let pokemonList = try await pokemonDataService.fetchPokemonByListOfNames(context: context, pokemonNames: pokemonNames)
            return pokemonList
        } catch {
            print("Failed to fetch Pokemon list from CoreData: \(error.localizedDescription)")
            throw error
        }
    }
}
