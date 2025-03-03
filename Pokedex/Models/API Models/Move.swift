import Foundation

// MARK: - Move
struct Move: Codable {
    let id: Int
    let name: String
    let accuracy: Int?
    let effectChance: Int?
    let pp: Int
    let priority: Int?
    let power: Int?
    let contestCombos: ContestCombos?
    let contestType: NamedAPIResource?
    let contestEffect: APIResource?
    let damageClass: NamedAPIResource?
    let effectEntries: [EffectEntry]
    let generation: NamedAPIResource?
    let meta: Meta?
    let names: [Name]
    let pastValues: [PastMoveStatValues]
    let statChanges: [StatChange]
    let superContestEffect: APIResource?
    let target: NamedAPIResource?
    let type: NamedAPIResource?
    let learnedByPokemon: [NamedAPIResource]
    let flavorTextEntries: [FlavorTextEntry]

    enum CodingKeys: String, CodingKey {
        case id, name, pp, priority, power, generation, names
        case accuracy = "accuracy"
        case effectChance = "effect_chance"
        case contestCombos = "contest_combos"
        case contestType = "contest_type"
        case contestEffect = "contest_effect"
        case damageClass = "damage_class"
        case effectEntries = "effect_entries"
        case meta = "meta"
        case superContestEffect = "super_contest_effect"
        case target = "target"
        case type = "type"
        case learnedByPokemon = "learned_by_pokemon"
        case flavorTextEntries = "flavor_text_entries"
        case pastValues = "past_values"
        case statChanges = "stat_changes"
    }
}
