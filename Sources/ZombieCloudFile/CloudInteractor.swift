import Foundation
import CloudKit

internal protocol Interactor {
    
    func record(for id: CKRecord.ID) async throws -> CKRecord
    func save(_ record: CKRecord) async throws -> CKRecord
    func deleteRecord(withID recordID: CKRecord.ID) async throws -> CKRecord.ID
    func records(for ids: [CKRecord.ID]) async throws -> [CKRecord.ID : Result<CKRecord, Error>]
    func modifyRecords(
        saving: [CKRecord],
        deleting: [CKRecord.ID]
    ) async throws -> (
        saveResults: [CKRecord.ID: Result<CKRecord, Error>],
        deleteResults: [CKRecord.ID: Result<Void, Error>]
    )
}

internal class CloudInteractor: Interactor {
    
    internal let container: CKContainer
    internal let database: CKDatabase
    internal let configuration: CKDatabaseOperation.Configuration
    
    public func record(for id: CKRecord.ID) async throws -> CKRecord {
        try await database.record(for: id)
    }
    
    public func save(_ record: CKRecord) async throws -> CKRecord {
        try await database.save(record)
    }

    public func deleteRecord(withID recordID: CKRecord.ID) async throws -> CKRecord.ID {
        try await database.deleteRecord(withID: recordID)
    }
    
    public init(containerIdentifier: String, databaseType: DatabaseType) {
        self.container = CKContainer(identifier: containerIdentifier)
        self.database = databaseType.database(from: container)
        self.configuration = CKDatabaseOperation.Configuration()
    }
    
    internal func records(for ids: [CKRecord.ID]) async throws -> [CKRecord.ID : Result<CKRecord, Error>] {
        try await database.records(for: ids)
    }
    
    internal func modifyRecords(
        saving: [CKRecord],
        deleting: [CKRecord.ID]
    ) async throws -> (
        saveResults: [CKRecord.ID: Result<CKRecord, Error>],
        deleteResults: [CKRecord.ID: Result<Void, Error>]
    ) {
        try await database.modifyRecords(saving: saving, deleting: deleting)
    }
}
