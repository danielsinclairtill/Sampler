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
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: R.Data.enitityName)
        // Predicate: "WHERE id equals the id I passed in"
        fetchRequest.predicate = NSPredicate(format: "id == %@", request.id as CVarArg)

        // perform store read on asynchronous thread, completion is called on main thread
        let asyncRequest = NSAsynchronousFetchRequest(fetchRequest: fetchRequest) { results in
            if let results = results.finalResult {
                guard !results.isEmpty else {
                    result?(.failure(StoreError.empty))
                    return
                }
                guard let dataCD = results.first as? R.Data.CD else {
                    result?(.failure(StoreError.readError))
                    return
                }
                let data: R.Data = R.Data.convertFromCD(dataCD)
                result?(.success(data))
            }
        }
        do {
            try container.viewContext.execute(asyncRequest)
        } catch {
            result?(.failure(StoreError.readError))
        }
    }
    
    func getList<R>(_ request: R,
                    result: ((Result<R.DataList, StoreError>) -> Void)?) where R : RequestStoreGetListContract {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: R.Data.enitityName)
        // perform store read on asynchronous thread, completion is called on main thread
        let asyncRequest = NSAsynchronousFetchRequest(fetchRequest: fetchRequest) { results in
            if let results = results.finalResult {
                guard let dataCD = results as? [R.Data.CD] else {
                    result?(.failure(StoreError.readError))
                    return
                }
                let data = dataCD.map { R.Data.convertFromCD($0) }
                if let data = data as? R.DataList {
                    result?(.success(data))
                } else {
                    result?(.failure(StoreError.readError))
                }
            }
        }
        do {
            try container.viewContext.execute(asyncRequest)
        } catch {
            result?(.failure(StoreError.readError))
        }
    }
    
    func store<R>(_ request: R, result: ((Result<Void, StoreError>) -> Void)?) where R : RequestStoreStoreContract {
        // perform store write on asynchronous thread
        container.performBackgroundTask { context in
            // data
            let _ = request.data.convertToCD(context: context)

            do {
                try context.save()
                // call on main thread
                DispatchQueue.main.async {
                    result?(.success(()))
                }
            } catch {
                DispatchQueue.main.async {
                    result?(.failure(StoreError.writeError))
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
