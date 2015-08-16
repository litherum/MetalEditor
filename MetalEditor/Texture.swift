//
//  Texture.swift
//  MetalEditor
//
//  Created by Litherum on 8/16/15.
//  Copyright © 2015 Litherum. All rights reserved.
//

import Foundation
import CoreData

class Texture: NSManagedObject {
    override func validateForInsert() throws {
        try super.validateForInsert()
        try validateUnique("Texture", managedObjectContext: managedObjectContext!, name: name, id: id, probe: self)
    }

    override func validateForUpdate() throws {
        try super.validateForUpdate()
        try validateUnique("Texture", managedObjectContext: managedObjectContext!, name: name, id: id, probe: self)
    }
}
