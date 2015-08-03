//
//  RenderStateDetailView.swift
//  MetalEditor
//
//  Created by Litherum on 8/2/15.
//  Copyright © 2015 Litherum. All rights reserved.
//

import Cocoa

class RenderStateDetailView : NSTableCellView, NSTableViewDelegate, NSTableViewDataSource {
    var initialized = false
    var managedObjectContext: NSManagedObjectContext!
    weak var modelObserver: ModelObserver!
    var state: RenderPipelineState!
    @IBOutlet var nameTextField: NSTextField!
    @IBOutlet var vertexFunctionTextField: NSTextField!
    @IBOutlet var fragmentFunctionTextField: NSTextField!
    // FIXME: Move all this duplicate table view gunk out to its own object
    @IBOutlet var colorAttachmentTableView: NSTableView!
    @IBOutlet var vertexAttributesTableView: NSTableView!
    @IBOutlet var vertexBufferLayoutsTableView: NSTableView!
    @IBOutlet var pixelFormatColumn: NSTableColumn!
    @IBOutlet var formatColumn: NSTableColumn!
    @IBOutlet var offsetColumn: NSTableColumn!
    @IBOutlet var bufferIndexColumn: NSTableColumn!
    @IBOutlet var stepFunctionColumn: NSTableColumn!
    @IBOutlet var stepRateColumn: NSTableColumn!
    @IBOutlet var strideColumn: NSTableColumn!

    func initialize() {
        initialized = true
        nameTextField.stringValue = state.name
        vertexFunctionTextField.stringValue = state.vertexFunction
        fragmentFunctionTextField.stringValue = state.fragmentFunction
    }

    @IBAction func setName(sender: NSTextField) {
        state.name = sender.stringValue
        modelObserver.modelDidChange()
    }

    @IBAction func setVertexFunction(sender: NSTextField) {
        state.vertexFunction = sender.stringValue
        modelObserver.modelDidChange()
    }

    @IBAction func setFragmentFunction(sender: NSTextField) {
        state.fragmentFunction = sender.stringValue
        modelObserver.modelDidChange()
    }

    // FIXME: Refactor this into a common utility
    private func numberOfEntities(entityName: String) -> Int {
        let fetchRequest = NSFetchRequest(entityName: entityName)
        var error: NSError?
        let result = managedObjectContext.countForFetchRequest(fetchRequest, error: &error)
        assert(error == nil)
        return result
    }

    func numberOfRowsInTableView(tableView: NSTableView) -> Int {
        guard initialized else {
            return 0;
        }

        switch tableView {
        case colorAttachmentTableView:
            return state.colorAttachments.count
        case vertexAttributesTableView:
            return state.vertexAttributes.count
        case vertexBufferLayoutsTableView:
            return state.vertexBufferLayouts.count
        default:
            return 0
        }
    }

    func tableView(tableView: NSTableView, viewForTableColumn tableColumn: NSTableColumn?, row: Int) -> NSView? {
        guard initialized else {
            return nil
        }
        guard let column = tableColumn else {
            return nil
        }

        switch tableView {
        case colorAttachmentTableView:
            let colorAttachment = state.colorAttachments[row] as! RenderPipelineColorAttachment
            switch column {
            case pixelFormatColumn:
                let textField = NSTextField()
                textField.stringValue = String(colorAttachment.pixelFormat)
                return textField
            default:
                return nil
            }
        case vertexAttributesTableView:
            let vertexAttribute = state.vertexAttributes[row] as! VertexAttribute
            switch column {
            case formatColumn:
                let textField = NSTextField()
                textField.stringValue = String(vertexAttribute.format)
                return textField
            case offsetColumn:
                let textField = NSTextField()
                textField.stringValue = String(vertexAttribute.offset)
                return textField
            case bufferIndexColumn:
                let textField = NSTextField()
                textField.stringValue = String(vertexAttribute.bufferIndex)
                return textField
            default:
                return nil
            }
        case vertexBufferLayoutsTableView:
            let vertexBufferLayout = state.vertexBufferLayouts[row] as! VertexBufferLayout
            switch column {
            case stepFunctionColumn:
                let textField = NSTextField()
                textField.stringValue = String(vertexBufferLayout.stepFunction)
                return textField
            case stepRateColumn:
                let textField = NSTextField()
                textField.stringValue = String(vertexBufferLayout.stepRate)
                return textField
            case strideColumn:
                let textField = NSTextField()
                textField.stringValue = String(vertexBufferLayout.stride)
                return textField
            default:
                return nil
            }
        default:
            return nil
        }
    }
}
