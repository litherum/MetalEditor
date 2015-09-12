//
//  RenderPipelineState+CoreDataProperties.swift
//  MetalEditor
//
//  Created by Litherum on 8/24/15.
//  Copyright © 2015 Litherum. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension RenderPipelineState {

    @NSManaged var alphaToCoverageEnabled: NSNumber
    @NSManaged var depthAttachmentPixelFormat: NSNumber?
    @NSManaged var fragmentFunction: String
    @NSManaged var name: String
    @NSManaged var sampleCount: NSNumber?
    @NSManaged var stencilAttachmentPixelFormat: NSNumber?
    @NSManaged var vertexFunction: String
    @NSManaged var alphaToOneEnabled: NSNumber
    @NSManaged var rasterizationEnabled: NSNumber
    @NSManaged var inputPrimitiveTopology: NSNumber
    @NSManaged var colorAttachments: NSOrderedSet
    @NSManaged var invocations: NSSet
    @NSManaged var vertexAttributes: NSOrderedSet
    @NSManaged var vertexBufferLayouts: NSOrderedSet

}
