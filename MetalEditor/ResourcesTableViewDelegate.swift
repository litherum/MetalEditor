//
//  ResourcesTableViewDelegate.swift
//  MetalEditor
//
//  Created by Litherum on 7/20/15.
//  Copyright © 2015 Litherum. All rights reserved.
//

import Cocoa

class ResourcesTableViewDelegate: NSObject, NSTableViewDelegate, NSTableViewDataSource {
    var managedObjectContext: NSManagedObjectContext!
    @IBOutlet var nameColumn: NSTableColumn!
    @IBOutlet var typeColumn: NSTableColumn!
    @IBOutlet var lengthColumn: NSTableColumn!
    @IBOutlet var fileColumn: NSTableColumn!

    func numberOfRowsInTableView(tableView: NSTableView) -> Int {
        let fetchRequest = NSFetchRequest(entityName: "Buffer")
        var error: NSError?
        let result = managedObjectContext.countForFetchRequest(fetchRequest, error: &error)
        assert(error == nil)
        return result
    }

    func tableView(tableView: NSTableView, viewForTableColumn tableColumn: NSTableColumn?, row: Int) -> NSView? {
        guard let column = tableColumn else {
            return nil
        }

        let fetchRequest = NSFetchRequest(entityName: "Buffer")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        fetchRequest.fetchLimit = 1
        fetchRequest.fetchOffset = row

        do {
            let buffers = try managedObjectContext.executeFetchRequest(fetchRequest) as! [Buffer]
            if buffers.count == 0 {
                return nil
            }
            let buffer = buffers[0]
            switch column {
            case nameColumn:
                let result = NSTextField()
                result.drawsBackground = false
                result.editable = false
                result.bezeled = false
                result.bordered = false
                result.stringValue = buffer.name
                return result
            case typeColumn:
                let result = NSTextField()
                result.drawsBackground = false
                result.editable = false
                result.bezeled = false
                result.bordered = false
                if buffer.initialData != nil {
                    result.stringValue = "Data"
                } else {
                    result.stringValue = "Length"
                }
                return result
            case lengthColumn:
                let result = NSTextField()
                result.drawsBackground = false
                result.editable = false
                result.bezeled = false
                result.bordered = false
                if let data = buffer.initialData {
                    result.stringValue = "\(data.length)"
                } else if let length = buffer.initialLength {
                    result.stringValue = "\(length)"
                } else {
                    assertionFailure()
                }
                return result
            case fileColumn:
                let result = NSButton()
                result.bezelStyle = .RoundedBezelStyle
                result.title = "Choose"
                return result
            default:
                return nil
            }
        } catch {
            return nil
        }
    }
}
