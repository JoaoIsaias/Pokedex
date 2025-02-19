import Foundation

struct AbilitySlot: Codable {
    let isHidden: Bool
    let slot: Int
    let ability: NamedAPIResource
    
    enum CodingKeys: String, CodingKey {
        case isHidden = "is_hidden"
        case slot, ability
    }
}
