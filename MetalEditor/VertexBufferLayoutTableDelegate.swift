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
    weak var indexObserver: VertexDescriptorObserver!
    var state: RenderPipelineState!
    @IBOutlet var tableView: NSTableView!
    @IBOutlet var indexColumn: NSTableColumn!
    @IBOutlet var stepFunctionColumn: NSTableColumn!
    @IBOutlet var stepRateColumn: NSTableColumn!
    @IBOutlet weak var strideColumn: NSTableColumn!

    func numberOfVertexBufferLayouts() -> Int {
        return state.vertexBufferLayouts.count
    }

    func numberOfRowsInTableView(tableView: NSTableView) -> Int {
        return numberOfVertexBufferLayouts()
    }

    func tableView(tableView: NSTableView, viewForTableColumn tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let vertexBufferLayout = state.vertexBufferLayouts[row] as! VertexBufferLayout
        switch tableColumn! {
        case indexColumn:
            let result = tableView.makeViewWithIdentifier("Index", owner: self) as! NSTableCellView
            let textField = result.textField!
            textField.editable = true
            textField.integerValue = vertexBufferLayout.index.integerValue
            return result
        case stepFunctionColumn:
            let result = tableView.makeViewWithIdentifier("StepFunctionPopUp", owner: self) as! NSTableCellView
            assert(result.subviews.count == 1)
            let popUp = result.subviews[0] as! NSPopUpButton
            let function = MTLVertexStepFunction(rawValue: vertexBufferLayout.stepFunction.unsignedLongValue)!
            popUp.selectItemAtIndex(Int(function.rawValue))
            return result
        case stepRateColumn:
            let result = tableView.makeViewWithIdentifier("StepRateField", owner: self) as! NSTableCellView
            let textField = result.textField!
            textField.editable = true
            textField.integerValue = vertexBufferLayout.stepRate.integerValue
            return result
        case strideColumn:
            let result = tableView.makeViewWithIdentifier("StrideField", owner: self) as! NSTableCellView
            let textField = result.textField!
            textField.editable = true
            textField.integerValue = vertexBufferLayout.stride.integerValue
            return result
        default:
            fatalError()
        }
    }

    func control(control: NSControl, isValidObject obj: AnyObject) -> Bool {
        return Int(obj as! String) != nil
    }

    @IBAction func setIndex(sender: NSTextField) {
        let row = tableView.rowForView(sender)
        let vertexBufferLayout = state.vertexBufferLayouts[row] as! VertexBufferLayout
        indexObserver.setVertexBufferLayoutIndex(sender.integerValue, vertexBufferLayout: vertexBufferLayout)
    }

    @IBAction func stepFunctionSelected(sender: NSPopUpButton) {
        let row = tableView.rowForView(sender)
        let vertexBufferLayout = state.vertexBufferLayouts[row] as! VertexBufferLayout
        let stepFunction = MTLVertexStepFunction(rawValue: UInt(sender.indexOfSelectedItem))!
        vertexBufferLayout.stepFunction = stepFunction.rawValue
        modelObserver.modelDidChange()
    }

    @IBAction func setStepRate(sender: NSTextField) {
        let row = tableView.rowForView(sender)
        let vertexBufferLayout = state.vertexBufferLayouts[row] as! VertexBufferLayout
        vertexBufferLayout.stepRate = sender.integerValue
        modelObserver.modelDidChange()
    }

    @IBAction func setStride(sender: NSTextField) {
        let row = tableView.rowForView(sender)
        let vertexBufferLayout = state.vertexBufferLayouts[row] as! VertexBufferLayout
        vertexBufferLayout.stride = sender.integerValue
        modelObserver.modelDidChange()
    }
}

