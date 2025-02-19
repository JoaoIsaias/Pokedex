import Foundation

struct VersionGroupDetail: Codable {
    let levelLearnedAt: Int
    let versionGroup: NamedAPIResource
    let moveLearnMethod: NamedAPIResource
    
    enum CodingKeys: String, CodingKey {
        case levelLearnedAt = "level_learned_at"
        case versionGroup = "version_group"
        case moveLearnMethod = "move_learn_method"
    }
}
