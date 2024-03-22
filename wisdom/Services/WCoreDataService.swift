//
//  WCoreDataService.swift
//  wisdom
//
//  Created by cipher on 09.09.2022.
//

import CoreData

/// Main service for simple atomic operations with CoreData stack. This service should be in single instance only for all application
protocol WCoreDataServiceProtocol {
    
    /// creates and provides local context object for operation in asynchronous mode
    /// - Parameter completionHandler: block will be launched after the local context is created, local context will be put to this block as parameter
    func asyncExecute() async -> NSManagedObjectContext

    /// Saves root context, as a matter of fact saves all the data in root context to persistent storage
    func saveRootContext()

}

class WCoreDataService: WCoreDataServiceProtocol {

    private lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "wisdom")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        
        return container
    }()

    //  MARK: - WCoreDataServiceProtocol -
    
    func asyncExecute() async -> NSManagedObjectContext {
        return await withCheckedContinuation { continuation in
            persistentContainer.performBackgroundTask { localContext in
                continuation.resume(with: .success(localContext))
            }
        }
    }

    func saveRootContext() {
        persistentContainer.viewContext.wisdom_saveContext()
    }

}
