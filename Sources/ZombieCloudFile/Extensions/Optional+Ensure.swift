import Foundation

extension Optional {

    func ensure(_ failure: Error) throws -> Wrapped {
        guard case let .some(value) = self else { throw failure }
        return value
    }
}
