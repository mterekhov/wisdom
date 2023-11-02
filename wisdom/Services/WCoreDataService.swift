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
    func asyncExecute(_ completionHandler: @escaping ((NSManagedObjectContext) -> Void))
    
    /// creates and provides local context in sync mode
    /// - Parameter completionHandler: block which will launched after the local context is created
    func execute(_ completionHandler: ((NSManagedObjectContext) -> Void))

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
    
    func asyncExecuteEx<T>(_ completionHandler: @escaping ((NSManagedObjectContext) -> T)) async -> T {
//        guard let persistentContainer = persistentContainer else {
//            return
//        }
//        
        return await persistentContainer.performBackgroundTask(completionHandler)
    }
    
    func asyncExecute(_ completionHandler: @escaping ((NSManagedObjectContext) -> Void)) {
//        guard let persistentContainer = persistentContainer else {
//            return
//        }
        persistentContainer.performBackgroundTask(completionHandler)
    }
    
    func execute(_ completionHandler: ((NSManagedObjectContext) -> Void)) {
//        guard let persistentContainer = persistentContainer else {
//            return
//        }
        let localContext = persistentContainer.newBackgroundContext()
        localContext.performAndWait {
            completionHandler(localContext)
        }
    }
    
    func saveRootContext() {
//        guard let persistentContainer = self.persistentContainer else {
//            return
//        }
//        
        persistentContainer.viewContext.wisdom_saveContext()
    }

}
