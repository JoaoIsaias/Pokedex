import SwiftUI
import CoreData

struct MainView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @StateObject private var viewModel = MainViewModel()
    @State var pokemonList: [PokemonData] = []
    @State var searchPokemonList: [PokemonData] = []
    @State var isLoading: Bool = false
    @State private var searchText = ""

    @State private var screenHeight: CGFloat = 0
    private let itemHeight: CGFloat = 75

    var body: some View {
        NavigationStack {
            if isLoading {
                VStack {
                    Spacer()
                    Text("Loading Pokémon list...")
                        .font(.title)
                        .padding()
                    ProgressView()
                        .padding()
                    Spacer()
                }
                Spacer()
            } else {
                List {
                    ForEach(searchPokemonList.indices, id: \.self) { pokemonIndex in
                        NavigationLink {
                            PokemonDetailsView(pokemonId: Int(searchPokemonList[pokemonIndex].id))
                        } label: {
                            HStack(alignment: .center) {
                                AsyncImage(url: URL(string: searchPokemonList[pokemonIndex].image ?? "")) { result in
                                    result.image?
                                        .resizable()
                                        .scaledToFill()
                                }
                                .frame(width: itemHeight, height: itemHeight)
                                .padding()
                                
                                VStack(alignment: .leading, spacing: 5) {
                                    Text("#\(Int(searchPokemonList[pokemonIndex].id).pokemonNumberString())")
                                    Text((searchPokemonList[pokemonIndex].name ?? "").capitalized)
                                }
                            }
                        }
                    }
                }
                .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always))
                .listStyle(PlainListStyle())
                .onChange(of: searchText) {
                    if searchText.isEmpty {
                        searchPokemonList = pokemonList
                    } else {
                        searchPokemonList = pokemonList.filter { pokemon in
                            pokemon.name?.lowercased().contains(searchText.lowercased()) ?? false ||
                            pokemon.id == Int(searchText) ?? 0
                        }
                    }
                }
                .task {
                    await loadPokemon()
                }
                .background(
                    GeometryReader { geometry in
                        Color.clear
                            .onAppear {
                                screenHeight = geometry.size.height
                            }
                    }
                )
                .scrollIndicators(.hidden)
            }
        }
    }

    private func loadPokemon() async {
        if pokemonList.isEmpty {
            isLoading = true
            do {
                let fetchedPokemonList = try await viewModel.loadPokemonList(context: viewContext)
                DispatchQueue.main.async {
                    isLoading = false
                    pokemonList.append(contentsOf: Set(fetchedPokemonList))
                    pokemonList.sort { $0.id < $1.id }
                    searchPokemonList = pokemonList
                }
            } catch {
                DispatchQueue.main.async {
                    isLoading = false
                    print("Failed to load Pokémon: \(error.localizedDescription)")
                }
            }
        }
    }
}

#Preview {
    MainView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
