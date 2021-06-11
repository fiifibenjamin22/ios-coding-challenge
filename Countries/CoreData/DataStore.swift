//
//  DataStore.swift
//  Countries
//
//  Created by Syft on 04/03/2020.
//  Copyright © 2020 Syft. All rights reserved.
//

import CoreData
import Foundation
import INSPersistentContainer


public enum DataStoreError: Error {
    case invalidDataError(errorDescription: String)
}


extension DataStoreError: LocalizedError {
    
    public var errorDescription: String? {
        switch self {
        case .invalidDataError(let errorDescription):
            return errorDescription
        }
    }
    
}


class DataStore {

    public static let shared = DataStore()
    public var viewContext: NSManagedObjectContext { return persistentContainer.viewContext }
    fileprivate let dispatchGroup = DispatchGroup()
    fileprivate let dispatchQueue = DispatchQueue(label: "DataStore.dispatchQueue")

//    #if DEBUG
//    let mergePolicy: NSMergePolicy = NSMergePolicy(merge: .mergeByPropertyObjectTrumpMergePolicyType)
//    #else
    let mergePolicy: NSMergePolicy = NSMergePolicy(merge: .overwriteMergePolicyType)
//    #endif

    fileprivate lazy var persistentContainer: INSPersistentContainer = {
        
        let persistentContainer = INSPersistentContainer(name: "Countries")
        persistentContainer.loadPersistentStores() { (storeDescription: INSPersistentStoreDescription, error: Error?) in
            
            guard error != nil else {
                return
            }
            
            // destroy existing store
            DataStore.destroy()
            
            // try to load again...
            persistentContainer.loadPersistentStores() { (storeDescription: INSPersistentStoreDescription, error: Error?) in
                if let error = error as NSError? {
                    fatalError("Unresolved error \(error), \(error.userInfo)")
                }
            }
            
        }
        persistentContainer.viewContext.mergePolicy = self.mergePolicy
        persistentContainer.viewContext.ins_automaticallyMergesChangesFromParent = true
        
        return persistentContainer
    }()
     
    class func destroy() {
        try? FileManager.default.removeItem(at: INSPersistentContainer.defaultDirectoryURL().appendingPathComponent("Countries.sqlite"))
        try? FileManager.default.removeItem(at: INSPersistentContainer.defaultDirectoryURL().appendingPathComponent("Countries.sqlite-shm"))
        try? FileManager.default.removeItem(at: INSPersistentContainer.defaultDirectoryURL().appendingPathComponent("Countries.sqlite-wal"))
    }
    
    
    /// Creartes a private managed object context.
    ///
    /// - returns: A newly created private managed object context.
    public func newBackgroundContext() -> NSManagedObjectContext {
        let managedObjectContext = persistentContainer.newBackgroundContext()
        managedObjectContext.mergePolicy = mergePolicy
        managedObjectContext.ins_automaticallyMergesChangesFromParent = true
        
        return managedObjectContext
    }
    
    
    /// Creartes a main queue managed object context.
    ///
    /// - returns: A newly created private managed object context.
    public func newViewContext() -> NSManagedObjectContext {
      
        let managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        managedObjectContext.mergePolicy = mergePolicy

        if viewContext.parent != nil {
            managedObjectContext.parent = viewContext.parent
        } else {
            managedObjectContext.persistentStoreCoordinator = self.persistentContainer.persistentStoreCoordinator
        }
        
        managedObjectContext.ins_automaticallyMergesChangesFromParent = true
        
        return managedObjectContext
    }
    

    /// Causes the persistent container to execute the block against a new private queue context.
    ///
    /// - Parameters:
    ///     - block: A block that is executed by the persistent container against a newly created private context. The private context is passed into the block as part of the execution of the block.
    func performBackgroundTask( _ block: @escaping (NSManagedObjectContext) -> Swift.Void ) {
        
        dispatchQueue.async {
            self.dispatchGroup.wait()
            self.dispatchGroup.enter()

            self.persistentContainer.performBackgroundTask { (managedObjectContext: NSManagedObjectContext) in
                managedObjectContext.mergePolicy = self.mergePolicy
                managedObjectContext.ins_automaticallyMergesChangesFromParent = true

                block(managedObjectContext)
                
                self.dispatchGroup.leave()
            }
        }
    }
    
    
    /// Returns a copy of the fetch request template with the variables substituted by values from the substitutions dictionary.
    ///
    /// - Parameters:
    ///   - name: A string containing the name of a fetch request template.
    ///   - variables: A dictionary containing key-value pairs where the keys are the names of variables specified in the template; the corresponding values are substituted before the fetch request is returned. The dictionary must provide values for all the variables in the template.
    /// - Returns: A copy of the fetch request template with the variables substituted by values from variables.
    func fetchRequestFromTemplate<T: NSFetchRequestResult>(withName name: String, substitutionVariables variables: [String : Any]? = nil) -> NSFetchRequest<T>? {
        let fetchRequest = persistentContainer.managedObjectModel.fetchRequestFromTemplate(withName: name, substitutionVariables: variables ?? [String : Any]()) as? NSFetchRequest<T>
        fetchRequest?.includesSubentities = false

        return fetchRequest
    }
    
}

/*
 protocol DatabaseCRUDProtocol {
     var managedObjectContext: NSManagedObjectContext { get }
     
     func insert<T: NSManagedObject>(object: T) throws
     func fetchObjects<T: NSManagedObject>(usingFetchRequest request: NSFetchRequest<T>) throws -> [T]
     func delete<T: NSManagedObject>(objects: [T]) throws
 }

 final class DatabaseController {
     
     // MARK: - Properties
     
     private let persistentContainer: NSPersistentContainer = NSPersistentContainer(name: "ParlorDatabaseModel")
     
     // MARK: - Init
     
     init() {
         setupPersistentContainer()
     }
     
     // MARK: - Private methods
     
     private func setupPersistentContainer() {
         persistentContainer.loadPersistentStores { _, error in
             if let error = error as NSError? {
                 fatalError("Can't loadPersistentStores: \(error), \(error.userInfo)")
             }
         }
     }
 }

 // MARK: - CRUD

 extension DatabaseController: DatabaseCRUDProtocol {
     var managedObjectContext: NSManagedObjectContext {
         return persistentContainer.viewContext
     }
     
     func insert<T: NSManagedObject>(object: T) throws {
         managedObjectContext.insert(object)
         try managedObjectContext.save()
     }

     func fetchObjects<T: NSManagedObject>(usingFetchRequest request: NSFetchRequest<T>) throws -> [T] {
         let objects = try managedObjectContext.fetch(request)
         return objects
     }
     
     func delete<T: NSManagedObject>(objects: [T]) throws {
         objects.forEach { managedObjectContext.delete($0) }
         try managedObjectContext.save()
     }
 }

 
 //Usage
 func fetchAllEvents() -> [AnalyticEventEntity] {
     do {
         return try database.fetchObjects(usingFetchRequest: AnalyticEventEntity.fetchRequest())
     } catch {
         logError(error, message: "Can't fetch analytic events")
         return []
     }
 }
 */
