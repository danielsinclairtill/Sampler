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
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    }

    func get<R: RequestStoreGetContract>(_ request: R) async throws -> R.Data? {
        let context = container.viewContext
        return try await context.perform {
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: R.Data.enitityName)
            fetchRequest.predicate = NSPredicate(format: "id == %@", request.id as CVarArg)

            let results = try context.fetch(fetchRequest)

            guard !results.isEmpty else { return nil }
            guard let dataCD = results.first as? R.Data.CD else { throw StoreError.readError }
            return R.Data.convertFromCD(dataCD)
        }
    }

    func getList<R: RequestStoreGetListContract>(_ request: R) async throws -> R.DataList {
        let context = container.viewContext
        return try await context.perform {
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: R.Data.enitityName)
            let results = try context.fetch(fetchRequest)

            guard !results.isEmpty else { return R.DataList() }
            guard let dataCD = results as? [R.Data.CD] else { throw StoreError.readError }
            let data = dataCD.map { R.Data.convertFromCD($0) }
            guard let dataList = data as? R.DataList else { throw StoreError.readError }
            return dataList
        }
    }

    func store<R: RequestStoreStoreContract>(_ request: R) async throws -> R.Data {
        let context = container.newBackgroundContext()
        context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy

        try await context.perform {
            _ = request.data.convertToCD(context: context)
            try context.save()
        }

        // Post on main actor — context.perform resumes on the caller's executor,
        // so annotate your call site with @MainActor or wrap explicitly:
        await MainActor.run {
            NotificationCenter.default.post(name: .itemDidUpdate, object: request.data)
        }
        
        return request.data
    }

    func wipe() async throws {
        let context = container.newBackgroundContext()
        var deletedIDs: [NSManagedObjectID] = []

        try await context.perform {
            guard let entities = context.persistentStoreCoordinator?.managedObjectModel.entities else { return }

            for entity in entities {
                guard let name = entity.name else { continue }

                let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: name)
                let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
                deleteRequest.resultType = .resultTypeObjectIDs

                // NSBatchDeleteRequest bypasses the context — executes directly on the store
                let result = try context.execute(deleteRequest) as? NSBatchDeleteResult
                if let objectIDs = result?.result as? [NSManagedObjectID] {
                    deletedIDs.append(contentsOf: objectIDs)
                }
            }
        }

        // Merge batch delete changes into the view context after the perform block completes
        NSManagedObjectContext.mergeChanges(
            fromRemoteContextSave: [NSDeletedObjectsKey: deletedIDs],
            into: [container.viewContext]
        )
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
