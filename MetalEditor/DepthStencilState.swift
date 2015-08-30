//
//  DepthStencilState.swift
//  MetalEditor
//
//  Created by Litherum on 8/30/15.
//  Copyright © 2015 Litherum. All rights reserved.
//

import Foundation
import CoreData

class DepthStencilState: NSManagedObject {
    override func validateForInsert() throws {
        try super.validateForInsert()
        try validateUnique("DepthStencilState", managedObjectContext: managedObjectContext!, name: name, id: id, probe: self)
    }

    override func validateForUpdate() throws {
        try super.validateForUpdate()
        try validateUnique("DepthStencilState", managedObjectContext: managedObjectContext!, name: name, id: id, probe: self)
    }
}
