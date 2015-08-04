//
//  ManagedObjectHelpers.swift
//  MetalEditor
//
//  Created by Litherum on 8/4/15.
//  Copyright © 2015 Litherum. All rights reserved.
//

import CoreData

func validatePropertyIsUnique(type: String, managedObjectContext: NSManagedObjectContext, name: String, value: AnyObject, probe: NSObject) throws {
    let fetchRequest = NSFetchRequest(entityName: type)
    fetchRequest.predicate = NSPredicate(format: "%K = %@", argumentArray: [name, value])
    var objects: [NSManagedObject] = []
    do {
        objects = try managedObjectContext.executeFetchRequest(fetchRequest) as! [NSManagedObject]
    } catch {
    }
    for object in objects {
        if object != probe {
            throw NSError(domain: "MetalEditor", code: NSManagedObjectValidationError, userInfo: nil)
        }
    }
}

func validateUnique(type: String, managedObjectContext: NSManagedObjectContext, name: String, id: NSNumber, probe: NSObject) throws {
    try validatePropertyIsUnique(type, managedObjectContext: managedObjectContext, name: "name", value: name, probe: probe)
    try validatePropertyIsUnique(type, managedObjectContext: managedObjectContext, name: "id", value: id, probe: probe)
}

func validateUnique(type: String, managedObjectContext: NSManagedObjectContext, id: NSNumber, probe: NSObject) throws {
    try validatePropertyIsUnique(type, managedObjectContext: managedObjectContext, name: "id", value: id, probe: probe)
}