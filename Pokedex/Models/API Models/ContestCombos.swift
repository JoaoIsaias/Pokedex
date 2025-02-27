import Foundation

struct ContestCombos: Codable {
    let normal: ComboType
    let super_: ComboType
    
    enum CodingKeys: String, CodingKey {
        case normal
        case super_ = "super"
    }
}
