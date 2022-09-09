//
//  NSManagedObjectContext+Wisdom.swift
//  Wisdom
//
//  Created by teremalex on 15.06.2020.
//

import CoreData

extension NSManagedObjectContext {
    
    /// Simple wrapper to save context
    public func wisdom_saveContext() {
        if !hasChanges {
            return
        }
        
        do {
            try save()
        }
        catch let error {
            print(error)
            return
        }
    }
    
}
