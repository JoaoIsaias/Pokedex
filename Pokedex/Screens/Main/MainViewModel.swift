import Foundation
import CoreData

class MainViewModel: ObservableObject {
    
    private var apiClient: APIClientProtocol
    private var nextUrl: String?
    
    init() {
        self.apiClient = APIClient()
    }
    
    func loadPokemonList(context: NSManagedObjectContext) async throws -> [PokemonData] {
        let fetchRequest: NSFetchRequest<PokemonData> = PokemonData.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \PokemonData.id, ascending: true)]
        
        do {
            let coreDataPokemonList = try context.fetch(fetchRequest)
            if !coreDataPokemonList.isEmpty {
                return coreDataPokemonList
            } else {
                // If not in CoreData, fetch from API
                return try await fetchPokemonList(context: context, url: Constants.pokemonListUrl)
            }
        } catch {
            print("Failed to fetch Pokémon List from CoreData: \(error.localizedDescription)")
            throw error
        }
    }
    
    private func fetchPokemonList(context: NSManagedObjectContext, url: String) async throws -> [PokemonData] {
        let result: PokemonList? = try await apiClient.request(url, method: .get, parameters: nil)
        
        guard let data = result else { throw NSError(domain: "No Data", code: -1) }
        
        self.nextUrl = data.next
        var newPokemonList: [PokemonData] = []
        
        for pokemonRequest in data.results {
            do {
                let pokemonData: Pokemon? = try await apiClient.request(pokemonRequest.url, method: .get, parameters: nil)
                if let pokemon = pokemonData {
                    let newPokemon = PokemonData(context: context)
                    newPokemon.id = Int16(pokemon.id)
                    newPokemon.name = pokemon.name
                    newPokemon.image = pokemon.sprites.frontDefault
                    
                    newPokemonList.append(newPokemon)
                }
            } catch {
                print("Error obtaining \(pokemonRequest.name) data: \(error)")
            }
        }
        
        do {
            try context.save()
            return newPokemonList
        } catch {
            context.rollback()
            throw error
        }
    }
}
