//
//  VertexAttribute+CoreDataProperties.swift
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

extension VertexAttribute {

    @NSManaged var format: Int32
    @NSManaged var offset: Int32
    @NSManaged var bufferIndex: Int32

}
