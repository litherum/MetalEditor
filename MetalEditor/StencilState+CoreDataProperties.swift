//
//  StencilDescriptor+CoreDataProperties.swift
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

extension StencilState {

    @NSManaged var stencilFailureOperation: NSNumber
    @NSManaged var depthFailureOperation: NSNumber
    @NSManaged var depthStencilPassOperation: NSNumber
    @NSManaged var stencilCompareFunction: NSNumber
    @NSManaged var readMask: NSNumber
    @NSManaged var writeMask: NSNumber

}
