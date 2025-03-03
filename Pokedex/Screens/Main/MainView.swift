//

import SwiftUI
import CoreData

struct MainView: View {
    @Environment(\.managedObjectContext) private var viewContext

//    @FetchRequest(
//        sortDescriptors: [NSSortDescriptor(keyPath: \Pokemon.name, ascending: true)],
//        animation: .default)
//    private var pokemonList: FetchedResults<Item>
    
    @StateObject private var viewModel = MainViewModel()
    @State var pokemonList: [PokemonData] = []
    @State var searchPokemonList: [PokemonData] = []
    @State var isLoading: Bool = false
    @State private var searchText = ""
    
    @State private var screenHeight: CGFloat = 0
    private let itemHeight: CGFloat = 75

    var body: some View {
        NavigationStack {
//            Text("")
//            .navigationTitle("Search a Pokemon")
//            .searchable(text: $searchText)
//            .padding()
            
            List {
                ForEach(searchPokemonList.indices, id: \.self) { pokemonIndex in
                    NavigationLink {
                        PokemonDetailsView(pokemonId: Int(searchPokemonList[pokemonIndex].id))
                    } label: {
                        HStack(alignment: .center) {
                            AsyncImage(url: URL(string: searchPokemonList[pokemonIndex].image ?? "")){ result in
                                result.image?
                                    .resizable()
                                    .scaledToFill()
                            }
                            .frame(width: itemHeight, height: itemHeight)
                            .padding()
                            
                            VStack(alignment: .leading, spacing: 5) {
                                Text("#\(Int(searchPokemonList[pokemonIndex].id).pokemonNumberString())")
//                                .padding()
                                Text((searchPokemonList[pokemonIndex].name ?? "").capitalized)
//                                .padding()
                            }
                            
                        }
                        .onAppear {
                            if pokemonIndex == pokemonList.count - 1 && searchPokemonList == pokemonList && !isLoading {
                                isLoading = true
                                viewModel.loadMorePokemonList(context: viewContext, pokemonListLength: pokemonList.count) { result in
                                    DispatchQueue.main.async {
                                        isLoading = false
                                        switch result {
                                        case .success(let fetchedPokemonList):
                                            pokemonList.append(contentsOf: fetchedPokemonList)
                                            pokemonList.sort{ $0.id < $1.id }
                                            print("New pokemon count: \(pokemonList.count)")
                                            searchPokemonList = pokemonList
                                        case .failure(let error):
                                            print("Failed to load Pokémon: \(error.localizedDescription)")
                                        }
                                    }
                                }
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
                if pokemonList.isEmpty {
                    isLoading = true
                    Task {
                        viewModel.loadInitialPokemonList(context: viewContext) { result in
                            DispatchQueue.main.async {
                                isLoading = false
                                switch result {
                                case .success(let fetchedPokemonList):
                                    pokemonList.append(contentsOf: Set(fetchedPokemonList))
                                    pokemonList.sort{ $0.id < $1.id }
                                    searchPokemonList = pokemonList
                                case .failure(let error):
                                    print("Failed to load Pokémon: \(error.localizedDescription)")
                                }
                            }
                        }
                    }
                }
            }
            .background(
                GeometryReader { geometry in
                    Color.clear
                    .onAppear {
                        screenHeight = geometry.size.height
                    }
                }
            )
//            .onChange(of: pokemonList) {
//                let itemsSize = pokemonList.count * Int(itemHeight)
//                if !isLoading && itemsSize < Int(screenHeight) {
//                    isLoading = true
//                    viewModel.loadMorePokemonList(context: viewContext) { result in
//                        DispatchQueue.main.async {
//                            isLoading = false
//                            switch result {
//                            case .success(let fetchedPokemonList):
//                                pokemonList.append(contentsOf: fetchedPokemonList)
//                                pokemonList.sort{ $0.id < $1.id }
//                            case .failure(let error):
//                                print("Failed to load Pokémon: \(error.localizedDescription)")
//                            }
//                        }
//                    }
//                }
//            }
            .scrollIndicators(.hidden)
//            .toolbar {
//                ToolbarItem(placement: .navigationBarTrailing) {
//                    EditButton()
//                }
//                ToolbarItem {
//                    Button(action: addItem) {
//                        Label("Add Item", systemImage: "plus")
//                    }
//                }
//            }
            if isLoading {
                ProgressView()
                    .padding()
            }
        }
    }
//
//    private func addItem() {
//        withAnimation {
//            let newItem = Item(context: viewContext)
//            newItem.timestamp = Date()
//
//            do {
//                try viewContext.save()
//            } catch {
//                // Replace this implementation with code to handle the error appropriately.
//                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
//                let nsError = error as NSError
//                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
//            }
//        }
//    }
//
//    private func deleteItems(offsets: IndexSet) {
//        withAnimation {
//            offsets.map { items[$0] }.forEach(viewContext.delete)
//
//            do {
//                try viewContext.save()
//            } catch {
//                // Replace this implementation with code to handle the error appropriately.
//                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
//                let nsError = error as NSError
//                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
//            }
//        }
//    }
}

private let itemFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .medium
    return formatter
}()

#Preview {
    MainView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
