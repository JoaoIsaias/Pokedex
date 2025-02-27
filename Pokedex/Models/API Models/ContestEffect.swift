import Foundation

struct ContestEffect: Codable {
    let id: Int?
    let name: String?
    let effectEntries: [EffectEntry]
    let url: String?
}
