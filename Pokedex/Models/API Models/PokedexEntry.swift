import Foundation

struct PokedexEntry: Codable {
    let entryNumber: Int
    let pokedex: NamedAPIResource

    enum CodingKeys: String, CodingKey {
        case entryNumber = "entry_number"
        case pokedex
    }
}
