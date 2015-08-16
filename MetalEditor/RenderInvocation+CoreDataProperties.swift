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

    @NSManaged var primitive: NSNumber
    @NSManaged var vertexStart: NSNumber
    @NSManaged var vertexCount: NSNumber
    @NSManaged var state: RenderPipelineState?
    @NSManaged var vertexBufferBindings: NSOrderedSet
    @NSManaged var fragmentBufferBindings: NSOrderedSet
    @NSManaged var vertexTextureBindings: NSOrderedSet
    @NSManaged var fragmentTextureBindings: NSOrderedSet

}
