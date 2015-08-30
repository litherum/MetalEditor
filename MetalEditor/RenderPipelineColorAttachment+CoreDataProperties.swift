//
//  RenderPipelineColorAttachment+CoreDataProperties.swift
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

extension RenderPipelineColorAttachment {

    @NSManaged var id: NSNumber
    @NSManaged var pixelFormat: NSNumber?
    @NSManaged var writeAlpha: NSNumber
    @NSManaged var writeRed: NSNumber
    @NSManaged var writeGreen: NSNumber
    @NSManaged var writeBlue: NSNumber
    @NSManaged var blendingEnabled: NSNumber
    @NSManaged var alphaBlendOperation: NSNumber
    @NSManaged var rgbBlendOperation: NSNumber
    @NSManaged var destinationAlphaBlendFactor: NSNumber
    @NSManaged var destinationRGBBlendFactor: NSNumber
    @NSManaged var sourceAlphaBlendFactor: NSNumber
    @NSManaged var sourceRGBBlendFactor: NSNumber

}
