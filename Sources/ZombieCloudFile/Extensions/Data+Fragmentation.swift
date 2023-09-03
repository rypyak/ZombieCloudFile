import Foundation

extension Data {

	init(from fragments: [Data]) {
		let capacity = fragments.reduce(0) { $0 + $1.count }
		self = Data(capacity: capacity)
		for fragment in fragments {
			self.append(fragment)
		}
	}

	internal func fragments(ofSize fragmentSize: Int) -> [Data] {
		var total: Data = self
		var fragments: [Data] = []
		repeat {
			let fragmentRange = 0..<Swift.min(total.count, fragmentSize)
			let fragment = total.subdata(in: fragmentRange)
			guard fragment.count != 0 else { return fragments }
			let remainderRange = fragmentRange.upperBound..<total.count
			total = total.subdata(in: remainderRange)
			fragments.append(fragment)
		} while total.count > 0
		return fragments
	}
}
