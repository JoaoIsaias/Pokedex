import Foundation

struct EffectEntry: Codable {
    let effect: String
    let shortEffect: String?
    let language: NamedAPIResource?
    
    enum CodingKeys: String, CodingKey {
        case effect, language
        case shortEffect = "short_effect"
    }
}
