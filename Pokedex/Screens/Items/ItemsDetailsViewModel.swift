import Foundation
import CoreData

class ItemsDetailsViewModel: ObservableObject {
    private var apiClient: APIClientProtocol
    
    init() {
        self.apiClient = APIClient()
    }
    
    func loadItemDetails(context: NSManagedObjectContext, itemDetailsUrl: String) async throws -> Item {
        let item: Item? = try await apiClient.request(itemDetailsUrl, method: .get, parameters: nil)
        guard let item = item else { throw NSError(domain: "No item data", code: -1) }
        return item
    }
}
