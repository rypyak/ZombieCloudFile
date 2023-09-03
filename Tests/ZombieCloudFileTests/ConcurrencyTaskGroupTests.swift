import Foundation
import XCTest
@testable import ZombieCloudFile

class ConcurrencyTaskGroupTests: XCTestCase {
    
    var durationRangeMS: ClosedRange<Int>!
    var durationThreshold: TimeInterval!
    var tasks: [() async -> Void]!
    
    override func setUpWithError() throws {
        durationRangeMS = 10...50
        durationThreshold = Double(durationRangeMS.upperBound) / 1000 * 1.1
        let maxDurationTask: () async -> Void = {
            try! await Task.sleep(for: Duration.milliseconds(self.durationRangeMS.upperBound))
        }
        let randomDurationTask: () async -> Void = {
            try! await Task.sleep(for: Duration.milliseconds(self.durationRangeMS.randomElement() ?? self.durationRangeMS.upperBound))
        }
        tasks = [maxDurationTask] + ((1...10).map { _ in randomDurationTask })
    }
    
    override func tearDownWithError() throws {
        durationRangeMS = nil
        durationThreshold = nil
        tasks = nil
    }

    func testWithTaskArrayGroup() async {
        let start = Date()
        
        await withTaskArrayGroup(tasks) { task in
            await task()
        }
        
        let executionTime = Date().timeIntervalSince(start)
        XCTAssertLessThan(executionTime, durationThreshold)
    }
    
    func testWithThrowingTaskArrayGroup() async throws {
        let start = Date()
        
        try await withThrowingTaskArrayGroup(tasks) { task in
            await task()
        }
        
        let executionTime = Date().timeIntervalSince(start)
        XCTAssertLessThan(executionTime, durationThreshold)
    }
}

