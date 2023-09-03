import CloudKit

internal extension CKRecord.RecordType {

	static func entry(name: String) -> Self {
		"\(name)Entry"
	}

	static func fragment(name: String) -> Self {
		"\(name)Fragment"
	}
}
