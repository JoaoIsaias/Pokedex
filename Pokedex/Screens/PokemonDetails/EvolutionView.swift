import SwiftUI

struct EvolutionView: View {
    let node: EvolutionNode
    let availableHeight: CGFloat  // Dynamic height for each node

    var body: some View {
        HStack {
            HStack(spacing: 10) {
                if let method = node.evolutionMethod {
                    VStack {
                        Image(systemName: "arrow.right")
                            .resizable()
                            .frame(width: 30, height: 10)
                            .foregroundColor(.blue)
                        
                        Text("(\(method.1))")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                }
                
                Text(node.species.capitalized)
                    .font(.headline)
                    .foregroundColor(.blue)

            }
            .frame(height: availableHeight)  // Control height dynamically
//            .background(RoundedRectangle(cornerRadius: 10).stroke(Color.gray, lineWidth: 1))
            
            // Render children recursively
            if !node.evolvesTo.isEmpty {
                VStack(spacing: 5) {
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
