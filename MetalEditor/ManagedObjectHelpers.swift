//
//  ManagedObjectHelpers.swift
//  MetalEditor
//
//  Created by Litherum on 8/4/15.
//  Copyright © 2015 Litherum. All rights reserved.
//

import CoreData

func validatePropertyIsUnique(_ type: String, managedObjectContext: NSManagedObjectContext, name: String, value: AnyObject, probe: NSObject) throws {
    let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: type)
    fetchRequest.predicate = NSPredicate(format: "%K = %@", argumentArray: [name, value])
    var objects: [NSManagedObject] = []
    do {
        objects = try managedObjectContext.fetch(fetchRequest) as! [NSManagedObject]
    } catch {
    }
    for object in objects {
        if object != probe {
            throw NSError(domain: "MetalEditor", code: NSManagedObjectValidationError, userInfo: nil)
        }
    }
}

func validateUnique(_ type: String, managedObjectContext: NSManagedObjectContext, name: String, id: NSNumber, probe: NSObject) throws {
    try validatePropertyIsUnique(type, managedObjectContext: managedObjectContext, name: "name", value: name as AnyObject, probe: probe)
    try validatePropertyIsUnique(type, managedObjectContext: managedObjectContext, name: "id", value: id, probe: probe)
}

func validateUnique(_ type: String, managedObjectContext: NSManagedObjectContext, id: NSNumber, probe: NSObject) throws {
    try validatePropertyIsUnique(type, managedObjectContext: managedObjectContext, name: "id", value: id, probe: probe)
}
