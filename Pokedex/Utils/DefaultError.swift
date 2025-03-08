import Foundation

struct DefaultError: Error {
    let message: String
    
    init(_ message: String) {
        self.message = message
    }
}
