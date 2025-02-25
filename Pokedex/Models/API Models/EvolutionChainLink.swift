import Foundation

struct EvolutionChainLink: Codable {
    let evolutionDetails: [EvolutionDetail]
    let evolvesTo: [EvolutionChainLink]
    let isBaby: Bool
    let species: NamedAPIResource

    enum CodingKeys: String, CodingKey {
        case evolutionDetails = "evolution_details"
        case evolvesTo = "evolves_to"
        case isBaby = "is_baby"
        case species
    }
}
