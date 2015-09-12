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
        try validatePropertyIsUnique("RenderPipelineState", managedObjectContext: managedObjectContext!, name: "name", value: name, probe: self)
    }

    override func validateForUpdate() throws {
        try super.validateForUpdate()
        try validatePropertyIsUnique("RenderPipelineState", managedObjectContext: managedObjectContext!, name: "name", value: name, probe: self)
    }
}
