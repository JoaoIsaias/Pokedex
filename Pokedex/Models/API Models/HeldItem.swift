import Foundation

struct HeldItem: Codable {
    let item: NamedAPIResource
    let versionDetails: [VersionDetail]
    
    enum CodingKeys: String, CodingKey {
        case item
        case versionDetails = "version_details"
    }
}
