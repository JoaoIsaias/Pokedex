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
}
