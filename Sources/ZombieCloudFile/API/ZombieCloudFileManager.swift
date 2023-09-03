import Foundation
import CloudKit

/// A `ZombieCloudFileManager` allows asynchronous reading, writing, deleting of virtual `Data` files stored in selected iCloud Database.
///
/// It does not use `CKAsset` and therefore does not require existence of files in your directories to operate on `Data` in the cloud.
///
/// To prevent `CKRecord`'s `1MB` limit the value may be fragmented and saved
/// into multiple records following this example:
/// ```
///  - File1- (3.8 MB)
///   - File1Fragment1 - 0.5 MB
///   - File1Fragment2 - 0.5 MB
///   - File1Fragment3 - 0.5 MB
///   - File1Fragment4 - 0.5 MB
///   - File1Fragment5 - 0.5 MB
///   - File1Fragment6 - 0.5 MB
///   - File1Fragment7 - 0.2 MB
///  - File2 - (0.3 MB)
///   - File2Fragment1 - 0.3 MB
/// ```
/// Keep in mind that while this circumvents the limitation it slows down the execution as multiple
/// CKRecords have to be retrieved from user's iCloud.
/// 
public class ZombieCloudFileManager {
    
    // MARK: - Properties
    // MARK: Public
    public let databaseType: DatabaseType
    public let containerIdentifier: String
    public let fragmentSize: Int
    // MARK: Internal
    internal let cloud: Interactor
    
    // MARK: - Methods
    // MARK: Public
    public init(
        containerIdentifier: String,
        databaseType: DatabaseType = .privateCloudDatabase,
        fragmentSize: Int = 512_0000
    ) {
        self.containerIdentifier = containerIdentifier
        self.databaseType = databaseType
        self.fragmentSize = fragmentSize
        self.cloud = Current.cloudInteractor(containerIdentifier, databaseType)
    }
    
    public func write(_ data: Data, to filename: String) async throws {
        let entry = try await fetchEntry(with: filename)
        guard entry.isEmpty else { throw ZCFError.full }
        let dataFragments = data.fragments(ofSize: fragmentSize)
        entry.fragments = dataFragments.count
        let fragments = zip(fragmentSlotIDs(for: entry), dataFragments).map { id, data in
            let newRecord = CKRecord(recordType: .fragment(name: filename), recordID: id)
            let fragment = Fragment(record: newRecord)
            fragment.data = data
            return fragment
        }
        let recordsBatch = fragments.map { $0.record } + [entry.record]
        let results = try await cloud.modifyRecords(saving: recordsBatch, deleting: [])
        try ensureSuccess(of: results.saveResults)
    }
    
    public func read(from filename: String) async throws -> Data {
        let entry = try await fetchEntry(with: filename)
        guard !entry.isEmpty else { throw ZCFError.empty }
        let fragments = try await fetchFragments(with: fragmentSlotIDs(for: entry))
        let fragmentsData = try fragments.map { try $0.data.ensure(ZCFError.corrupted) }
        let data = Data(from: fragmentsData)
        return data
    }
    
    public func delete(at filename: String) async throws {
        let entry = try await fetchEntry(with: filename)
        let idsBatch = fragmentSlotIDs(for: entry) + [entry.id]
        let results = try await cloud.modifyRecords(saving: [], deleting: idsBatch)
        try ensureSuccess(of: results.deleteResults)
    }
    
    // MARK: Internal
    internal func fetchEntry(with filename: String) async throws -> Entry {
        do {
            let record = try await cloud.record(for: entrySlotID(for: filename))
            return Entry(record: record)
        } catch let error as CKError where error.code == .unknownItem {
            return Entry(
                record: CKRecord(
                    recordType: .entry(name: filename),
                    recordID: .entry(name: filename)
                )
            )
        }
    }
    
    internal func fetchFragments(with ids: [CKRecord.ID]) async throws -> [Fragment] {
        try await cloud.records(for: ids).map { Fragment(record: try $0.value.get()) }
    }
    
    internal func ensureSuccess(of results: [CKRecord.ID: Result<CKRecord, Error>]) throws {
        try results.values.forEach { try $0.ensure() }
    }
    
    internal func ensureSuccess(of results: [CKRecord.ID: Result<Void, Error>]) throws {
        try results.values.forEach { try $0.ensure() }
    }
    
    internal func entrySlotID(for filename: String) -> CKRecord.ID {
        CKRecord.ID.entry(name: filename)
    }
    
    internal func fragmentSlotIDs(for entry: Entry) -> [CKRecord.ID] {
        (1...entry.fragments).map { number in
            CKRecord.ID.fragment(entry: entry, number: number)
        }
    }
}
