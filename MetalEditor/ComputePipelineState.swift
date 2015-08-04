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
    override func validateForInsert() throws {
        try super.validateForInsert()
        guard let context = managedObjectContext else {
            return
        }
        try validateUnique("ComputePipelineState", managedObjectContext: context, name: name, id: id, probe: self)
    }

    override func validateForUpdate() throws {
        try super.validateForUpdate()
    }
}
