//
//  BuffersUIController.swift
//  MetalEditor
//
//  Created by Litherum on 7/20/15.
//  Copyright © 2015 Litherum. All rights reserved.
//

import Cocoa

class BuffersTableViewDelegate: NSObject, NSTableViewDelegate, NSTableViewDataSource {
    var managedObjectContext: NSManagedObjectContext!
    weak var modelObserver: ModelObserver!
    @IBOutlet var tableView: NSTableView!
    @IBOutlet var nameColumn: NSTableColumn!
    @IBOutlet var typeColumn: NSTableColumn!
    @IBOutlet var lengthColumn: NSTableColumn!
    @IBOutlet var fileColumn: NSTableColumn!

    private func numberOfBuffers() -> Int {
        let fetchRequest = NSFetchRequest(entityName: "Buffer")
        var error: NSError?
        let result = managedObjectContext.countForFetchRequest(fetchRequest, error: &error)
        assert(error == nil)
        return result
    }

    func numberOfRowsInTableView(tableView: NSTableView) -> Int {
        return numberOfBuffers()
    }

    private func getBuffer(index: Int) -> Buffer {
        let fetchRequest = NSFetchRequest(entityName: "Buffer")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "id", ascending: true)]
        // <rdar://problem/22108925> managedObjectContext.executeFetchRequest() crashes if you add two objects.
        // FIXME: This is a hack.
        //fetchRequest.fetchLimit = 1
        //fetchRequest.fetchOffset = index
        
        do {
            let buffers = try managedObjectContext.executeFetchRequest(fetchRequest) as! [Buffer]
            return buffers[index]
        } catch {
            fatalError()
        }
    }

    @IBAction func setName(sender: NSTextField) {
        let row = tableView.rowForView(sender)
        let buffer = getBuffer(row)
        buffer.name = sender.stringValue
        modelObserver.modelDidChange()
    }

    @IBAction func setLength(sender: NSTextField) {
        let row = tableView.rowForView(sender)
        let buffer = getBuffer(row)
        buffer.initialLength = sender.integerValue
        buffer.initialData = nil
        tableView.reloadData()
        modelObserver.modelDidChange()
    }

    @IBAction func setData(sender: NSButton) {
        let row = tableView.rowForView(sender)
        let buffer = getBuffer(row)
        let window = tableView.window!
        let openPanel = NSOpenPanel()
        openPanel.allowsMultipleSelection = false
        openPanel.beginSheetModalForWindow(window) {(selected: Int) in
            guard selected == NSFileHandlingPanelOKButton else {
                return
            }
            guard let url = openPanel.URL else {
                return
            }
            guard let contents = NSData(contentsOfURL: url) else {
                return
            }
            buffer.initialData = contents
            buffer.initialLength = nil
            self.tableView.reloadData()
            self.modelObserver.modelDidChange()
        }
    }

    func tableView(tableView: NSTableView, viewForTableColumn tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let buffer = getBuffer(row)
        switch tableColumn! {
        case nameColumn:
            let result = tableView.makeViewWithIdentifier("NameTextField", owner: self) as! NSTableCellView
            let textField = result.textField!
            textField.editable = true
            textField.stringValue = buffer.name
            return result
        case typeColumn:
            let result = tableView.makeViewWithIdentifier("TypeTextField", owner: self) as! NSTableCellView
            let textField = result.textField!
            if buffer.initialData != nil {
                textField.stringValue = "Data"
            } else {
                textField.stringValue = "Length"
            }
            return result
        case lengthColumn:
            let result = tableView.makeViewWithIdentifier("LengthTextField", owner: self) as! NSTableCellView
            let textField = result.textField!
            textField.editable = true
            if let data = buffer.initialData {
                textField.stringValue = "\(data.length)"
            } else {
                textField.intValue = buffer.initialLength!.intValue
            }
            return result
        case fileColumn:
            return tableView.makeViewWithIdentifier("FileButton", owner: self) as! NSTableCellView
        default:
            return nil
        }
    }

    @IBAction func addRemove(sender: NSSegmentedControl) {
        if sender.selectedSegment == 0 { // Add
            let bufferCount = numberOfBuffers()
            let buffer = NSEntityDescription.insertNewObjectForEntityForName("Buffer", inManagedObjectContext: managedObjectContext) as! Buffer
            buffer.initialData = nil
            buffer.initialLength = 0
            buffer.name = "Buffer"
            buffer.id = bufferCount
        } else { // Remove
            assert(sender.selectedSegment == 1)
            guard tableView.selectedRow >= 0 else {
                return
            }
            managedObjectContext.deleteObject(getBuffer(tableView.selectedRow))
        }
        tableView.reloadData()
        modelObserver.modelDidChange()
        sender.selectedSegment = -1
    }
}
