import SwiftUI

struct EvolutionView: View {
    let node: EvolutionNode
    let availableHeight: CGFloat  // Dynamic height for each node
    
    let spriteSize: CGFloat = 75

    var body: some View {
        HStack(alignment: .center) {
            HStack(alignment: .center, spacing: 10) {
                if let method = node.evolutionMethod {
                    VStack {
                        Image(systemName: "arrow.right")
                            .resizable()
                            .frame(width: 30, height: 10)
                        
                        Text("(\(method.1))")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                }
                VStack(alignment: .center) {
                    AsyncImage(url: URL(string: node.defaultSpriteUrl ?? "")) { result in
                        switch result {
                        case .empty:
                            ProgressView() // Show loading indicator
                                .frame(width: spriteSize, height: spriteSize)
                        case .success(let image):
                            image.resizable()
                                .scaledToFit()
                                .frame(width: spriteSize, height: spriteSize) // Adjust size as needed
                        case .failure:
                            Image(systemName: "xmark.octagon") // Error placeholder
                                .resizable()
                                .scaledToFit()
                                .frame(width: spriteSize, height: spriteSize)
                        @unknown default:
                            EmptyView()
                        }
                    }
                    .background(RoundedRectangle(cornerRadius: 10).stroke(Color.gray, lineWidth: 1))
                    
                    Text(node.species.capitalized)
                        .font(.headline)
                        
                    
                    Spacer()
                }
                .frame(height: availableHeight)

            }
            .frame(height: availableHeight)  // Control height dynamically
            
            // Render children recursively
            if !node.evolvesTo.isEmpty {
                VStack(alignment: .center, spacing: 5) {
                    ForEach(node.evolvesTo, id: \.species) { child in
                        EvolutionView(
                            node: child,
                            availableHeight: availableHeight / CGFloat(node.evolvesTo.count)  // Distribute height
                        )
                    }
                }
            }
        }
    }
}
