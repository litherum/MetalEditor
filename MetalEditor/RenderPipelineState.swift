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
    override func validateForInsert() throws {
        try super.validateForInsert()
        guard let context = managedObjectContext else {
            return
        }
        try validateUnique("RenderPipelineState", managedObjectContext: context, name: name, id: id, probe: self)
    }

    override func validateForUpdate() throws {
        try super.validateForUpdate()
        guard let context = managedObjectContext else {
            return
        }
        try validateUnique("RenderPipelineState", managedObjectContext: context, name: name, id: id, probe: self)
    }
}
