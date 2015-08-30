//
//  RenderPassAttachment+CoreDataProperties.swift
//  MetalEditor
//
//  Created by Litherum on 8/30/15.
//  Copyright © 2015 Litherum. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension RenderPassAttachment {

    @NSManaged var level: NSNumber
    @NSManaged var slice: NSNumber
    @NSManaged var depthPlane: NSNumber
    @NSManaged var loadAction: NSNumber
    @NSManaged var storeAction: NSNumber
    @NSManaged var resolveLevel: NSNumber
    @NSManaged var resolveSlice: NSNumber
    @NSManaged var resolveDepthPlane: NSNumber
    @NSManaged var texture: Texture?
    @NSManaged var resolveTexture: Texture?

}
