import Foundation

struct VersionGroupFlavorText: Codable {
    let text: String
    let versionGroup: NamedAPIResource?
    let language: NamedAPIResource?
    
    enum CodingKeys: String, CodingKey {
        case text
        case versionGroup = "version_group"
        case language
    }
}
