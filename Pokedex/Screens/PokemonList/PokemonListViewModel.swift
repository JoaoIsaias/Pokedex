import Foundation
import CoreData

class PokemonListViewModel: ObservableObject {
    
    private var apiClient: APIClientProtocol
    private var pokemonDataService: PokemonDataServiceProtocol
    private var nextUrl: String?
    
    init(apiClient: APIClientProtocol = APIClient(), pokemonDataService: PokemonDataServiceProtocol = PokemonDataService()) {
        self.apiClient = apiClient
        self.pokemonDataService = pokemonDataService
    }
    
    func loadPokemonList(context: NSManagedObjectContext) async throws -> [PokemonData] {
        do {
            let allPokemonList = try await pokemonDataService.fetchAllPokemon(context: context)
            if !allPokemonList.isEmpty {
                return allPokemonList
            } else {
                // If not in CoreData, fetch from API
                return try await fetchPokemonList(context: context, url: Constants.pokemonListUrl)
            }
        } catch {
            print("(thrown from function: \(#function)) -> Failed to fetch Pokemon List from CoreData: \(error.localizedDescription)")
            throw error
        }
    }
    
    private func fetchPokemonList(context: NSManagedObjectContext, url: String) async throws -> [PokemonData] {
        let result: PokemonList? = try await apiClient.request(url, method: .get, parameters: nil)
        
        guard let data = result else { throw DefaultError("No Data") }
        
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
