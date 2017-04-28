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

    func numberOfRows(in tableView: NSTableView) -> Int {
        return numberOfVertexBufferLayouts()
    }

    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let vertexBufferLayout = state.vertexBufferLayouts[row] as! VertexBufferLayout
        switch tableColumn! {
        case indexColumn:
            let result = tableView.make(withIdentifier: "Index", owner: self) as! NSTableCellView
            let textField = result.textField!
            textField.isEditable = true
            textField.integerValue = vertexBufferLayout.index.intValue
            return result
        case stepFunctionColumn:
            let result = tableView.make(withIdentifier: "StepFunctionPopUp", owner: self) as! NSTableCellView
            assert(result.subviews.count == 1)
            let popUp = result.subviews[0] as! NSPopUpButton
            let function = MTLVertexStepFunction(rawValue: vertexBufferLayout.stepFunction.uintValue)!
            popUp.selectItem(at: Int(function.rawValue))
            return result
        case stepRateColumn:
            let result = tableView.make(withIdentifier: "StepRateField", owner: self) as! NSTableCellView
            let textField = result.textField!
            textField.isEditable = true
            textField.integerValue = vertexBufferLayout.stepRate.intValue
            return result
        case strideColumn:
            let result = tableView.make(withIdentifier: "StrideField", owner: self) as! NSTableCellView
            let textField = result.textField!
            textField.isEditable = true
            textField.integerValue = vertexBufferLayout.stride.intValue
            return result
        default:
            fatalError()
        }
    }

    func control(_ control: NSControl, isValidObject obj: Any?) -> Bool {
        return Int(obj as! String) != nil
    }

    @IBAction func setIndex(_ sender: NSTextField) {
        let row = tableView.row(for: sender)
        let vertexBufferLayout = state.vertexBufferLayouts[row] as! VertexBufferLayout
        indexObserver.setVertexBufferLayoutIndex(sender.integerValue, vertexBufferLayout: vertexBufferLayout)
    }

    @IBAction func stepFunctionSelected(_ sender: NSPopUpButton) {
        let row = tableView.row(for: sender)
        let vertexBufferLayout = state.vertexBufferLayouts[row] as! VertexBufferLayout
        let stepFunction = MTLVertexStepFunction(rawValue: UInt(sender.indexOfSelectedItem))!
        vertexBufferLayout.stepFunction = NSNumber(value: stepFunction.rawValue)
        modelObserver.modelDidChange()
    }

    @IBAction func setStepRate(_ sender: NSTextField) {
        let row = tableView.row(for: sender)
        let vertexBufferLayout = state.vertexBufferLayouts[row] as! VertexBufferLayout
        vertexBufferLayout.stepRate = NSNumber(value: sender.integerValue)
        modelObserver.modelDidChange()
    }

    @IBAction func setStride(_ sender: NSTextField) {
        let row = tableView.row(for: sender)
        let vertexBufferLayout = state.vertexBufferLayouts[row] as! VertexBufferLayout
        vertexBufferLayout.stride = NSNumber(value: sender.integerValue)
        modelObserver.modelDidChange()
    }
}

