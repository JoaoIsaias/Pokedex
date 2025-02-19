import Foundation
import Alamofire

protocol APIClientProtocol {
    func request<T: Decodable>(_ url: String, method: HTTPMethod, parameters: Parameters?, completion: @escaping (Result<T?, Error>) -> Void)
}

class APIClient: APIClientProtocol {
    func request<T: Decodable>(_ url: String, method: HTTPMethod, parameters: Parameters?, completion: @escaping (Result<T?, Error>) -> Void) {
        AF.request(url, method: method, parameters: parameters).responseDecodable(of: T.self) { response in
            switch response.result {
            case .success(let data):
                completion(.success(data))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
