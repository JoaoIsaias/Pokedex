import Foundation

struct PokemonVariety: Codable {
    let isDefault: Bool
    let pokemon: NamedAPIResource

    enum CodingKeys: String, CodingKey {
        case isDefault = "is_default"
        case pokemon
    }
}
