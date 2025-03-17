import Foundation

struct EvolutionNode: Identifiable {
    let id = UUID()
    let species: String
    let defaultSpriteUrl: String?
    let evolutionMethod: (Constants.EvolutionTrigger, String)?
    let evolvesFrom: String?
    let evolvesTo: [EvolutionNode]
}
