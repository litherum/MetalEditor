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
        try validatePropertyIsUnique("Texture", managedObjectContext: managedObjectContext!, name: "name", value: name, probe: self)
    }

    override func validateForUpdate() throws {
        try super.validateForUpdate()
        try validatePropertyIsUnique("Texture", managedObjectContext: managedObjectContext!, name: "name", value: name, probe: self)
    }
}
