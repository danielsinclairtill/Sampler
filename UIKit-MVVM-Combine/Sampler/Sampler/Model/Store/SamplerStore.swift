//
//  SamplerStore.swift
//  Sampler
//
//  Created by Daniel on 2026-01-30.
//

import Foundation
import CoreData
import UIKit

class SamplerStore: StoreContract {
    private let container: NSPersistentContainer
    
    init(container: NSPersistentContainer) {
        self.container = container
        // merge changes from parent for async store processes to work correctly
        container.viewContext.automaticallyMergesChangesFromParent = true
        // update existing records over
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    }
    
    func get<R>(_ request: R, result: ((Result<R.Data, StoreError>) -> Void)?) where R : RequestStoreGetContract {
        func completion(_ finalResult: Result<R.Data, StoreError>) {
            DispatchQueue.main.async {
                result?(finalResult)
            }
        }
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: R.Data.enitityName)
        // Predicate: "WHERE id equals the id I passed in"
        fetchRequest.predicate = NSPredicate(format: "id == %@", request.id as CVarArg)

        // perform store read on asynchronous thread, completion is called on main thread
        let asyncRequest = NSAsynchronousFetchRequest(fetchRequest: fetchRequest) { results in
            if let results = results.finalResult {
                guard !results.isEmpty else {
                    completion(.failure(StoreError.empty))
                    return
                }
                guard let dataCD = results.first as? R.Data.CD else {
                    completion(.failure(StoreError.readError))
                    return
                }
                let data: R.Data = R.Data.convertFromCD(dataCD)
                completion(.success(data))
            }
        }
        do {
            try container.viewContext.execute(asyncRequest)
        } catch {
            completion(.failure(StoreError.readError))
        }
    }
    
    func getList<R>(_ request: R,
                    result: ((Result<R.DataList, StoreError>) -> Void)?) where R : RequestStoreGetListContract {
        func completion(_ finalResult: Result<R.DataList, StoreError>) {
            DispatchQueue.main.async {
                result?(finalResult)
            }
        }
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: R.Data.enitityName)
        // perform store read on asynchronous thread, completion is called on main thread
        let asyncRequest = NSAsynchronousFetchRequest(fetchRequest: fetchRequest) { results in
            if let results = results.finalResult {
                guard let dataCD = results as? [R.Data.CD] else {
                    completion(.failure(StoreError.readError))
                    return
                }
                let data = dataCD.map { R.Data.convertFromCD($0) }
                if let data = data as? R.DataList {
                    completion(.success(data))
                } else {
                    completion(.failure(StoreError.readError))
                }
            }
        }
        do {
            try container.viewContext.execute(asyncRequest)
        } catch {
            completion(.failure(StoreError.readError))
        }
    }
    
    func store<R>(_ request: R, result: ((Result<Void, StoreError>) -> Void)?) where R : RequestStoreStoreContract {
        func completion(_ finalResult: Result<Void, StoreError>) {
            DispatchQueue.main.async {
                result?(finalResult)
            }
        }
        
        // perform store write on asynchronous thread
        container.performBackgroundTask { context in
            context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
            // data
            let _ = request.data.convertToCD(context: context)
            
            do {
                try context.save()
                // call on main thread
                completion(.success(()))
                NotificationCenter.default.post(name: .itemDidUpdate, object: request.data)
            } catch {
                completion(.failure(StoreError.writeError))
            }
        }
    }
    
    
    func wipe(result: ((Result<Void, StoreError>) -> Void)?) {
        container.performBackgroundTask { context in
            guard let entities = context.persistentStoreCoordinator?.managedObjectModel.entities else { return }
            context.performAndWait { [weak self] in
                guard let self else { return }
                // Loop through every entity in your model
                for entity in entities {
                    guard let name = entity.name else { continue }
                    
                    let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: name)
                    let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
                    
                    // Optional: Specify result type if you need the count
                    deleteRequest.resultType = .resultTypeObjectIDs
                    
                    do {
                        // Execute the delete
                        let executeResult = try context.execute(deleteRequest) as? NSBatchDeleteResult
                        
                        // Important: Batch deletes happen on disk, so we must
                        // merge changes back into memory if other contexts are active
                        if let objectIDs = executeResult?.result as? [NSManagedObjectID] {
                            NSManagedObjectContext.mergeChanges(
                                fromRemoteContextSave: [NSDeletedObjectsKey: objectIDs],
                                into: [self.container.viewContext]
                            )
                        }
                        DispatchQueue.main.async {
                            result?(.success(()))
                        }
                    } catch {
                        DispatchQueue.main.async {
                            result?(.failure(.writeError))
                        }
                    }
                }
            }
        }
    }
}

extension SamplerStore {
    static func persistentContainer() -> NSPersistentContainer {
        let container = NSPersistentContainer(name: "SamplerModel")
        container.loadPersistentStores { (storeDescription, error) in
            if let error = error as NSError? {
                assertionFailure("Unresolved error \(error), \(error.userInfo)")
            }
        }
        return container
    }
}
