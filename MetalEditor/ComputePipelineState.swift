//
//  ComputePipelineState.swift
//  MetalEditor
//
//  Created by Litherum on 7/17/15.
//  Copyright © 2015 Litherum. All rights reserved.
//

import Foundation
import CoreData

class ComputePipelineState: NSManagedObject {
    private func validatePropertyIsUnique(name: String, value: AnyObject) throws {
        guard let context = managedObjectContext else {
            return
        }

        let fetchRequest = NSFetchRequest(entityName: "ComputePipelineState")
        fetchRequest.predicate = NSPredicate(format: "%K = %@", argumentArray: [name, value])
        var states: [ComputePipelineState] = []
        do {
            states = try context.executeFetchRequest(fetchRequest) as! [ComputePipelineState]
        } catch {
        }
        for state in states {
            if state != self {
                throw NSError(domain: "MetalEditorComputePipelineState", code: NSManagedObjectValidationError, userInfo: nil)
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
