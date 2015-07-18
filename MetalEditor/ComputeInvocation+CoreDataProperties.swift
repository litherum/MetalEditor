//
//  ComputeInvocation+CoreDataProperties.swift
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

extension ComputeInvocation {

    @NSManaged var bufferBindings: NSOrderedSet!
    @NSManaged var pass: ComputePass?
    @NSManaged var state: ComputePipelineState!
    @NSManaged var threadgroupsPerGrid: Size!
    @NSManaged var threadsPerThreadgroup: Size!

}
