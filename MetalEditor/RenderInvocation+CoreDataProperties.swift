//
//  RenderInvocation+CoreDataProperties.swift
//  MetalEditor
//
//  Created by Litherum on 7/18/15.
//  Copyright © 2015 Litherum. All rights reserved.
//
//  Delete this file and regenerate it using "Create NSManagedObject Subclass…"
//  to keep your implementation up to date with your model.
//

import Foundation
import CoreData

extension RenderInvocation {
    
    @NSManaged var vertexBufferBindings: NSOrderedSet!
    @NSManaged var fragmentBufferBindings: NSOrderedSet!
    @NSManaged var state: RenderPipelineState!
    @NSManaged var primitiveType: Int16
    @NSManaged var vertexStart: Int32
    @NSManaged var vertexCount: Int32

}
