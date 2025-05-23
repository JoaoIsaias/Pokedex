import SwiftUI
import CoreData

struct PokemonDetailsView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    let pokemonId: Int
    
    @State var pokemonData: PokemonData?
    @State var pokemonDetails: Pokemon?
    
    @State var pokemonSpritesUrlArray: [String?] = []
    @State var pokemonMovesMap: [Constants.MoveLearnMethod: [String]] = [:]
    
    @State var pokemonEvolutionNode: EvolutionNode?
    @State var maxNodeLevel: Int = 1
    @State var maxNumberOfNodesInSameLevel: Int = 1
    
    @StateObject private var viewModel = PokemonDetailsViewModel()
    
    //The following variables are all used to help navigation with modals open/closed
    //General
    @State var nextPokemonId: Int = 0
    @State var showNextPokemon: Bool = false
    //Moves
    @State var moveClicked: String = ""
    @State var showMoveDetailsView: Bool = false
    @State var scrollMovesPokemonListToIndex: Int = 0
    //Items
    @State var itemClicked: String = ""
    @State var showItemDetailsView: Bool = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                
                ScrollView(.horizontal, showsIndicators: true) {
                    HStack(spacing: 0) {
                        ForEach(pokemonSpritesUrlArray.indices, id: \.self) { index in
                            AsyncImage(url: URL(string: pokemonSpritesUrlArray[index] ?? "")) { result in
                                result.image?
                                    .resizable()
                                    .scaledToFill()
                            }
                            .shadow(radius: 5, x: 5, y: 5)
                            .frame(width: UIScreen.main.bounds.width * 0.8, height: UIScreen.main.bounds.width * 0.8)
                            .background(RoundedRectangle(cornerRadius: 10).stroke(Color.gray, lineWidth: 1))
                            .scrollTransition { content, phase in
                                content
                                    .opacity(phase.isIdentity ? 1 : 0.5) // Apply opacity animation
                                    .scaleEffect(y: phase.isIdentity ? 1 : 0.7) // Apply scale animation
                            }
                            .padding()
                        }
                    }
                    .scrollTargetLayout() // Align content to the view
                }
                .contentMargins(20, for: .scrollContent) // Add padding
                .scrollTargetBehavior(.viewAligned)
                .scrollIndicators(.visible)
                
                
                HStack(alignment: .center) {
                    Text("#\(pokemonId.pokemonNumberString())")
                        .font(.title)
                        .fontWeight(.bold)
                        .padding()
                    
                    Text((pokemonData?.name ?? "").capitalized)
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
                            pokemonDetailsId: pokemonId,
                            node: pokemonEvolutionNode,
                            maxNumberOfNodesVertically: maxNumberOfNodesInSameLevel,
                            currentNumberOfNodesVertically: 1,
                            isInItemSheet: false,
                            itemName: $itemClicked,
                            nextPokemonId: $nextPokemonId,
                            showItemDetailsView: $showItemDetailsView
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
                                Button {
                                    moveClicked = move.trimmingCharacters(in: .decimalDigits)
                                    scrollMovesPokemonListToIndex = 0
                                    showMoveDetailsView = true
                                } label: {
                                    Text(move.trimmingCharacters(in: .decimalDigits).capitalized)
                                }
                                .padding()
                                
                                Text(String(Int(move.filter { $0.isNumber }) ?? 0))
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
                                Button {
                                    moveClicked = move
                                    scrollMovesPokemonListToIndex = 0
                                    showMoveDetailsView = true
                                } label: {
                                    Text(move.capitalized)
                                }
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
                                Button {
                                    moveClicked = move
                                    scrollMovesPokemonListToIndex = 0
                                    showMoveDetailsView = true
                                } label: {
                                    Text(move.capitalized)
                                }
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
                                Button {
                                    moveClicked = move
                                    scrollMovesPokemonListToIndex = 0
                                    showMoveDetailsView = true
                                } label: {
                                    Text(move.capitalized)
                                }
                                .padding()
                            }
                        }
                    }
                }
            }
            .navigationTitle(pokemonData?.name?.capitalized ?? "")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                if nextPokemonId != 0 {
                    if moveClicked != "" {
                        nextPokemonId = 0
                        showMoveDetailsView = true
                    } else if itemClicked != "" {
                        nextPokemonId = 0
                        showItemDetailsView = true
                    }
                }
                showNextPokemon = false
                Task {
                    if pokemonData == nil {
                        await loadPokemonData()
                    }
                    if pokemonDetails == nil {
                        await loadPokemonDetails()
                    }
                }
            }
            .sheet(isPresented: $showMoveDetailsView) {
                MovesDetailsView(
                    currentPokemonId: pokemonId,
                    moveName: $moveClicked,
                    nextPokemonId: $nextPokemonId,
                    showView: $showMoveDetailsView,
                    scrollToIndex: $scrollMovesPokemonListToIndex
                )
            }
            .onChange(of: nextPokemonId) {
                if nextPokemonId != 0 {
                    showNextPokemon = true
                }
            }
            .background(
                NavigationLink(
                    destination: PokemonDetailsView(pokemonId: nextPokemonId),
                    isActive: $showNextPokemon
                ) {
                    EmptyView()
                }
            )
            .onDisappear() {
                showNextPokemon = false
                showMoveDetailsView = false
                showItemDetailsView = false
            }
        }
    }
    
    // Load Pokemon Data from CoreData
    func loadPokemonData() async {
        do {
            let pokemonDataResult = try await viewModel.fetchPokemonData(context: viewContext, pokemonId: pokemonId)
                pokemonData = pokemonDataResult
        } catch {
            print("(thrown from function: \(#function)) -> Failed to fetch PokemonData on CoreData: \(error.localizedDescription)")
        }
    }
    
    // Load Pokemon Details and handle evolution chain
    func loadPokemonDetails() async {
        do {
            let pokemonDetailsResult = try await viewModel.loadPokemonDetails(context: viewContext, pokemonDetailsUrl: Constants.pokemonDetailsDefaultUrl + String(pokemonId))
            pokemonDetails = pokemonDetailsResult
            pokemonSpritesUrlArray = [pokemonData?.image, pokemonDetailsResult.sprites.frontShiny]
            await updateMovesMap()
            await getEvolutionChain()
        } catch {
            print("(thrown from function: \(#function)) -> Failed to load Pokemon details: \(error.localizedDescription)")
        }
    }
    
    // Update the moves map
    func updateMovesMap() async {
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
    
    // Fetch evolution chain
    func getEvolutionChain() async {
        guard let pokemonDetails = pokemonDetails else { return }
        
        do {
            // Fetch the evolution chain asynchronously
            let evolutionChain = try await viewModel.getEvolutionChain(context: viewContext, pokemonSpeciesUrl: pokemonDetails.species.url)
            pokemonEvolutionNode = await buildEvolutionTree(evolutionChain: evolutionChain.chain)
            //TODO: DECIDE HOW TO SAVE/SHOW INFORMATION
        } catch {
            print("(thrown from function: \(#function)) -> Failed to get evolution chain: \(error.localizedDescription)")
        }
    }
    
    // Build evolution tree
    func buildEvolutionTree(evolutionChain: EvolutionChainLink, evolvesFrom: String? = nil, currentNodeLevel: Int = 1) async -> EvolutionNode {
        var evolutionMethod: (Constants.EvolutionTrigger, String)? = nil
        
        // TODO: Add the missing evolution method + REFACTOR THIS HERE AND IN ITEMDETAILS
        if let evolutionDetails = evolutionChain.evolutionDetails.first,
           let evolutionTrigger = Constants.EvolutionTrigger(evolutionDetails.trigger.name) {
            
            switch evolutionTrigger {
            case .levelUp:
                let minLevel = evolutionDetails.minLevel ?? 0
                var heldItemText = ""
                if let itemName = evolutionDetails.heldItem?.name {
                    heldItemText = " w/ " + itemName
                }
                evolutionMethod = (evolutionTrigger, "Level " + String(minLevel) + heldItemText)
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
        
        let children = await withTaskGroup(of: EvolutionNode.self) { group in
            for childChain in evolutionChain.evolvesTo {
                group.addTask {
                    await buildEvolutionTree(evolutionChain: childChain, evolvesFrom: pokemonName, currentNodeLevel: currentNodeLevel + 1)
                }
            }
            
            var childNodes: [EvolutionNode] = []
            for await child in group {
                childNodes.append(child)
            }
            return childNodes
        }
        
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


#Preview {
    PokemonDetailsView(pokemonId: 1).environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
