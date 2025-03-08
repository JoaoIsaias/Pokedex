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
            let pokemonNames = pokemonList.compactMap { $0.name?.capitalized }
            
            // Check which names appear in the text
            let foundPokemon = pokemonNames.filter { text.localizedCaseInsensitiveContains($0) }
            
            return foundPokemon
        } catch {
            print("Failed to fetch Pokemon names: \(error.localizedDescription)")
            throw error
        }
    }
}
