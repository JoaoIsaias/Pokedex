import SwiftUI
import CoreData

struct PokemonDetailsView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    //    @FetchRequest(
    //        sortDescriptors: [NSSortDescriptor(keyPath: \Pokemon.name, ascending: true)],
    //        animation: .default)
    //    private var pokemonList: FetchedResults<Item>
    @State var pokemonData: PokemonData
    @State var pokemonDetails: Pokemon?
    
    @State var pokemonMovesMap: [Constants.MoveLearnMethod: [String]] = [:]
    
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
            } else {
                Text("TEMP")
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
//            default:
//                print("Error updating moves: Unrecognized move learn method: \(expectedLearnMethod)")
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
}
