import Foundation

struct PalParkEncounter: Codable {
    let area: NamedAPIResource
    let baseScore: Int
    let rate: Int

    enum CodingKeys: String, CodingKey {
        case area
        case baseScore = "base_score"
        case rate
    }
}
