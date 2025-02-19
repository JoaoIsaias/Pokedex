import Foundation

struct MoveSlot: Codable, Identifiable {
    let id = UUID()
    let move: NamedAPIResource
    let versionGroupDetails: [VersionGroupDetail]
    
    enum CodingKeys: String, CodingKey {
        case move
        case versionGroupDetails = "version_group_details"
    }
}
