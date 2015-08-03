//
//  ComputeStateUIController.swift
//  MetalEditor
//
//  Created by Litherum on 8/2/15.
//  Copyright © 2015 Litherum. All rights reserved.
//

import Cocoa

class ComputeStateUIController: NSObject, NSTableViewDelegate, NSTableViewDataSource {
    var managedObjectContext: NSManagedObjectContext!
    weak var modelObserver: ModelObserver!
    @IBOutlet var tableView: NSTableView!
    @IBOutlet var nameColumn: NSTableColumn!
    @IBOutlet var functionNameColumn: NSTableColumn!
    private func numberOfStates() -> Int {
        let fetchRequest = NSFetchRequest(entityName: "ComputePipelineState")
        var error: NSError?
        let result = managedObjectContext.countForFetchRequest(fetchRequest, error: &error)
        assert(error == nil)
        return result
    }

    func numberOfRowsInTableView(tableView: NSTableView) -> Int {
        return numberOfStates()
    }

    private func getState(index: Int) -> ComputePipelineState? {
        let fetchRequest = NSFetchRequest(entityName: "ComputePipelineState")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "id", ascending: true)]
        // <rdar://problem/22108925> managedObjectContext.executeFetchRequest() crashes if you add two objects.
        // FIXME: This is a hack.
        //fetchRequest.fetchLimit = 1
        //fetchRequest.fetchOffset = index
        
        do {
            let states = try managedObjectContext.executeFetchRequest(fetchRequest) as! [ComputePipelineState]
            if states.count == 0 {
                return nil
            }
            return states[index]
        } catch {
            return nil
        }
    }

    @IBAction func setName(sender: NSTextField) {
        let row = tableView.rowForView(sender)
        if row == -1 {
            return
        }
        guard let state = getState(row) else {
            return
        }
        state.name = sender.stringValue
        modelObserver.modelDidChange()
    }

    @IBAction func setFunctionName(sender: NSTextField) {
        let row = tableView.rowForView(sender)
        if row == -1 {
            return
        }
        guard let state = getState(row) else {
            return
        }
        state.functionName = sender.stringValue
        modelObserver.modelDidChange()
    }

    func tableView(tableView: NSTableView, viewForTableColumn tableColumn: NSTableColumn?, row: Int) -> NSView? {
        guard let column = tableColumn else {
            return nil
        }
        guard let state = getState(row) else {
            return nil
        }
        switch column {
        case nameColumn:
            if let result = tableView.makeViewWithIdentifier("NameTextField", owner: self) as? NSTableCellView {
                if let textField = result.textField {
                    textField.editable = true
                    textField.stringValue = state.name
                    return result
                }
            }
            return nil
        case functionNameColumn:
            if let result = tableView.makeViewWithIdentifier("FunctionNameTextField", owner: self) as? NSTableCellView {
                if let textField = result.textField {
                    textField.editable = true
                    textField.stringValue = state.functionName
                    return result
                }
            }
            return nil
        default:
            return nil
        }
    }

    @IBAction func addRemove(sender: NSSegmentedControl) {
        if sender.selectedSegment == 0 {
            // Add
            let stateCount = numberOfStates()
            let state = NSEntityDescription.insertNewObjectForEntityForName("ComputePipelineState", inManagedObjectContext: managedObjectContext) as! ComputePipelineState
            state.functionName = "Function"
            state.id = stateCount
        } else {
            assert(sender.selectedSegment == 1)
            // Remove
            for index in tableView.selectedRowIndexes {
                guard let state = getState(index) else {
                    continue
                }
                managedObjectContext.deleteObject(state);
            }
        }
        tableView.reloadData()
        modelObserver.modelDidChange()
        sender.selectedSegment = -1
    }
}