import CloudKit

public enum DatabaseType {
	case privateCloudDatabase, publicCloudDatabase, sharedCloudDatabase

	internal func database(from container: CKContainer) -> CKDatabase {
		switch self {
		case .privateCloudDatabase:
			return container.privateCloudDatabase
		case .publicCloudDatabase:
			return container.publicCloudDatabase
		case .sharedCloudDatabase:
			return container.sharedCloudDatabase
		}
	}
}
