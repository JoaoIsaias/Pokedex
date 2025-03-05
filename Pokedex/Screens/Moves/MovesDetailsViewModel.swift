import Foundation
import CoreData

class MovesDetailsViewModel: ObservableObject {
    private var apiClient: APIClientProtocol
    
    init() {
        self.apiClient = APIClient()
    }
    
    func loadMovesDetails(context: NSManagedObjectContext, moveDetailsUrl: String) async throws -> Move {
        let move: Move? = try await apiClient.request(moveDetailsUrl, method: .get, parameters: nil)
        guard let move = move else { throw NSError(domain: "No move data", code: -1) }
        return move
    }
    
    func fetchPokemonList(context: NSManagedObjectContext, pokemonNames: [String]) async throws -> [PokemonData] {
        let fetchRequest: NSFetchRequest<PokemonData> = PokemonData.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \PokemonData.id, ascending: true)]
        fetchRequest.predicate = NSPredicate(format: "name IN %@", pokemonNames)
        
        do {
            return try context.fetch(fetchRequest)
        } catch {
            print("Failed to fetch Pokémon list from CoreData: \(error.localizedDescription)")
            throw error
        }
    }
}
