//
//  CountryDataCOntroller.swift
//  Countries
//
//  Created by Benjamin Acquah on 09/06/2021.
//  Copyright © 2021 James Weatherley. All rights reserved.
//

import UIKit
import CoreData

class CountryDataController: NSObject {
    
    static let sharedinstance: CountryDataController = {
        let instance = CountryDataController()
        return instance
    }()
    
    public lazy var fetchedResultsController: NSFetchedResultsController<Country> = {
        
        // Initialize Fetch Request
        let fetchRequest:NSFetchRequest<Country> = Country.fetchRequest()
    
        // Add sort descriptor
        let sortDescriptor = NSSortDescriptor(key: "region", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        // Initialize Fetched Results Controller
        let fetchedResultsController = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: DataStore.shared.newViewContext(),
            sectionNameKeyPath: nil,
            cacheName: nil)
        
        return fetchedResultsController
    }()

    var fetchedItems:Array<Country> {
        get {
            return fetchedResultsController.fetchedObjects ?? [Country]()
        }
    }
    
    override init() {
        super.init()
        // Execute initial fetch command
        try? executeFetch()
    }
        
    public func executeFetch() throws {
        
        // Perform fetch
        do {
            try self.fetchedResultsController.performFetch()
        } catch {
            let fetchError = error as NSError
            print("Unable to Perform Fetch Request")
            print("\(fetchError), \(fetchError.localizedDescription)")
        }
    }
}
