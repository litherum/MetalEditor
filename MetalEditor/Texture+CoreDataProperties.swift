//
//  Texture+CoreDataProperties.swift
//  MetalEditor
//
//  Created by Litherum on 8/16/15.
//  Copyright © 2015 Litherum. All rights reserved.
//
//  Delete this file and regenerate it using "Create NSManagedObject Subclass…"
//  to keep your implementation up to date with your model.
//

import Foundation
import CoreData

extension Texture {

    @NSManaged var name: String
    @NSManaged var id: NSNumber
    @NSManaged var initialData: NSData?
    @NSManaged var arrayLength: NSNumber
    @NSManaged var depth: NSNumber
    @NSManaged var height: NSNumber
    @NSManaged var mipmapLevelCount: NSNumber
    @NSManaged var pixelFormat: NSNumber
    @NSManaged var sampleCount: NSNumber
    @NSManaged var textureType: NSNumber
    @NSManaged var width: NSNumber

}
