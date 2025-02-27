import Foundation

struct StatChange: Codable {
    let stat: NamedAPIResource
    let change: Int
}
