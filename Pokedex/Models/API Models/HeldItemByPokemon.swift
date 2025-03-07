import Foundation

struct HeldItemByPokemon: Codable {
    let pokemon: NamedAPIResource
    let versionDetails: [VersionDetail]
    
    enum CodingKeys: String, CodingKey {
        case pokemon
        case versionDetails = "version_details"
    }
}
