import Foundation
import CoreData

class MovesDetailsViewModel: ObservableObject {
    private var apiClient: APIClientProtocol
    
    init() {
        self.apiClient = APIClient()
    }
    
    func loadMovesDetails(context: NSManagedObjectContext, moveDetailsUrl: String, completion: @escaping (Result<Move, Error>) -> Void) {
        apiClient.request(moveDetailsUrl, method: .get, parameters: nil) {
            [weak self] (result: Result<Move?, Error>) in
//            guard let self = self else { return }
            switch result {
            case .success(let move):
                guard let move = move else { return }
                completion(.success(move))
            case .failure(let error):
                print("Error obtaining move details: \(error)")
                completion(.failure(error))
                
            }
        }
    }
}
