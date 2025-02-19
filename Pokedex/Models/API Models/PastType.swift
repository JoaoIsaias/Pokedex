import Foundation

struct PastType: Codable {
    let generation: NamedAPIResource
    let types: [TypeSlot]
}
