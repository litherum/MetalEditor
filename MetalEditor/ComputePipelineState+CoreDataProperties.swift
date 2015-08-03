//
//  ComputePipelineState+CoreDataProperties.swift
//  MetalEditor
//
//  Created by Litherum on 7/17/15.
//  Copyright © 2015 Litherum. All rights reserved.
//
//  Delete this file and regenerate it using "Create NSManagedObject Subclass…"
//  to keep your implementation up to date with your model.
//

import Foundation
import CoreData

extension ComputePipelineState {

    @NSManaged var id: NSNumber
    @NSManaged var functionName: String
    @NSManaged var invocations: NSSet?
    @NSManaged var name: String

}
