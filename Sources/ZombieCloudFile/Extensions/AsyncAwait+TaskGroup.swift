import Foundation

@discardableResult
internal func withThrowingTaskArrayGroup<Input, Output>(_ inputs: [Input], by transform: @escaping (Input) async throws -> Output) async throws -> [Output] {
	try await withThrowingTaskGroup(of: (Int, Output).self, returning: [Output].self) { group in
		var outputs = inputs.map { _ in Output?.none }
		for (offset, input) in inputs.enumerated() {
			group.addTask { (offset, try await transform(input)) }
		}

		for try await (offset, output) in group {
			outputs[offset] = output
		}

		return outputs.compactMap { $0 }
	}
}

@discardableResult
internal func withTaskArrayGroup<Input, Output>(_ inputs: [Input], by transform: @escaping (Input) async -> Output) async -> [Output] {
	await withTaskGroup(of: (Int, Output).self, returning: [Output].self) { group in
		var outputs = inputs.map { _ in Output?.none }
		for (offset, input) in inputs.enumerated() {
			group.addTask { (offset, await transform(input)) }
		}

		for await (offset, output) in group {
			outputs[offset] = output
		}

		return outputs.compactMap { $0 }
	}
}
