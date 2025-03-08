import CoreData
import Foundation

protocol PokemonDataServiceProtocol {
    func fetchAllPokemon(context: NSManagedObjectContext) async throws -> [PokemonData]
    func fetchPokemonById(context: NSManagedObjectContext, id: Int16) async throws -> PokemonData?
    func fetchPokemonByName(context: NSManagedObjectContext, name: String) async throws -> [PokemonData]
    func fetchPokemonByImage(context: NSManagedObjectContext, imageUrl: String) async throws -> [PokemonData]
    func fetchPokemonByListOfNames(context: NSManagedObjectContext, pokemonNames: [String]) async throws -> [PokemonData]
}

class PokemonDataService: PokemonDataServiceProtocol {
    
    // Fetch all Pokemon from Core Data
    func fetchAllPokemon(context: NSManagedObjectContext) async throws -> [PokemonData] {
        let fetchRequest: NSFetchRequest<PokemonData> = PokemonData.fetchRequest()
        do {
            let pokemonList = try context.fetch(fetchRequest)
            return pokemonList
        } catch {
            print("Failed to fetch Pokemon list from CoreData: \(error.localizedDescription)")
            throw error
        }
    }
    
    // Fetch a Pokemon by its unique ID
    func fetchPokemonById(context: NSManagedObjectContext, id: Int16) async throws -> PokemonData? {
        let fetchRequest: NSFetchRequest<PokemonData> = PokemonData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %d", id)
        
        do {
            let result = try context.fetch(fetchRequest)
            return result.first
        } catch {
            print("Failed to fetch Pokemon by ID from CoreData: \(error.localizedDescription)")
            throw error
        }
    }
    
    // Fetch Pokemon by name
    func fetchPokemonByName(context: NSManagedObjectContext, name: String) async throws -> [PokemonData] {
        let fetchRequest: NSFetchRequest<PokemonData> = PokemonData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "name ==[c] %@", name)
        
        do {
            let result = try context.fetch(fetchRequest)
            return result
        } catch {
            print("Failed to fetch Pokemon by name from CoreData: \(error.localizedDescription)")
            throw error
        }
    }
    
    // Fetch Pokemon by image URL
    func fetchPokemonByImage(context: NSManagedObjectContext, imageUrl: String) async throws -> [PokemonData] {
        let fetchRequest: NSFetchRequest<PokemonData> = PokemonData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "image ==[c] %@", imageUrl)
        
        do {
            let result = try context.fetch(fetchRequest)
            return result
        } catch {
            print("Failed to fetch Pokemon by image Url from CoreData: \(error.localizedDescription)")
            throw error
        }
    }
    
    // Fetch Pokemon in list of pokemon names
    func fetchPokemonByListOfNames(context: NSManagedObjectContext, pokemonNames: [String]) throws -> [PokemonData] {
        let fetchRequest: NSFetchRequest<PokemonData> = PokemonData.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \PokemonData.id, ascending: true)]
        fetchRequest.predicate = NSPredicate(format: "name IN %@", pokemonNames)
        
        do {
            let result = try context.fetch(fetchRequest)
            return result
        } catch {
            print("Failed to fetch Pokemon list from CoreData: \(error.localizedDescription)")
            throw error
        }
    }
}
