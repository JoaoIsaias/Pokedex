import Foundation
import CoreData

class MainViewModel: ObservableObject {
    
    private var apiClient: APIClientProtocol
    private var nextUrl: String?
    
    init() {
        self.apiClient = APIClient()
    }
    
    func loadInitialPokemonList(context: NSManagedObjectContext, completion: @escaping (Result<[PokemonData], Error>) -> Void) {
        let fetchRequest: NSFetchRequest<PokemonData> = PokemonData.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \PokemonData.id, ascending: true)]
        do {
            let coreDataPokemonList = try context.fetch(fetchRequest)
            if !coreDataPokemonList.isEmpty {
                completion(.success(coreDataPokemonList))
                return
            } else {
                // If not in CoreData, do API request
                fetchPokemonList(context: context, url: Constants.pokemonListUrl, completion: completion)
            }
        } catch {
            print("Failed to fetch Pokemon List on CoreData: \(error.localizedDescription)")
            completion(.failure(error))
            return
        }
    }
    
    func loadMorePokemonList(context: NSManagedObjectContext, pokemonListLength: Int = 0, completion: @escaping (Result<[PokemonData], Error>) -> Void) {
        if let nextUrl = nextUrl {
            fetchPokemonList(context: context, url: nextUrl, completion: completion)
        } else {
            let newUrl = "https://pokeapi.co/api/v2/pokemon?offset=\(String(pokemonListLength))&limit=20"
            fetchPokemonList(context: context, url: newUrl, completion: completion)
        }
    }
    
    private func fetchPokemonList(context: NSManagedObjectContext, url: String, completion: @escaping (Result<[PokemonData], Error>) -> Void) {
        apiClient.request(url, method: .get, parameters: nil) {
            [weak self] (result: Result<PokemonList?, Error>) in
            guard let self = self else { return }
            switch result {
            case .success(let data):
                self.nextUrl = data?.next
                var newPokemonList: [PokemonData] = []
                let dispatchGroup = DispatchGroup()
                
                data?.results.forEach({ [weak self] pokemonRequest in
                    guard let self = self else { return }
                    dispatchGroup.enter()
                    self.apiClient.request(pokemonRequest.url, method: .get, parameters: nil) {
                        (result: Result<Pokemon?, Error>) in
                        switch result {
                        case .success(let pokemon):
                            if let pokemonData = pokemon {
                                let newPokemon = PokemonData(context: context)
                                newPokemon.id = Int32(pokemonData.id)
                                newPokemon.name = pokemonData.name
                                newPokemon.image = pokemonData.sprites.frontDefault
                                
                                newPokemonList.append(newPokemon)
                            }
                        case .failure(let error):
                            print("Error occurred obtaining \(pokemonRequest.name) data: \(error)")
                        }
                        dispatchGroup.leave()
                    }
                    
                })
                dispatchGroup.notify(queue: .main) {
                    do {
                        try context.save()
                        completion(.success(newPokemonList))
                    } catch {
                        context.rollback()
                        completion(.failure(error))
                    }
                }
            case .failure(let error):
                print("Error occurred obtaining pokemon list data : \(error)")
                completion(.failure(error))
            }
        }
    }
}
