//
//  Buffer+CoreDataProperties.swift
//  MetalEditor
//
//  Created by Litherum on 7/17/15.
//  Copyright © 2015 Litherum. All rights reserved.
//
//  Delete this file and regenerate it using "Create NSManagedObject Subclass…"
//  to keep your implementation up to date with your model.
//

import Foundation
import CoreData

extension Buffer {
    
    @NSManaged var name: String
    @NSManaged var initialData: NSData?
    @NSManaged var initialLength: NSNumber?

}
