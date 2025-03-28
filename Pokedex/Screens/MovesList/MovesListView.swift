import SwiftUI
import CoreData

struct MovesListView: View {
    @Environment(\.managedObjectContext) private var viewContext

    var body: some View {
        Text("Moves List")
    }
}

#Preview {
    MainView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
