//
//  ScissorRect+CoreDataProperties.swift
//  MetalEditor
//
//  Created by Litherum on 8/29/15.
//  Copyright © 2015 Litherum. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension ScissorRect {

    @NSManaged var x: NSNumber
    @NSManaged var y: NSNumber
    @NSManaged var width: NSNumber
    @NSManaged var height: NSNumber
    @NSManaged var renderInvocation: RenderInvocation

}
