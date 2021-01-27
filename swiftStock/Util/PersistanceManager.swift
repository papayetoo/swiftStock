//
//  PersistanceManager.swift
//  swiftStock
//
//  Created by 최광현 on 2021/01/20.
//

import Foundation
import CoreData

class PersistenceManager{
    static var shared : PersistenceManager = PersistenceManager()
    
    var persistanceContainer : NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Data")
        container.loadPersistentStores{ (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
        return container
    }()
    
    var context : NSManagedObjectContext {
        return self.persistanceContainer.viewContext
    }
    
    func fetch<T: NSManagedObject>(request: NSFetchRequest<T>) ->[T]{
        do{
            let fetchResult = try self.context.fetch(request)
            return fetchResult
        }catch {
            print(error)
            return []
        }
    }
    
    @discardableResult
    func delete(object: NSManagedObject) -> Bool{
        self.context.delete(object)
        do{
            try self.context.save()
            return true
        }catch{
            return false
        }
    }
    
    @discardableResult
    func deleteAll<T:NSManagedObject>(request: NSFetchRequest<T>) -> Bool{
        let request: NSFetchRequest<NSFetchRequestResult> = T.fetchRequest()
        let delete = NSBatchDeleteRequest(fetchRequest: request)
        do{
            try self.context.execute(delete)
            return true
        }catch{
            return false
        }
    }
}
