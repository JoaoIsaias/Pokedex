import SwiftUI

struct EvolutionView: View {    
    let pokemonDetailsId: Int
    let node: EvolutionNode
    let maxNumberOfNodesVertically: Int
    let currentNumberOfNodesVertically: Int // Helps positioning the node views vertically
    
    let isInItemSheet: Bool
    
    let spriteSize: CGFloat = 80
    let textHeight: CGFloat = 40
    let nodesSpacing: CGFloat = 10
    
    @State var topSpacing: CGFloat = 0
    @State var maxHeight: CGFloat = 0  // Dynamic height for each node
    
    @Binding var itemName: String
    @Binding var nextPokemonId: Int
    @Binding var showItemDetailsView: Bool
    
    private var pokemonImageView: some View {
        AsyncImage(url: URL(string: node.defaultSpriteUrl ?? "")) { result in
            switch result {
            case .empty:
                ProgressView()
                    .frame(width: spriteSize, height: spriteSize)
            case .success(let image):
                image.resizable()
                    .scaledToFit()
                    .frame(width: spriteSize, height: spriteSize)
            case .failure:
                Image(systemName: "xmark.octagon")
                    .resizable()
                    .scaledToFit()
                    .frame(width: spriteSize, height: spriteSize)
            @unknown default:
                EmptyView()
            }
        }
    }

    var body: some View {
        NavigationStack {
            HStack(alignment: .top, spacing: 5) {
                HStack(alignment: .top, spacing: 5) {
                    if let method = node.evolutionMethod {
                        VStack(spacing: 5) {
                            Image(systemName: "arrow.right")
                                .resizable()
                                .frame(width: 50, height: 10)
                                .padding(.top, topSpacing+0.8*spriteSize/2)
                            if isInItemSheet == true {
                                Text("(\(method.1))")
                                    .font(.caption2)
                                    .foregroundColor(.gray)
                                    .frame(width: 50, height: textHeight)
                            } else if method.0 == .useItem {
                                Button {
                                    itemName = method.1.replacingOccurrences(of: "Use ", with: "")
                                    showItemDetailsView = true
                                } label: {
                                    Text("(\(method.1))")
                                        .font(.caption2)
                                        .frame(width: 50, height: textHeight)
                                }
                            } else if method.1.contains("w/"),
                            let range = method.1.range(of: #"w/\s(.+)"#, options: .regularExpression) {
                                Button {
                                    itemName = String(method.1[range]).replacingOccurrences(of: "w/ ", with: "")
                                    showItemDetailsView = true
                                } label: {
                                    Text("(\(method.1))")
                                        .font(.caption2)
                                        .frame(width: 50, height: textHeight)
                                }
                            } else {
                                Text("(\(method.1))")
                                    .font(.caption2)
                                    .foregroundColor(.gray)
                                    .frame(width: 50, height: textHeight)
                            }
                            Spacer()
                        }
                        .frame(height: max(0,(maxHeight-(CGFloat(currentNumberOfNodesVertically)-1)*nodesSpacing)/CGFloat(currentNumberOfNodesVertically)))
                    }
                    VStack(alignment: .center, spacing: 5) {
                        if let pokemonId = getPokemonIdFromSpriteUrl(), pokemonId != pokemonDetailsId {
                            Button {
                                showItemDetailsView = false
                                nextPokemonId = pokemonId
                            } label: {
                                pokemonImageView
                            }
                            .background(RoundedRectangle(cornerRadius: 10).stroke(Color.blue, lineWidth: 1))
                            .padding(.top, topSpacing)
                        } else {
                            pokemonImageView // Just display the image without navigation
                            .background(RoundedRectangle(cornerRadius: 10).stroke(Color.gray, lineWidth: 1))
                            .padding(.top, topSpacing)
                        }
                        
                        Text(node.species.capitalized)
                            .font(.footnote)
                        
                        Spacer()
                    }
                    .frame(height: max(0,(maxHeight-(CGFloat(currentNumberOfNodesVertically)-1)*nodesSpacing)/CGFloat(currentNumberOfNodesVertically)))
                    
                }
                .frame(height: max(0,(maxHeight-(CGFloat(currentNumberOfNodesVertically)-1)*nodesSpacing)/CGFloat(currentNumberOfNodesVertically)))
                
                // Render children recursively
                if !node.evolvesTo.isEmpty {
                    VStack(alignment: .center, spacing: nodesSpacing) {
                        ForEach(node.evolvesTo.indices, id: \.self) { childIndex in
                            EvolutionView(
                                pokemonDetailsId: pokemonDetailsId,
                                node: node.evolvesTo[childIndex],
                                maxNumberOfNodesVertically: maxNumberOfNodesVertically,
                                currentNumberOfNodesVertically: max(node.evolvesTo.count, currentNumberOfNodesVertically),
                                isInItemSheet: isInItemSheet,
                                itemName: $itemName,
                                nextPokemonId: $nextPokemonId,
                                showItemDetailsView: $showItemDetailsView
                            )
                        }
                    }
                }
            }
            .onAppear {
                calculateSpacing()
            }
            .sheet(isPresented: isInItemSheet ? .constant(false) : $showItemDetailsView) {
                ItemsDetailsView(currentPokemonId: pokemonDetailsId, itemName: $itemName, nextPokemonId: $nextPokemonId, showView: $showItemDetailsView)
            }
        }
    }
    
    func calculateSpacing() {
        maxHeight = 2*nodesSpacing + CGFloat(maxNumberOfNodesVertically)*(spriteSize+textHeight) + (CGFloat(maxNumberOfNodesVertically)-1)*nodesSpacing
        topSpacing = (maxHeight - (CGFloat(currentNumberOfNodesVertically)*(spriteSize+textHeight) + (CGFloat(currentNumberOfNodesVertically)-1)*nodesSpacing))/2
    }
    
    func getPokemonIdFromSpriteUrl() -> Int? {
        guard
            let spriteSubString = node.defaultSpriteUrl?.split(separator: "/").last,
            let idString = String(spriteSubString).split(separator: ".").first,
            let id = Int(idString)
        else {
            return nil
        }
        return id
    }
}

#Preview {
    StatefulPreviewWrapper(("water-stone", 2, false)) { binding in
        EvolutionView(
            pokemonDetailsId: 1,
            node: EvolutionNode(
                species: "Bulbasaur",
                defaultSpriteUrl: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/1.png",
                evolutionMethod: nil,
                evolvesFrom: nil,
                evolvesTo: []
            ),
            maxNumberOfNodesVertically: 1,
            currentNumberOfNodesVertically: 1,
            isInItemSheet: false,
            itemName: binding.0,
            nextPokemonId: binding.1,
            showItemDetailsView: binding.2
        )
    }
}
