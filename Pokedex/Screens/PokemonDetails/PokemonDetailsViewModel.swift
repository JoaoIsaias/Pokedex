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
    
    func getEvolutionChain(context: NSManagedObjectContext, pokemonSpeciesUrl: String, completion: @escaping (Result<EvolutionChain, Error>) -> Void) {
        apiClient.request(pokemonSpeciesUrl, method: .get, parameters: nil) {
            [weak self] (result: Result<PokemonSpecies?, Error>) in
            guard let self = self else { return }
            switch result {
            case .success(let pokemonSpecie):
                guard let pokemonSpecie = pokemonSpecie else { return }
                //Evolution Chain API call
                self.apiClient.request(pokemonSpecie.evolutionChain.url, method: .get, parameters: nil) {
                    [weak self] (result: Result<EvolutionChain?, Error>) in
                    guard let self = self else { return }
                    switch result {
                    case .success(let evolutionChain):
                        guard let evolutionChain = evolutionChain else { return }
                        completion(.success(evolutionChain))
                    case .failure(let error):
                        print("Error obtaining pokemon details: \(error)")
                        completion(.failure(error))
                    }
                }
            case .failure(let error):
                print("Error obtaining pokemon details: \(error)")
                completion(.failure(error))
            }
        }
    }
}
