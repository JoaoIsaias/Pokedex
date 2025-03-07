import Foundation

struct Item: Codable {
    let id: Int
    let name: String
    let cost: Int
    let flingPower: Int?
    let flingEffect: NamedAPIResource?
    let attributes: [NamedAPIResource]
    let category: NamedAPIResource
    let effectEntries: [EffectEntry]
    let flavorTextEntries: [VersionGroupFlavorText]
    let gameIndices: [GenerationGameIndex]
    let names: [Name]
    let sprites: ItemSprites
    let heldByPokemon: [HeldItemByPokemon]?
    let babyTriggerFor: APIResource?
    
    enum CodingKeys: String, CodingKey {
        case id, name, cost
        case flingPower = "fling_power"
        case flingEffect = "fling_effect"
        case attributes, category
        case effectEntries = "effect_entries"
        case flavorTextEntries = "flavor_text_entries"
        case gameIndices = "game_indices"
        case names, sprites
        case heldByPokemon = "held_by_pokemon"
        case babyTriggerFor = "baby_trigger_for"
    }
}
