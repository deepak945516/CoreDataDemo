//
//  CoreDataManager.swift
//  PersonData
//
//  Created by Deepak Kumar on 05/08/19.
//  Copyright © 2019 Alok. All rights reserved.
//

import UIKit
import CoreData

enum CoreDataKeys: String {
    case containerName = "CoreDataDemo"
    case entityName = "Notes"
}

struct CoreDataManager {
    // MARK: - Properties
    var appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    /// Returns total entry count in a table
    func getTotalEntryCount(entityName: CoreDataKeys) -> Int {
        let managedObjectContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: entityName.rawValue)
        let totalEntryCount = (try? managedObjectContext.count(for: fetchRequest)) ?? 0
        return totalEntryCount
    }
    
    // MARK: - Save
    func save(entityName: String, dataDict: [String: Any], completion: @escaping ((NSManagedObject?) -> ())) {
        let managedObjectContext = appDelegate.persistentContainer.viewContext
        guard let entity = NSEntityDescription.entity(forEntityName: CoreDataKeys.entityName.rawValue, in: managedObjectContext) else { return }
        let note = NSManagedObject(entity: entity, insertInto: managedObjectContext)
        note.setValuesForKeys(dataDict)
        do {
            try managedObjectContext.save()
            debugPrint("Saved successfully")
            completion(note)
        } catch let error as NSError {
            debugPrint("Could not save. \(error), \(error.userInfo)")
            completion(nil)
        }
    }
    
    // MARK: - Fetch
    func fetch(isPaginationOn: Bool = false, pageSize: Int = 0, pageOffset: Int = 0, completion: @escaping (([NSManagedObject]?) -> ())) {
        let managedObjectContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: CoreDataKeys.entityName.rawValue)
        if isPaginationOn {
            fetchRequest.fetchLimit = pageSize
            fetchRequest.fetchOffset = pageOffset
        }
        do {
            let arrPerson = try managedObjectContext.fetch(fetchRequest)
            completion(arrPerson)
        } catch let error as NSError {
            debugPrint("Could not fetch. \(error), \(error.userInfo)")
            completion(nil)
        }
    }
    
    // MARK: - Update
    func update(dictData: [String: Any], note: NSManagedObject) {
        let managedObjectContext = appDelegate.persistentContainer.viewContext
        note.setValuesForKeys(dictData)
        do {
            try managedObjectContext.save()
        } catch let error as NSError  {
            debugPrint("Could not Update \(error), \(error.userInfo)")
        }
    }
    
    // MARK: - Delete
    func delete(time: Int) {
        let managedObjectContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: CoreDataKeys.entityName.rawValue)
        fetchRequest.predicate = NSPredicate(format: "\(NoteKeys.time.rawValue) == %d", time)
        do {
            let arrItem = try managedObjectContext.fetch(fetchRequest)
            arrItem.forEach { (managedObject) in
                managedObjectContext.delete(managedObject)
            }
            try managedObjectContext.save()
        } catch let error as NSError {
            debugPrint("Could not delete. \(error), \(error.userInfo)")
        }
    }
}
