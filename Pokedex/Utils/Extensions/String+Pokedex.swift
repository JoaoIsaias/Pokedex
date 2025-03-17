import Foundation

extension String {
    func containsRegex(_ pattern: String) -> Bool {
        return self.range(of: pattern, options: .regularExpression) != nil
    }
}
