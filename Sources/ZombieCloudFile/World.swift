import Foundation

#if TEST
internal let Current = World()
#else
internal var Current = World()
#endif

internal struct World {

	var cloudInteractor: (String, DatabaseType) -> Interactor = { containerIdentifier, databaseType in
		CloudInteractor(containerIdentifier: containerIdentifier, databaseType: databaseType)
	}
}

