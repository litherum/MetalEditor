//
//  RenderPipelineState+CoreDataProperties.swift
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

extension RenderPipelineState {

    @NSManaged var vertexFunction: String!
    @NSManaged var fragmentFunction: String!
    @NSManaged var depthAttachmentPixelFormat: Int32
    @NSManaged var stencilAttachmentPixelFormat: Int32
    @NSManaged var sampleCount: Int32
    @NSManaged var colorAttachments: NSOrderedSet!
    @NSManaged var vertexAttributes: NSOrderedSet!
    @NSManaged var vertexBufferLayouts: NSOrderedSet!

}
