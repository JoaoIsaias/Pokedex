import Foundation

enum Constants {
    static let pokemonListUrl: String = "https://pokeapi.co/api/v2/pokemon/"
    
    enum MoveLearnMethod: String {
        case levelUp = "level-up"
        case egg = "egg"
        case tutor = "tutor"
        case machine = "machine"
        
        init?(_ method: String) {
            self.init(rawValue: method) // Uses the existing failable initializer
        }
    }
    
    enum EvolutionTrigger: String {
        case levelUp = "level-up"
        case trade = "trade"
        case useItem = "use-item"
        case shed = "shed"
        case spin = "spin"
        case towerOfDarkness = "tower-of-darkness"
        case towerOfWaters = "tower-of-waters"
        case threeCriticalHits = "three-critical-hits"
        case takeDamage = "take-damage"
        case other = "other"
        case agileStyleMove = "agile-style-move"
        case strongStyleMove = "strong-style-move"
        case recoilDamage = "recoil-damage"

        init?(_ method: String) {
            self.init(rawValue: method) // Uses the existing failable initializer
        }
    }
}
