import SwiftUI
import CoreData

struct MovesDetailsView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    let spriteHeight: CGFloat = 30
    private let itemHeight: CGFloat = 75
    
    let currentPokemonId: Int
    @Binding var moveName: String
    @Binding var nextPokemonId: Int
    @Binding var showView: Bool
    
    @State var move: Move?
    @State var moveDescription: String?
    @State var pokemonList: [PokemonData] = []
    
    @Binding var scrollToIndex: Int
    @State var dataIsLoaded: Bool = false
    
    @StateObject private var viewModel = MovesDetailsViewModel()
    
    private var dragGesture: some Gesture {
            DragGesture(minimumDistance: 10)
            .onChanged { _ in
                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
            }
        }
    
    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                VStack(spacing: 0) {
                    Text(moveName.capitalized)
                        .font(.title)
                        .fontWeight(.bold)
                        .padding()
                    
                    HStack {
                        HStack(spacing: 5) {
                            Text("Type: ")
                                .font(.title3)
                            Image(move?.type?.name ?? "")
                                .resizable()
                                .scaledToFit()
                                .frame(height: spriteHeight)
                        }
                        Spacer()
                        Text("/")
                            .font(.title3)
                        Spacer()
                        HStack(spacing: 5) {
                            Text("Category: ")
                                .font(.title3)
                            Image(move?.damageClass?.name ?? "")
                                .resizable()
                                .scaledToFit()
                                .frame(height: spriteHeight)
                        }
                    }
                    .padding()
                    
                    HStack {
                        HStack(spacing: 5) {
                            Text("PP: ")
                                .font(.title3)
                            Text("\(move?.pp != nil ? String(move?.pp ?? 0) : "---")")
                                .font(.title3)
                                .fontWeight(.bold)
                        }
                        Spacer()
                        HStack(spacing: 5) {
                            Text("Power: ")
                                .font(.title3)
                            Text("\(move?.power != nil ? String(move?.power ?? 0) : "---")")
                                .font(.title3)
                                .fontWeight(.bold)
                        }
                        Spacer()
                        HStack(spacing: 5) {
                            Text("Accuracy: ")
                                .font(.title3)
                            Text("\(move?.accuracy != nil ? String(move?.accuracy ?? 0) : "---")")
                                .font(.title3)
                                .fontWeight(.bold)
                        }
                    }
                    .padding()
                    
                    Text("Description: \(moveDescription ?? "")")
                        .font(.title3)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .multilineTextAlignment(.leading)
                        .padding()
                    
                    Text("Pokemon that learn this move:")
                        .font(.title2)
                        .fontWeight(.bold)
                        .padding()
                    
                    LazyVStack(alignment: .leading) {
                        ForEach(pokemonList.indices, id: \.self) { pokemonIndex in
                            let isCurrentPokemon = (Int(pokemonList[pokemonIndex].id) == currentPokemonId)
                            
                            HStack() {
                                AsyncImage(url: URL(string: pokemonList[pokemonIndex].image ?? "")) { result in
                                    result.image?
                                        .resizable()
                                        .scaledToFill()
                                }
                                .frame(width: itemHeight, height: itemHeight)
                                .padding()
                                
                                VStack(alignment: .leading, spacing: 5) {
                                    Text("#\(Int(pokemonList[pokemonIndex].id).pokemonNumberString())")
                                    Text((pokemonList[pokemonIndex].name ?? "").capitalized)
                                }
                                
                                Spacer()
                                
                                if !isCurrentPokemon { // To copy system list indicator
                                    Image(systemName: "chevron.right")
                                    .foregroundColor(.gray)
                                }
                            }
                            .contentShape(Rectangle())
                            .onTapGesture(perform: {
                                if !isCurrentPokemon{
                                    showView = false
                                    nextPokemonId = Int(pokemonList[pokemonIndex].id)
                                    scrollToIndex = pokemonIndex
                                }
                            })
                            Divider()
                        }
                    }
                    .padding()
                    .listStyle(PlainListStyle())
                }
            }
            .task {
                await loadMoveDetails()
            }
            .onChange(of: dataIsLoaded) {
                if scrollToIndex != 0 {
                    //position is not 100% correct. Maybe try to fix in future, but not important
                    proxy.scrollTo(scrollToIndex)
                }
            }
        }
    }
    
    @MainActor
    private func loadMoveDetails() async {
        do {
            move = try await viewModel.loadMovesDetails(
                context: viewContext,
                moveDetailsUrl: Constants.pokemonDefaultMoveUrl + moveName
            )
            setMoveDescription()
            
            let fetchedPokemonList = try await viewModel.fetchPokemonList(
                context: viewContext,
                pokemonNames: move?.learnedByPokemon.map({$0.name}) ?? []
            )
            
            pokemonList = fetchedPokemonList
            dataIsLoaded = true
        } catch {
            print("(thrown from function: \(#function)) -> Failed to load move \(moveName) details: \(error.localizedDescription)")
        }
    }
    
    private func setMoveDescription() {
        moveDescription = move?.flavorTextEntries
            .last(where: { $0.language?.name == "en" })?
            .flavorText
            .replacingOccurrences(of: "\n", with: " ")
    }
    
    private func getPokemonIdFromPokemonUrl(url: String) -> Int? {
        return Int(url.split(separator: "/").last ?? "")
    }
}

#Preview {
    StatefulPreviewWrapper(("tackle", 0, true, 0)) { binding in
        MovesDetailsView(
            currentPokemonId: 1,
            moveName: binding.0,
            nextPokemonId: binding.1,
            showView: binding.2,
            scrollToIndex: binding.3
        )
            .environment(
                \.managedObjectContext,
                PersistenceController.preview.container.viewContext
            )
    }
}
