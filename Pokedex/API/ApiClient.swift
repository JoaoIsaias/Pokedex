import Foundation
import Alamofire

protocol APIClientProtocol {
    func request<T: Decodable>(_ url: String, method: HTTPMethod, parameters: Parameters?) async throws -> T
}

class APIClient: APIClientProtocol {
    func request<T: Decodable>(_ url: String, method: HTTPMethod, parameters: Parameters?) async throws -> T {
        return try await withCheckedThrowingContinuation { continuation in
            AF.request(url, method: method, parameters: parameters)
                .validate()
                .responseDecodable(of: T.self) { response in
                    switch response.result {
                    case .success(let data):
                        continuation.resume(returning: data)
                    case .failure(let error):
                        continuation.resume(throwing: error)
                    }
                }
        }
    }
}
