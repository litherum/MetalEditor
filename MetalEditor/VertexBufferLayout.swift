//
//  VertexBufferLayout.swift
//  MetalEditor
//
//  Created by Litherum on 7/18/15.
//  Copyright © 2015 Litherum. All rights reserved.
//

import Foundation
import CoreData

class VertexBufferLayout: NSManagedObject {
    override func validateForInsert() throws {
        try super.validateForInsert()
        try validateUnique("VertexBufferLayout", managedObjectContext: managedObjectContext!, id: id, probe: self)
    }

    override func validateForUpdate() throws {
        try super.validateForUpdate()
        try validateUnique("VertexBufferLayout", managedObjectContext: managedObjectContext!, id: id, probe: self)
    }
}
