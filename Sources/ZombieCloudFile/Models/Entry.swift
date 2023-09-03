import CloudKit

internal final class Entry {

	internal let record: CKRecord

	private var fragmentsKey: String { "fragments" }

	init(record: CKRecord) {
		self.record = record
	}

    var id: CKRecord.ID {
        get { record.recordID }
	}

	var fragments: Int {
		get { record[fragmentsKey] as? Int ?? 0 }
		set { record[fragmentsKey] = newValue }
	}
    
    var isEmpty: Bool {
        fragments == 0
    }

	var modificationDate: Date? {
		get { record.modificationDate }
	}

	var creationDate: Date? {
		get { record.creationDate }
	}
}
