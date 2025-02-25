import Foundation

struct PokemonSpecies: Codable {
    let baseHappiness: Int
    let captureRate: Int
    let color: NamedAPIResource
    let eggGroups: [NamedAPIResource]
    let evolutionChain: APIResource
    let evolvesFromSpecies: NamedAPIResource?
    let flavorTextEntries: [FlavorTextEntry]
    let formsSwitchable: Bool
    let genderRate: Int
    let genera: [Genus]
    let generation: NamedAPIResource
    let growthRate: NamedAPIResource
    let habitat: NamedAPIResource?
    let hasGenderDifferences: Bool
    let hatchCounter: Int
    let id: Int
    let isBaby: Bool
    let isLegendary: Bool
    let isMythical: Bool
    let name: String
    let names: [PokemonName]
    let order: Int
    let palParkEncounters: [PalParkEncounter]
    let pokedexNumbers: [PokedexEntry]
    let shape: NamedAPIResource?
    let varieties: [PokemonVariety]

    enum CodingKeys: String, CodingKey {
        case baseHappiness = "base_happiness"
        case captureRate = "capture_rate"
        case color, eggGroups = "egg_groups"
        case evolutionChain = "evolution_chain"
        case evolvesFromSpecies = "evolves_from_species"
        case flavorTextEntries = "flavor_text_entries"
        case formsSwitchable = "forms_switchable"
        case genderRate = "gender_rate"
        case genera, generation, growthRate = "growth_rate"
        case habitat, hasGenderDifferences = "has_gender_differences"
        case hatchCounter = "hatch_counter"
        case id, isBaby = "is_baby"
        case isLegendary = "is_legendary"
        case isMythical = "is_mythical"
        case name, names, order
        case palParkEncounters = "pal_park_encounters"
        case pokedexNumbers = "pokedex_numbers"
        case shape, varieties
    }
}
