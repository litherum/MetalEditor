//
//  ColorAttachment+CoreDataProperties.swift
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

extension ColorAttachment {

    @NSManaged var clearRed: NSNumber
    @NSManaged var clearGreen: NSNumber
    @NSManaged var clearBlue: NSNumber
    @NSManaged var clearAlpha: NSNumber

}
