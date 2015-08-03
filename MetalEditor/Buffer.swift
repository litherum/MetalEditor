//
//  Buffer.swift
//  MetalEditor
//
//  Created by Litherum on 7/17/15.
//  Copyright © 2015 Litherum. All rights reserved.
//

import Foundation
import CoreData

class Buffer: NSManagedObject {
    private func validatePropertyIsUnique(name: String, value: AnyObject) throws {
        guard let context = managedObjectContext else {
            return
        }

        let fetchRequest = NSFetchRequest(entityName: "Buffer")
        fetchRequest.predicate = NSPredicate(format: "%K = %@", argumentArray: [name, value])
        var buffers: [Buffer] = []
        do {
            buffers = try context.executeFetchRequest(fetchRequest) as! [Buffer]
        } catch {
        }
        for buffer in buffers {
            if buffer != self {
                throw NSError(domain: "MetalEditorBuffer", code: NSManagedObjectValidationError, userInfo: nil)
            }
        }
    }

    private func validateUnique() throws {
        try validatePropertyIsUnique("name", value: name)
        try validatePropertyIsUnique("id", value: id)
    }
    

    override func validateForInsert() throws {
        try super.validateForInsert()
        try validateUnique()
    }

    override func validateForUpdate() throws {
        try super.validateForUpdate()
        try validateUnique()
    }
}
