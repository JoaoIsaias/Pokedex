import Foundation

struct EvolutionChain: Codable {
    let babyTriggerItem: String?
    let chain: EvolutionChainLink
    let id: Int

    enum CodingKeys: String, CodingKey {
        case babyTriggerItem = "baby_trigger_item"
        case chain
        case id
    }
}
