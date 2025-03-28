import SwiftUI
import CoreData

struct MainView: View {
    @State private var isTabBarVisible: Bool = true
    var body: some View {
        ZStack {
            if isTabBarVisible {
                TabView {
                    PokemonListView()
                    .tabItem {
                        Label("Pokemon List", systemImage: "list.dash")
                    }
                    
                    MovesListView()
                    .tabItem {
                        Label("Moves List", systemImage: "bolt")
                    }
                }
            } else {
                EmptyView()
            }
        }
    }
}

#Preview {
    MainView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
