import Foundation

struct PastMoveStatValues: Codable {
    let generation: NamedAPIResource
    let powerChange: Int

    enum CodingKeys: String, CodingKey {
        case generation
        case powerChange = "power_change"
    }
}
