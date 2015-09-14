//
//  VertexBufferLayout+CoreDataProperties.swift
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

extension VertexBufferLayout {

    @NSManaged var index: NSNumber
    @NSManaged var id: NSNumber
    @NSManaged var stride: NSNumber
    @NSManaged var stepFunction: NSNumber
    @NSManaged var stepRate: NSNumber

}
