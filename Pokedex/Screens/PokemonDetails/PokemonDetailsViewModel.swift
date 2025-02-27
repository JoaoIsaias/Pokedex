import Foundation
import CoreData

class PokemonDetailsViewModel: ObservableObject {
    private var apiClient: APIClientProtocol
    
    init() {
        self.apiClient = APIClient()
    }
    
    func fetchPokemonData(context: NSManagedObjectContext, pokemonId: Int, completion: @escaping (Result<PokemonData, Error>) -> Void) {
        let fetchRequest: NSFetchRequest<PokemonData> = PokemonData.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \PokemonData.id, ascending: true)]
        fetchRequest.predicate = NSPredicate(format: "id == %d", pokemonId)
        do {
            let coreDataPokemonList = try context.fetch(fetchRequest)
            if !coreDataPokemonList.isEmpty,
               let fetchedPokemon = coreDataPokemonList.first {
                completion(.success(fetchedPokemon))
                return
            }
        } catch {
            print("Failed to fetch Pokemon with id #\(pokemonId) on CoreData: \(error.localizedDescription)")
            completion(.failure(error))
            return
        }
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
