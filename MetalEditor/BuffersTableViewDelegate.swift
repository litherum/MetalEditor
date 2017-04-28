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

    fileprivate func numberOfBuffers() -> Int {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Buffer")
        var error: NSError?
        let result = try! managedObjectContext.count(for: fetchRequest)
        assert(error == nil)
        return result
    }

    func numberOfRows(in tableView: NSTableView) -> Int {
        return numberOfBuffers()
    }

    fileprivate func getBuffer(_ index: Int) -> Buffer {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Buffer")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "id", ascending: true)]
        // <rdar://problem/22108925> managedObjectContext.executeFetchRequest() crashes if you add two objects.
        // FIXME: This is a hack.
        //fetchRequest.fetchLimit = 1
        //fetchRequest.fetchOffset = index
        
        do {
            let buffers = try managedObjectContext.fetch(fetchRequest) as! [Buffer]
            return buffers[index]
        } catch {
            fatalError()
        }
    }

    @IBAction func setName(_ sender: NSTextField) {
        let row = tableView.row(for: sender)
        let buffer = getBuffer(row)
        buffer.name = sender.stringValue
        modelObserver.modelDidChange()
    }

    @IBAction func setLength(_ sender: NSTextField) {
        let row = tableView.row(for: sender)
        let buffer = getBuffer(row)
        buffer.initialLength = sender.integerValue as NSNumber
        buffer.initialData = nil
        tableView.reloadData()
        modelObserver.modelDidChange()
    }

    @IBAction func setData(_ sender: NSButton) {
        let row = tableView.row(for: sender)
        let buffer = getBuffer(row)
        let window = tableView.window!
        let openPanel = NSOpenPanel()
        openPanel.allowsMultipleSelection = false
        openPanel.beginSheetModal(for: window) {(selected: Int) in
            guard selected == NSFileHandlingPanelOKButton else {
                return
            }
            guard let url = openPanel.url else {
                return
            }
            guard let contents = try? Data(contentsOf: url) else {
                return
            }
            buffer.initialData = contents
            buffer.initialLength = nil
            self.tableView.reloadData()
            self.modelObserver.modelDidChange()
        }
    }

    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let buffer = getBuffer(row)
        switch tableColumn! {
        case nameColumn:
            let result = tableView.make(withIdentifier: "NameTextField", owner: self) as! NSTableCellView
            let textField = result.textField!
            textField.isEditable = true
            textField.stringValue = buffer.name
            return result
        case typeColumn:
            let result = tableView.make(withIdentifier: "TypeTextField", owner: self) as! NSTableCellView
            let textField = result.textField!
            if buffer.initialData != nil {
                textField.stringValue = "Data"
            } else {
                textField.stringValue = "Length"
            }
            return result
        case lengthColumn:
            let result = tableView.make(withIdentifier: "LengthTextField", owner: self) as! NSTableCellView
            let textField = result.textField!
            textField.isEditable = true
            if let data = buffer.initialData {
                textField.stringValue = "\(data.count)"
            } else {
                textField.intValue = buffer.initialLength!.int32Value
            }
            return result
        case fileColumn:
            return tableView.make(withIdentifier: "FileButton", owner: self) as! NSTableCellView
        default:
            return nil
        }
    }

    @IBAction func addRemove(_ sender: NSSegmentedControl) {
        if sender.selectedSegment == 0 { // Add
            let bufferCount = numberOfBuffers()
            let buffer = NSEntityDescription.insertNewObject(forEntityName: "Buffer", into: managedObjectContext) as! Buffer
            buffer.initialData = nil
            buffer.initialLength = 0
            buffer.name = "Buffer"
            buffer.id = NSNumber(bufferCount)
        } else { // Remove
            assert(sender.selectedSegment == 1)
            guard tableView.selectedRow >= 0 else {
                return
            }
            managedObjectContext.delete(getBuffer(tableView.selectedRow))
        }
        tableView.reloadData()
        modelObserver.modelDidChange()
        sender.selectedSegment = -1
    }
}
