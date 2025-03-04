import SwiftUI
import CoreData

struct MovesDetailsView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    let moveName: String
    let spriteHeight: CGFloat = 30
    
    @State var move: Move?
    @State var moveDescription: String?
    @StateObject private var viewModel = MovesDetailsViewModel()
    
    var body: some View {
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
                
                //TODO: Add Pokemon List that learn this move
                
                Text("Pokemon that learn this move:")
                    .font(.title2)
                    .fontWeight(.bold)
                    .padding()
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
                            move = moveData
                            setMoveDescription()
                        case .failure(let error):
                            print("Failed to load move \(moveName) details: \(error.localizedDescription)")
                        }
                    }
                    
                }
        }
    }
    
    func setMoveDescription() {
        let originalMoveDescription = move?.flavorTextEntries.last { $0.language?.name == "en" }?.flavorText
        moveDescription = originalMoveDescription?.replacingOccurrences(of: "\n", with: " ")
    }
}

#Preview {
    MovesDetailsView(moveName: "pound").environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
