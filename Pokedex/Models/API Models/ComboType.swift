import Foundation

struct ComboType: Codable {
    let useBefore: [NamedAPIResource]?
    let useAfter: [NamedAPIResource]?

    enum CodingKeys: String, CodingKey {
        case useBefore = "use_before"
        case useAfter = "use_after"
    }
}
