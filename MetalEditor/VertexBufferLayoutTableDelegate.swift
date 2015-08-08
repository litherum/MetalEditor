//
//  VertexBufferLayoutTableDelegate.swift
//  MetalEditor
//
//  Created by Litherum on 8/8/15.
//  Copyright © 2015 Litherum. All rights reserved.
//

import Cocoa

class VertexBufferLayoutTableDelegate: NSObject, NSTableViewDelegate, NSTableViewDataSource {
    var managedObjectContext: NSManagedObjectContext!
    weak var modelObserver: ModelObserver!
    var state: RenderPipelineState!
    @IBOutlet var tableView: NSTableView!
    @IBOutlet var stepFunctionColumn: NSTableColumn!
    @IBOutlet var stepRateColumn: NSTableColumn!
    @IBOutlet weak var strideColumn: NSTableColumn!

    func addVertexBufferLayout() {
        let layoutCount = numberOfVertexBufferLayouts()
        let layout = NSEntityDescription.insertNewObjectForEntityForName("VertexBufferLayout", inManagedObjectContext: managedObjectContext) as! VertexBufferLayout
        layout.stepFunction = MTLVertexStepFunction.PerVertex.rawValue
        layout.stepRate = 1
        layout.stride = 8
        layout.id = layoutCount
        state.mutableOrderedSetValueForKey("vertexBufferLayouts").addObject(layout)
    }

    func removeSelectedVertexBufferLayout() {
        guard tableView.selectedRow >= 0 && tableView.selectedRow < state.vertexBufferLayouts.count else {
            return
        }
        managedObjectContext.deleteObject(state.vertexBufferLayouts[tableView.selectedRow] as! NSManagedObject)
    }

    func numberOfVertexBufferLayouts() -> Int {
        return state.vertexBufferLayouts.count
    }

    func numberOfRowsInTableView(tableView: NSTableView) -> Int {
        return numberOfVertexBufferLayouts()
    }

    func tableView(tableView: NSTableView, viewForTableColumn tableColumn: NSTableColumn?, row: Int) -> NSView? {
        guard let column = tableColumn else {
            return nil
        }
        guard let vertexBufferLayout = state.vertexBufferLayouts[row] as? VertexBufferLayout else {
            return nil
        }
        switch column {
        case stepFunctionColumn:
            guard let result = tableView.makeViewWithIdentifier("StepFunctionPopUp", owner: self) as? NSTableCellView else {
                return nil
            }
            guard result.subviews.count == 1 else {
                return nil
            }
            guard let popUp = result.subviews[0] as? NSPopUpButton else {
                return nil
            }
            guard let function = MTLVertexStepFunction(rawValue: vertexBufferLayout.stepFunction.unsignedLongValue) else {
                return nil
            }
            popUp.selectItemAtIndex(Int(function.rawValue))
            return result
        case stepRateColumn:
            guard let result = tableView.makeViewWithIdentifier("StepRateField", owner: self) as? NSTableCellView else {
                return nil
            }
            guard let textField = result.textField else {
                return nil
            }
            textField.editable = true
            textField.integerValue = vertexBufferLayout.stepRate.integerValue
            return result
        case strideColumn:
            guard let result = tableView.makeViewWithIdentifier("StrideField", owner: self) as? NSTableCellView else {
                return nil
            }
            guard let textField = result.textField else {
                return nil
            }
            textField.editable = true
            textField.integerValue = vertexBufferLayout.stride.integerValue
            return result
        default:
            fatalError()
        }
    }

    func control(control: NSControl, isValidObject obj: AnyObject) -> Bool {
        if let s = obj as? String {
            if Int(s) != nil {
                return true
            }
        }
        return false
    }

    @IBAction func stepFunctionSelected(sender: NSPopUpButton) {
        let row = tableView.rowForView(sender)
        guard row >= 0 else {
            return
        }
        guard sender.indexOfSelectedItem >= 0 else {
            return
        }
        guard let vertexBufferLayout = state.vertexBufferLayouts[row] as? VertexBufferLayout else {
            return
        }
        guard let stepFunction = MTLVertexStepFunction(rawValue: UInt(sender.indexOfSelectedItem)) else {
            return
        }
        vertexBufferLayout.stepFunction = stepFunction.rawValue
        modelObserver.modelDidChange()
    }

    @IBAction func setStepRate(sender: NSTextField) {
        let row = tableView.rowForView(sender)
        guard row >= 0 else {
            return
        }
        guard let vertexBufferLayout = state.vertexBufferLayouts[row] as? VertexBufferLayout else {
            return
        }
        vertexBufferLayout.stepRate = sender.integerValue
        modelObserver.modelDidChange()
    }

    @IBAction func setStride(sender: NSTextField) {
        let row = tableView.rowForView(sender)
        guard row >= 0 else {
            return
        }
        guard let vertexBufferLayout = state.vertexBufferLayouts[row] as? VertexBufferLayout else {
            return
        }
        vertexBufferLayout.stride = sender.integerValue
        modelObserver.modelDidChange()
    }
}

