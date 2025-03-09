import SwiftUI
import CoreData

struct ItemsDetailsView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    private let itemHeight: CGFloat = 75
    
    @Binding var itemName: String
    
    @State var item: Item?
    @State var itemDescription: String?
    @State var pokemonEvolutionNodeList: [EvolutionNode] = []
    
    @StateObject private var viewModel = ItemsDetailsViewModel()
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 0) {
                    Text(itemName.capitalized)
                        .font(.title)
                        .fontWeight(.bold)
                        .padding()
                    
                    AsyncImage(url: URL(string: item?.sprites.default ?? "")) { result in
                        result.image?
                            .resizable()
                            .scaledToFill()
                    }
                    .frame(width: itemHeight, height: itemHeight)
                    .padding()
                    
                    Text("Description: \(itemDescription ?? "")")
                        .font(.title3)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .multilineTextAlignment(.leading)
                        .padding()
                    
                    if !pokemonEvolutionNodeList.isEmpty {
                        Text("Pokemon that evolve with this item:")
                            .font(.title2)
                            .fontWeight(.bold)
                            .padding()
                        
                        LazyVStack(alignment: .leading) {
                            ForEach(pokemonEvolutionNodeList.indices, id: \.self) { evolutionNodeIndex in
                                EvolutionView(
                                    pokemonDetailsId: 0, //Never equal to any pokemon
                                    node: pokemonEvolutionNodeList[evolutionNodeIndex],
                                    maxNumberOfNodesVertically: 1,
                                    currentNumberOfNodesVertically: 1
                                )
                                .padding()
                            }
                        }
                    }
                }
            }
            .task {
                await loadItemDetails()
            }
        }
    }
    
    @MainActor
    private func loadItemDetails() async {
        do {
            item = try await viewModel.loadItemDetails(
                context: viewContext,
                itemDetailsUrl: Constants.pokemonDefaultItemUrl + itemName
            )
            setItemDescription()
            try await setPokemonEvolutionsList(effectEntriesText: item?.effectEntries.first?.effect ?? "")
        } catch {
            print("(thrown from function: \(#function)) -> Failed to load item \(itemName) details: \(error.localizedDescription)")
        }
    }
    
    private func setItemDescription() {
        itemDescription = item?.flavorTextEntries
            .last(where: { $0.language?.name == "en" })?
            .text
            .replacingOccurrences(of: "\n", with: " ")
    }
    
    private func setPokemonEvolutionsList(effectEntriesText: String) async throws {
        do {
            let pokemonList = try await getPokemonsInEffectEntries(text: effectEntriesText)
            pokemonEvolutionNodeList = try await getEvolutionNodesInPokemonList(pokemonList: pokemonList)
        } catch {
            print("(thrown from function: \(#function)) -> Failed to get evolutions for \(itemName): \(error.localizedDescription)")
            throw error
        }
    }
    
    
    
    private func getPokemonsInEffectEntries(text: String) async throws -> [String] {
        do {
            let pokemonList = try await viewModel.findPokemonNames(in: text, context: viewContext)
            return pokemonList
        } catch {
            print("(thrown from function: \(#function)) -> Failed to get Pokemon names in Effect Entries: \(error.localizedDescription)")
            throw error
        }
    }
    
    private func getEvolutionNodesInPokemonList(pokemonList: [String]) async throws -> [EvolutionNode] {
        do {
            let pokemonEvolutionChainList = try await viewModel.getEvolutionNodes(in: pokemonList, context: viewContext)
            return pokemonEvolutionChainList
        } catch {
            print("(thrown from function: \(#function)) -> Failed to get Pokemon evolution chains in Pokemon list: \(error.localizedDescription)")
            throw error
        }
    }
}

#Preview {
    StatefulPreviewWrapper("water-stone") { binding in
        ItemsDetailsView(itemName: binding).environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
