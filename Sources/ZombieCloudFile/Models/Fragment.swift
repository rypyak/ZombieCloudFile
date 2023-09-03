import CloudKit

internal class Fragment {

	internal let record: CKRecord

	private var dataKey: String { "data" }

	init(record: CKRecord) {
		self.record = record
	}

    var id: CKRecord.ID {
		get { record.recordID }
	}

	var data: Data? {
		get { record[dataKey] as? Data }
		set { record[dataKey] = newValue }
	}

	func withData(_ data: Data) -> Self {
		self.data = data
		return self
	}
}
