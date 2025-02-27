import Foundation

struct Meta: Codable {
    let ailment: NamedAPIResource
    let category: NamedAPIResource
    let minHits: Int?
    let maxHits: Int?
    let minTurns: Int?
    let maxTurns: Int?
    let drain: Int
    let healing: Int
    let critRate: Int
    let ailmentChance: Int
    let flinchChance: Int
    let statChance: Int
    
    enum CodingKeys: String, CodingKey {
        case ailment, category, drain, healing, critRate = "crit_rate", ailmentChance = "ailment_chance", flinchChance = "flinch_chance", statChance = "stat_chance"
        case minHits = "min_hits"
        case maxHits = "max_hits"
        case minTurns = "min_turns"
        case maxTurns = "max_turns"
    }
}
