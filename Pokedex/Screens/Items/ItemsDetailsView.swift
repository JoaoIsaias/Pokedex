import SwiftUI
import CoreData

struct ItemsDetailsView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    private let itemHeight: CGFloat = 75
    
    @Binding var itemName: String
    
    @State var item: Item?
    @State var itemDescription: String?
    
    @StateObject private var viewModel = ItemsDetailsViewModel()
    
    var body: some View {
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
            }
        }
        .task {
            await loadItemDetails()
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
        } catch {
            print("Failed to load item \(itemName) details: \(error.localizedDescription)")
        }
    }
    
    private func setItemDescription() {
        itemDescription = item?.flavorTextEntries
            .last(where: { $0.language?.name == "en" })?
            .text
            .replacingOccurrences(of: "\n", with: " ")
    }
}

#Preview {
    StatefulPreviewWrapper("water-stone") { binding in
        ItemsDetailsView(itemName: binding).environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
