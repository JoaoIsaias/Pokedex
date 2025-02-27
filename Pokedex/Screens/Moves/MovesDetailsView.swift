import SwiftUI
import CoreData

struct MovesDetailsView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    let moveName: String
    @State var move: Move?
    @StateObject private var viewModel = MovesDetailsViewModel()
    
    var body: some View {
        ScrollView {
            Text(moveName.capitalized)
                .font(.title)
                .fontWeight(.bold)
                .padding()
            HStack {
                HStack(spacing: 5) {
                    Text("Type: ")
                        .font(.title3)
                        .padding()
                    Image(move?.type.name ?? "")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 30)
                        .padding()
                }
                
                Image(move?.damageClass.name ?? "")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 30)
                    .padding()
            }
            
            HStack {
                HStack(spacing: 5) {
                    Text("Power Points (PP): \(move?.pp ?? 0)")
                        .font(.title3)
                        .padding()
                    
                    Text("Base Power: \(move?.power ?? 0)")
                        .font(.title3)
                        .padding()
                    
                    Text("Accuracy: \(move?.accuracy ?? 0)")
                        .font(.title3)
                        .padding()
                }
            }
        }
        .onAppear {
            print(Constants.pokemonDefaultMoveUrl + moveName)
            viewModel
                .loadMovesDetails(
                    context: viewContext,
                    moveDetailsUrl: Constants.pokemonDefaultMoveUrl + moveName
                ) { moveDataResult in
                    DispatchQueue.main.async {
                        switch moveDataResult {
                        case .success(let moveData):
                            print(moveData)
                            move = moveData
                        case .failure(let error):
                            print("Failed to load move \(moveName) details: \(error.localizedDescription)")
                        }
                    }
                    
                }
        }
    }
}

#Preview {
    MovesDetailsView(moveName: "pound").environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
