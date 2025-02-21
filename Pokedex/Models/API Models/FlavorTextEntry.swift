import Foundation

struct FlavorTextEntry: Codable {
    let flavorText: String
    let language: NamedAPIResource
    let version: NamedAPIResource

    enum CodingKeys: String, CodingKey {
        case flavorText = "flavor_text"
        case language, version
    }
}
