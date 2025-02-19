import Foundation
import CoreData

class PokemonDetailsViewModel: ObservableObject {
    private var apiClient: APIClientProtocol
    
    init() {
        self.apiClient = APIClient()
    }
    func loadPokemonDetails(context: NSManagedObjectContext, pokemonDetailsUrl: String, completion: @escaping (Result<Pokemon, Error>) -> Void) {
        apiClient.request(pokemonDetailsUrl, method: .get, parameters: nil) {
            [weak self] (result: Result<Pokemon?, Error>) in
//            guard let self = self else { return }
            switch result {
            case .success(let pokemon):
                guard let pokemon = pokemon else { return }
                completion(.success(pokemon))
            case .failure(let error):
                print("Error obtaining pokemon details: \(error)")
                completion(.failure(error))
                
            }
        }
    }
}
