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
    @NSManaged var blendColorRed: NSNumber
    @NSManaged var blendColorGreen: NSNumber
    @NSManaged var blendColorBlue: NSNumber
    @NSManaged var blendColorAlpha: NSNumber
    @NSManaged var cullMode: NSNumber
    @NSManaged var depthBias: NSNumber
    @NSManaged var depthSlopeScale: NSNumber
    @NSManaged var depthClamp: NSNumber
    @NSManaged var depthClipMode: NSNumber
    @NSManaged var frontFacingWinding: NSNumber
    @NSManaged var scissorRect: ScissorRect?
    @NSManaged var stencilFrontReferenceValue: NSNumber
    @NSManaged var stencilBackReferenceValue: NSNumber
    @NSManaged var triangleFillMode: NSNumber
    @NSManaged var viewport: Viewport?
    @NSManaged var visibilityResultMode: NSNumber
    @NSManaged var visibilityResultOffset: NSNumber

}
