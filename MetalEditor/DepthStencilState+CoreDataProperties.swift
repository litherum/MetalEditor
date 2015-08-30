//
//  DepthStencilState+CoreDataProperties.swift
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

extension DepthStencilState {

    @NSManaged var depthCompareFunction: NSNumber
    @NSManaged var depthWriteEnabled: NSNumber
    @NSManaged var name: String
    @NSManaged var backFaceStencil: StencilState
    @NSManaged var frontFaceStencil: StencilState

}
