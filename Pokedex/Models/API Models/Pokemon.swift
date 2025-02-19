import Foundation

struct Pokemon: Codable {
    let id: Int
    let name: String
    let baseExperience: Int
    let height: Int
    let isDefault: Bool
    let order: Int
    let weight: Int
    let abilities: [AbilitySlot]
    let forms: [NamedAPIResource]
    let gameIndices: [GameIndex]
    let heldItems: [HeldItem]
    let locationAreaEncounters: String
    let moves: [MoveSlot]
    let species: NamedAPIResource
    let sprites: Sprites
    let stats: [Stat]
    let types: [TypeSlot]
    let pastTypes: [PastType]
    
    enum CodingKeys: String, CodingKey {
        case id, name, height, weight, abilities, forms, moves, species, sprites, stats, types, order
        case baseExperience = "base_experience"
        case isDefault = "is_default"
        case gameIndices = "game_indices"
        case heldItems = "held_items"
        case locationAreaEncounters = "location_area_encounters"
        case pastTypes = "past_types"
    }
}
