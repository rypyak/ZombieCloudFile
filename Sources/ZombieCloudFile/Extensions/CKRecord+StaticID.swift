import CloudKit

internal extension CKRecord.ID {

    static func entry(name: String) -> CKRecord.ID {
        CKRecord.ID(recordName: "\(name)Entry")
    }

    static func fragment(entry: Entry, number: Int) -> CKRecord.ID {
        CKRecord.ID(recordName: "\(entry.id.recordName)Fragment\(number)")
    }
}
