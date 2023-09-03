import XCTest
@testable import ZombieCloudFile

final class DataFragmentationTests: XCTestCase {

	func test_Data_from_fragments_of_equal_size() {
			// Given
		let fragments = [
			Data(count: 8),
			Data(count: 8),
			Data(count: 8),
			Data(count: 8)
		]

			// When
		measure {
			let data = Data(from: fragments)

				// Then
			XCTAssertFalse(data.isEmpty)
			XCTAssertEqual(data.count, 32)
		}
	}

	func test_Data_from_fragments_of_unequal_size() {
			// Given
		let fragments = [
			Data(count: 8),
			Data(count: 8),
			Data(count: 8),
			Data(count: 8),
			Data(count: 3)
		]

			// When
		measure {
			let data = Data(from: fragments)

				// Then
			XCTAssertFalse(data.isEmpty)
			XCTAssertEqual(data.count, 35)
		}
	}

	func test_Data_fragments_of_equal_size() async throws {
			// Given
		let mockData = Data(count: 32)
		measure {
				// When
			let fragments = mockData.fragments(ofSize: 8)

				// Then
			XCTAssertEqual(fragments.count, 4)
			XCTAssertFalse(fragments.isEmpty)
			XCTAssertFalse(fragments.contains { $0.count != 8 })
			XCTAssertEqual(fragments[0].count, 8)
			XCTAssertEqual(fragments[1].count, 8)
			XCTAssertEqual(fragments[2].count, 8)
			XCTAssertEqual(fragments[3].count, 8)
		}
	}

	func test_Data_fragments_of_unequal_size() async throws {
			// Given
		let mockData = Data(count: 41)
		measure {
				// When
			let fragments = mockData.fragments(ofSize: 10)

				// Then
			XCTAssertFalse(fragments.isEmpty)
			XCTAssertEqual(fragments.count, 5)
			XCTAssertEqual(fragments[0].count, 10)
			XCTAssertEqual(fragments[1].count, 10)
			XCTAssertEqual(fragments[2].count, 10)
			XCTAssertEqual(fragments[3].count, 10)
			XCTAssertEqual(fragments[4].count, 1)
		}
	}
}
