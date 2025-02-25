import SwiftUI

struct EvolutionView: View {
    let node: EvolutionNode
    
    let maxNumberOfNodesVertically: Int
    let currentNumberOfNodesVertically: Int // Helps positioning the node views vertically
    
    let spriteSize: CGFloat = 80
    let textHeight: CGFloat = 40
    let nodesSpacing: CGFloat = 10
    
    @State var topSpacing: CGFloat = 0
    @State var maxHeight: CGFloat = 0  // Dynamic height for each node

    var body: some View {
        HStack(alignment: .top, spacing: 5) {
            HStack(alignment: .top, spacing: 5) {
                if let method = node.evolutionMethod {
                    VStack {
                        Image(systemName: "arrow.right")
                            .resizable()
                            .frame(width: 40, height: 10)
                            .background(RoundedRectangle(cornerRadius: 10).stroke(Color.green, lineWidth: 1))
                            .padding(.top, topSpacing+spriteSize/2)
                        
                        Text("(\(method.1))")
                            .font(.caption2)
                            .foregroundColor(.gray)
                            .frame(height: textHeight)
                        Spacer()
                    }
                    .frame(height: max(0,(maxHeight-(CGFloat(currentNumberOfNodesVertically)-1)*nodesSpacing)/CGFloat(currentNumberOfNodesVertically)))
                    .background(RoundedRectangle(cornerRadius: 10).stroke(Color.blue, lineWidth: 1))
                }
                VStack(alignment: .center, spacing: 5) {
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
                    .padding(.top, topSpacing)
                    
                    Text(node.species.capitalized)
                        .font(.subheadline)
                        
                    Spacer()
                }
                .frame(height: max(0,(maxHeight-(CGFloat(currentNumberOfNodesVertically)-1)*nodesSpacing)/CGFloat(currentNumberOfNodesVertically)))
                .background(RoundedRectangle(cornerRadius: 10).stroke(Color.red, lineWidth: 1))

            }
            .frame(height: max(0,(maxHeight-(CGFloat(currentNumberOfNodesVertically)-1)*nodesSpacing)/CGFloat(currentNumberOfNodesVertically)))

            // Render children recursively
            if !node.evolvesTo.isEmpty {
                VStack(alignment: .center, spacing: nodesSpacing) {
                    ForEach(node.evolvesTo.indices, id: \.self) { childIndex in
                        EvolutionView(
                            node: node.evolvesTo[childIndex],
                            maxNumberOfNodesVertically: maxNumberOfNodesVertically,
                            currentNumberOfNodesVertically: max(node.evolvesTo.count, currentNumberOfNodesVertically)
                        )
                    }
                }
            }
        }
        .onAppear {
            calculateSpacing()
        }
        .background(RoundedRectangle(cornerRadius: 10).stroke(Color.purple, lineWidth: 1))
    }
    
    func calculateSpacing() {
        maxHeight = 2*nodesSpacing + CGFloat(maxNumberOfNodesVertically)*(spriteSize+textHeight) + (CGFloat(maxNumberOfNodesVertically)-1)*nodesSpacing
        topSpacing = (maxHeight - (CGFloat(currentNumberOfNodesVertically)*(spriteSize+textHeight) + (CGFloat(currentNumberOfNodesVertically)-1)*nodesSpacing))/2
    }
}
