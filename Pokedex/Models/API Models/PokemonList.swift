import Foundation

struct PokemonList: Codable {
    let count: Int
    let next: String?
    let previous: String?
    let results: [NamedAPIResource]
}
