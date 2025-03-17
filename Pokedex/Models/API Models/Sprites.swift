import Foundation

struct Sprites: Codable {
    let frontDefault: String?
    let frontShiny: String?
    
    enum CodingKeys: String, CodingKey {
        case frontDefault = "front_default"
        case frontShiny = "front_shiny"
    }
}
