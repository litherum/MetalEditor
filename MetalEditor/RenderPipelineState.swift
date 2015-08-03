//
//  RenderPipelineState.swift
//  MetalEditor
//
//  Created by Litherum on 7/18/15.
//  Copyright © 2015 Litherum. All rights reserved.
//

import Foundation
import CoreData

class RenderPipelineState: NSManagedObject {
    // FIXME: Pull this out so it can be shared
    private func validatePropertyIsUnique(name: String, value: AnyObject) throws {
        guard let context = managedObjectContext else {
            return
        }

        let fetchRequest = NSFetchRequest(entityName: "RenderPipelineState")
        fetchRequest.predicate = NSPredicate(format: "%K = %@", argumentArray: [name, value])
        var states: [RenderPipelineState] = []
        do {
            states = try context.executeFetchRequest(fetchRequest) as! [RenderPipelineState]
        } catch {
        }
        for state in states {
            if state != self {
                throw NSError(domain: "MetalEditorRenderPipelineState", code: NSManagedObjectValidationError, userInfo: nil)
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
