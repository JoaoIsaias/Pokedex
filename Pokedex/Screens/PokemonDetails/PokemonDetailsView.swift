import SwiftUI
import CoreData

struct EvolutionNode: Identifiable {
    let id = UUID()
    let species: String
    let defaultSpriteUrl: String?
    let evolutionMethod: (Constants.EvolutionTrigger, String)?
    let evolvesFrom: String?
    let evolvesTo: [EvolutionNode]
}

struct PokemonDetailsView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    //    @FetchRequest(
    //        sortDescriptors: [NSSortDescriptor(keyPath: \Pokemon.name, ascending: true)],
    //        animation: .default)
    //    private var pokemonList: FetchedResults<Item>
    @State var pokemonData: PokemonData
    @State var pokemonDetails: Pokemon?
    
    @State var pokemonMovesMap: [Constants.MoveLearnMethod: [String]] = [:]
    
    @State var pokemonEvolutionNode: EvolutionNode?
    @State var maxNodeLevel: Int = 1
    @State var maxNumberOfNodesInSameLevel: Int = 1
    
    @StateObject private var viewModel = PokemonDetailsViewModel()
    
    var body: some View {
        ScrollView{
            AsyncImage(url: URL(string: pokemonData.image ?? "")){ result in
                result.image?
                    .resizable()
                    .scaledToFill()
            }
            .frame(width: UIScreen.main.bounds.width*0.8, height: UIScreen.main.bounds.width*0.8)
            .padding()
            
            HStack(alignment: .center) {
                Text("#\(Int(pokemonData.id).pokemonNumberString())")
                    .font(.title)
                    .fontWeight(.bold)
                    .padding()
                
                Text((pokemonData.name ?? "").capitalized)
                    .font(.title)
                    .fontWeight(.bold)
                    .padding()
            }
            
            if let pokemonDetails = pokemonDetails {
                HStack(alignment: .center) {
                    ForEach(pokemonDetails.types.indices, id: \.self) { typeIndex in
                        Image(pokemonDetails.types[typeIndex].type.name)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 30)
                            .padding()
                    }
                        
                }
                
                if let pokemonEvolutionNode = pokemonEvolutionNode {
                    Text("Evolution Chain")
                        .font(.title2)
                        .bold()
                        .padding()
                    
                        EvolutionView(
                            node: pokemonEvolutionNode,
                            maxNumberOfNodesVertically: maxNumberOfNodesInSameLevel,
                            currentNumberOfNodesVertically: 1
                        )
                        .padding()
                }

                if let pokemonMovesByLevelUpArray = pokemonMovesMap[Constants.MoveLearnMethod.levelUp] {
                    Text("Moves Learned by Level Up")
                        .font(.title2)
                        .bold()
                        .padding()
                    
                    LazyVGrid(columns: [
                        GridItem(.flexible(), spacing: 10),
                        GridItem(.flexible(), spacing: 10)
                    ]) {
                        Text("Move")
                            .font(.title3)
                            .bold()
                            .padding()
                        Text("Learned at level")
                            .font(.title3)
                            .bold()
                            .padding()
                        ForEach(pokemonMovesByLevelUpArray, id: \.self) { move in
                            Text(move.trimmingCharacters(in: .decimalDigits).capitalized)
//                                .font(.caption)
                                .padding()
                            
                            Text(String(Int(move.filter { $0.isNumber }) ?? 0))
//                                .font(.caption)
                                .padding()
                        }
                    }
                }
                
                if let pokemonMachineMovesArray = pokemonMovesMap[Constants.MoveLearnMethod.machine] {
                    Text("Moves Learned by TM/HM")
                        .font(.title2)
                        .bold()
                        .padding()
                    LazyVStack {
                        ForEach(pokemonMachineMovesArray, id: \.self) { move in
                            Text(move.capitalized)
//                                .font(.caption)
                                .padding()
                        }
                    }
                }
                
                if let pokemonTutorMovesArray = pokemonMovesMap[Constants.MoveLearnMethod.tutor] {
                    Text("Tutor Moves")
                        .font(.title2)
                        .bold()
                        .padding()
                    LazyVStack {
                        ForEach(pokemonTutorMovesArray, id: \.self) { move in
                            Text(move.capitalized)
//                                .font(.caption)
                                .padding()
                        }
                    }
                }
                
                if let pokemonEggMovesArray = pokemonMovesMap[Constants.MoveLearnMethod.egg] {
                    Text("Egg Moves")
                        .font(.title2)
                        .bold()
                        .padding()
                    LazyVStack {
                        ForEach(pokemonEggMovesArray, id: \.self) { move in
                            Text(move.capitalized)
//                                .font(.caption)
                                .padding()
                        }
                    }
                }
            }
        }
        .navigationTitle(pokemonData.name?.capitalized ?? "")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            viewModel.loadPokemonDetails(context: viewContext, pokemonDetailsUrl: Constants.pokemonListUrl+String(pokemonData.id)) { pokemon in
                DispatchQueue.main.async {
                    switch pokemon {
                    case .success(let fetchedPokemonDetails):
                        pokemonDetails = fetchedPokemonDetails
                        updateMovesMap()
                        getEvolutionChain()
                    case .failure(let error):
                        print("Failed to load Pokémon: \(error.localizedDescription)")
                    }
                }
            }
        }
//        NavigationStack {
//
//        }
        
    }
    
    func updateMovesMap() {
        guard let pokemonDetails = pokemonDetails else { return }
        
        for move in pokemonDetails.moves {
            guard let expectedLearnMethod = Constants.MoveLearnMethod(move.versionGroupDetails[0].moveLearnMethod.name) else { continue }
            
            switch expectedLearnMethod {
            case .levelUp:
                let moveName = "\(move.move.name)\(move.versionGroupDetails[0].levelLearnedAt)"
                pokemonMovesMap[expectedLearnMethod, default: []].append(moveName)
            case .egg, .tutor, .machine:
                pokemonMovesMap[expectedLearnMethod, default: []].append(move.move.name)
            }
        }
        
        
        for learnMethod in pokemonMovesMap.keys {
            switch learnMethod {
            case .levelUp:
                pokemonMovesMap[learnMethod]?.sort() {
                    // Extracting the number part
                    let numberPart1 = Int($0.filter { $0.isNumber }) ?? 0
                    let numberPart2 = Int($1.filter { $0.isNumber }) ?? 0
                    
                    
                    // Extracting the text part
                    let textPart1 = $0.replacingOccurrences(of: String(numberPart1), with: "")
                    let textPart2 = $1.replacingOccurrences(of: String(numberPart2), with: "")
                    
                    // First sort by number, then alphabetically by word
                    return numberPart1 != numberPart2
                        ? numberPart1 < numberPart2
                        : textPart1 < textPart2
                }
            case .egg, .tutor, .machine:
                pokemonMovesMap[learnMethod]?.sort()
            }
        }
    }
    
    func getEvolutionChain() {
        guard let pokemonDetails = pokemonDetails else { return }
        viewModel.getEvolutionChain(context: viewContext, pokemonSpeciesUrl: pokemonDetails.species.url) { evolutionChainResult in
            DispatchQueue.main.async {
                switch evolutionChainResult {
                case .success(let evolutionChain):
                    pokemonEvolutionNode = buildEvolutionTree(evolutionChain: evolutionChain.chain)
                    //TODO: DECIDE HOW TO SAVE/SHOW INFORMATION
                case .failure(let error):
                    print("Failed to get evolution chain: \(error.localizedDescription)")
                }
            }
        }
    }
    
    func buildEvolutionTree(evolutionChain: EvolutionChainLink, evolvesFrom: String? = nil, currentNodeLevel: Int = 1) -> EvolutionNode {
        var evolutionMethod: (Constants.EvolutionTrigger, String)? = nil
        
        //TODO: ADD THE MISSING EVOLUTION METHOD
        if  let evolutionDetails = evolutionChain.evolutionDetails.first,
            let evolutionTrigger = Constants.EvolutionTrigger(evolutionDetails.trigger.name) {
            
            switch evolutionTrigger {
            case .levelUp:
                let minLevel = evolutionDetails.minLevel ?? 0
                evolutionMethod = (evolutionTrigger, "Level " + String(minLevel))
            case .useItem:
                let itemName = evolutionDetails.item?.name ?? ""
                evolutionMethod = (evolutionTrigger, "Use " + String(itemName))
            case .trade:
                var heldItemText = ""
                if let itemName = evolutionDetails.heldItem?.name {
                    heldItemText = " w/ " + itemName
                }
                evolutionMethod = (evolutionTrigger, "Trade" + heldItemText)
            default:
                print("Evolution trigger not yet supported: \(evolutionTrigger)")
            }
        }
        
        let pokemonName = evolutionChain.species.name
        var pokemonSpriteUrl: String? = nil
        if let pokemonId = evolutionChain.species.url.split(separator: "/").last {
            pokemonSpriteUrl = Constants.pokemonDefaultSpriteUrl + String(pokemonId) + ".png"
        }
        let children = evolutionChain.evolvesTo.map { buildEvolutionTree(evolutionChain: $0, evolvesFrom: pokemonName, currentNodeLevel: currentNodeLevel+1) }
        
        if children.isEmpty {
            maxNodeLevel = max(maxNodeLevel, currentNodeLevel)
        } else {
            maxNumberOfNodesInSameLevel = max(maxNumberOfNodesInSameLevel, children.count)
        }
        
        return EvolutionNode(
            species: pokemonName,
            defaultSpriteUrl: pokemonSpriteUrl,
            evolutionMethod: evolutionMethod,
            evolvesFrom: evolvesFrom,
            evolvesTo: children
        )
    }
}
