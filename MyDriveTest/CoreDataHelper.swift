//
//  CoreDataHelper.swift
//  MyDriveTest
//
//  Created by galmarom on 11/11/2016.
//  Copyright © 2016 galmarom. All rights reserved.
//
import UIKit
import CoreData

class CoreDataHelper: NSObject {
    
    static let sharedInstance = CoreDataHelper()

    lazy var managedObjectModel: NSManagedObjectModel = {
        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
        let modelURL = Bundle.main.url(forResource: "ExchangeRatesModel", withExtension: "momd")!
        return NSManagedObjectModel(contentsOf: modelURL)!
    }()
    
    //The persistant store for the application
    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator? = {
        var coordinator: NSPersistentStoreCoordinator? = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let storeUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("ExchangeRates.sqlite")
        do {
            try coordinator!.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: storeUrl, options: nil)
        }catch{
            coordinator = nil
            print("There was an error creating or loading the application's saved data.")
        }
        // TODO:: Add light migration support
        return coordinator
    }()
    
    /**
     Returns: The managedObjectContext that is already bout to the persistant store coordinator.
    */
    lazy var managedObjectContext: NSManagedObjectContext? = {
        let coordinator = self.persistentStoreCoordinator
        if coordinator == nil {
            return nil
        }
        var managedObjectContext = NSManagedObjectContext(concurrencyType: NSManagedObjectContextConcurrencyType.mainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
    }()
    
    func deleteObject(_ managedObject : NSManagedObject){
        self.managedObjectContext?.delete(managedObject)
    }
    
    // MARK: - Core Data Saving support
    func saveContext () {
        if let moc = self.managedObjectContext {
            if moc.hasChanges{
                do {
                    try moc.save()
                }catch {
                    print("Unresolved error \(error), \(error.localizedDescription)")
                }
            }
        }
    }
}
