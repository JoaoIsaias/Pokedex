import Foundation

struct EvolutionDetail: Codable {
    let gender: Int?
    let heldItem: NamedAPIResource?
    let item: NamedAPIResource?
    let knownMove: String?
    let knownMoveType: String?
    let location: String?
    let minAffection: Int?
    let minBeauty: Int?
    let minHappiness: Int?
    let minLevel: Int?
    let needsOverworldRain: Bool
    let partySpecies: String?
    let partyType: String?
    let relativePhysicalStats: Int?
    let timeOfDay: String
    let tradeSpecies: String?
    let trigger: NamedAPIResource
    let turnUpsideDown: Bool

    enum CodingKeys: String, CodingKey {
        case gender
        case heldItem = "held_item"
        case item
        case knownMove = "known_move"
        case knownMoveType = "known_move_type"
        case location
        case minAffection = "min_affection"
        case minBeauty = "min_beauty"
        case minHappiness = "min_happiness"
        case minLevel = "min_level"
        case needsOverworldRain = "needs_overworld_rain"
        case partySpecies = "party_species"
        case partyType = "party_type"
        case relativePhysicalStats = "relative_physical_stats"
        case timeOfDay = "time_of_day"
        case tradeSpecies = "trade_species"
        case trigger
        case turnUpsideDown = "turn_upside_down"
    }
}
