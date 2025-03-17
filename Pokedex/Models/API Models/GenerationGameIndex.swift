import Foundation

struct GenerationGameIndex: Codable {
    let gameIndex: Int
    let generation: NamedAPIResource
    
    enum CodingKeys: String, CodingKey {
        case gameIndex = "game_index"
        case generation
    }
}
