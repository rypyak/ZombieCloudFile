import Foundation

extension Result {

	@discardableResult
	func ensure() throws -> Success {
		try get()
	}
}
