//
//  VertexAttributesTableDelegate.swift
//  MetalEditor
//
//  Created by Litherum on 8/8/15.
//  Copyright © 2015 Litherum. All rights reserved.
//

import Cocoa

let vertexFormatNameMap: [MTLVertexFormat : String] = [.Invalid: "Invalid", .UChar2: "UChar2", .UChar3: "UChar3", .UChar4: "UChar4", .Char2: "Char2", .Char3: "Char3", .Char4: "Char4", .UChar2Normalized: "UChar2Normalized", .UChar3Normalized: "UChar3Normalized", .UChar4Normalized: "UChar4Normalized", .Char2Normalized: "Char2Normalized", .Char3Normalized: "Char3Normalized", .Char4Normalized: "Char4Normalized", .UShort2: "UShort2", .UShort3: "UShort3", .UShort4: "UShort4", .Short2: "Short2", .Short3: "Short3", .Short4: "Short4", .UShort2Normalized: "UShort2Normalized", .UShort3Normalized: "UShort3Normalized", .UShort4Normalized: "UShort4Normalized", .Short2Normalized: "Short2Normalized", .Short3Normalized: "Short3Normalized", .Short4Normalized: "Short4Normalized", .Half2: "Half2", .Half3: "Half3", .Half4: "Half4", .Float: "Float", .Float2: "Float2", .Float3: "Float3", .Float4: "Float4", .Int: "Int", .Int2: "Int2", .Int3: "Int3", .Int4: "Int4", .UInt: "UInt", .UInt2: "UInt2", .UInt3: "UInt3", .UInt4: "UInt4", .Int1010102Normalized: "Int1010102Normalized", .UInt1010102Normalized: "UInt1010102Normalized"]

let vertexFormatMenuOrder: [MTLVertexFormat] = [.Invalid, .UChar2, .UChar3, .UChar4, .Char2, .Char3, .Char4, .UChar2Normalized, .UChar3Normalized, .UChar4Normalized, .Char2Normalized, .Char3Normalized, .Char4Normalized, .UShort2, .UShort3, .UShort4, .Short2, .Short3, .Short4, .UShort2Normalized, .UShort3Normalized, .UShort4Normalized, .Short2Normalized, .Short3Normalized, .Short4Normalized, .Half2, .Half3, .Half4, .Float, .Float2, .Float3, .Float4, .Int, .Int2, .Int3, .Int4, .UInt, .UInt2, .UInt3, .UInt4, .Int1010102Normalized, .UInt1010102Normalized]

func vertexFormatToIndex(vertexFormat: MTLVertexFormat) -> Int {
    for i in 0 ..< vertexFormatMenuOrder.count {
        if vertexFormatMenuOrder[i] == vertexFormat {
            return i
        }
    }
    return 0
}

func indexToVertexFormat(i: Int) -> MTLVertexFormat? {
    guard i >= 0 && i < vertexFormatMenuOrder.count else {
        return nil
    }
    return vertexFormatMenuOrder[i]
}

func vertexFormatMenu() -> NSMenu {
    let result = NSMenu()
    for i in MTLVertexFormat.Invalid.rawValue ... MTLVertexFormat.UInt1010102Normalized.rawValue {
        guard let format = MTLVertexFormat(rawValue: i) else {
            continue
        }
        guard let name = vertexFormatNameMap[format] else {
            continue
        }
        result.addItem(NSMenuItem(title: name, action: nil, keyEquivalent: ""))
    }
    return result
}

class VertexAttributesTableDelegate: NSObject, NSTableViewDelegate, NSTableViewDataSource {
    var managedObjectContext: NSManagedObjectContext!
    weak var modelObserver: ModelObserver!
    var state: RenderPipelineState!
    @IBOutlet var tableView: NSTableView!
    @IBOutlet var formatColumn: NSTableColumn!
    @IBOutlet var offsetColumn: NSTableColumn!
    @IBOutlet var bufferIndexColumn: NSTableColumn!

    func addVertexAttribute() {
        let attributeCount = numberOfVertexAttributes()
        let attribute = NSEntityDescription.insertNewObjectForEntityForName("VertexAttribute", inManagedObjectContext: managedObjectContext) as! VertexAttribute
        attribute.format = MTLVertexFormat.Float2.rawValue
        attribute.offset = 0
        attribute.bufferIndex = 0
        attribute.id = attributeCount
        state.mutableOrderedSetValueForKey("vertexAttributes").addObject(attribute)
    }

    func removeSelectedVertexAttribute() {
        guard tableView.selectedRow >= 0 && tableView.selectedRow < state.vertexAttributes.count else {
            return
        }
        managedObjectContext.deleteObject(state.vertexAttributes[tableView.selectedRow] as! NSManagedObject)
    }

    func numberOfVertexAttributes() -> Int {
        return state.vertexAttributes.count
    }

    func numberOfRowsInTableView(tableView: NSTableView) -> Int {
        return numberOfVertexAttributes()
    }

    func tableView(tableView: NSTableView, viewForTableColumn tableColumn: NSTableColumn?, row: Int) -> NSView? {
        guard let column = tableColumn else {
            return nil
        }
        guard let vertexAttribute = state.vertexAttributes[row] as? VertexAttribute else {
            return nil
        }
        switch column {
        case formatColumn:
            guard let result = tableView.makeViewWithIdentifier("FormatPopUp", owner: self) as? NSTableCellView else {
                return nil
            }
            guard result.subviews.count == 1 else {
                return nil
            }
            guard let popUp = result.subviews[0] as? NSPopUpButton else {
                return nil
            }
            guard let format = MTLVertexFormat(rawValue: vertexAttribute.format.unsignedLongValue) else {
                return nil
            }
            popUp.menu = vertexFormatMenu()
            popUp.selectItemAtIndex(vertexFormatToIndex(format))
            return result
        case offsetColumn:
            guard let result = tableView.makeViewWithIdentifier("OffsetField", owner: self) as? NSTableCellView else {
                return nil
            }
            guard let textField = result.textField else {
                return nil
            }
            textField.editable = true
            textField.integerValue = vertexAttribute.offset.integerValue
            return result
        case bufferIndexColumn:
            guard let result = tableView.makeViewWithIdentifier("BufferIndexField", owner: self) as? NSTableCellView else {
                return nil
            }
            guard let textField = result.textField else {
                return nil
            }
            textField.editable = true
            textField.integerValue = vertexAttribute.bufferIndex.integerValue
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

    @IBAction func formatSelected(sender: NSPopUpButton) {
        let row = tableView.rowForView(sender)
        guard row >= 0 else {
            return
        }
        guard sender.indexOfSelectedItem >= 0 else {
            return
        }
        guard let vertexAttribute = state.vertexAttributes[row] as? VertexAttribute else {
            return
        }
        guard let format = indexToVertexFormat(sender.indexOfSelectedItem) else {
            return
        }
        vertexAttribute.format = format.rawValue
        modelObserver.modelDidChange()
    }

    @IBAction func setOffset(sender: NSTextField) {
        let row = tableView.rowForView(sender)
        guard row >= 0 else {
            return
        }
        guard let vertexAttribute = state.vertexAttributes[row] as? VertexAttribute else {
            return
        }
        vertexAttribute.offset = sender.integerValue
        modelObserver.modelDidChange()
    }
    
    @IBAction func setBufferIndex(sender: NSTextField) {
        let row = tableView.rowForView(sender)
        guard row >= 0 else {
            return
        }
        guard let vertexAttribute = state.vertexAttributes[row] as? VertexAttribute else {
            return
        }
        vertexAttribute.bufferIndex = sender.integerValue
        modelObserver.modelDidChange()
    }
}