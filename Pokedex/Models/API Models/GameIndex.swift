import Foundation

struct GameIndex: Codable {
    let gameIndex: Int
    let version: NamedAPIResource
    
    enum CodingKeys: String, CodingKey {
        case gameIndex = "game_index"
        case version
    }
}
