//
//  VertexAttributesTableDelegate.swift
//  MetalEditor
//
//  Created by Litherum on 8/8/15.
//  Copyright © 2015 Litherum. All rights reserved.
//

import Cocoa

let vertexFormatNameMap: [MTLVertexFormat : String] = [.invalid: "Invalid", .uchar2: "UChar2", .uchar3: "UChar3", .uchar4: "UChar4", .char2: "Char2", .char3: "Char3", .char4: "Char4", .uchar2Normalized: "UChar2Normalized", .uchar3Normalized: "UChar3Normalized", .uchar4Normalized: "UChar4Normalized", .char2Normalized: "Char2Normalized", .char3Normalized: "Char3Normalized", .char4Normalized: "Char4Normalized", .ushort2: "UShort2", .ushort3: "UShort3", .ushort4: "UShort4", .short2: "Short2", .short3: "Short3", .short4: "Short4", .ushort2Normalized: "UShort2Normalized", .ushort3Normalized: "UShort3Normalized", .ushort4Normalized: "UShort4Normalized", .short2Normalized: "Short2Normalized", .short3Normalized: "Short3Normalized", .short4Normalized: "Short4Normalized", .half2: "Half2", .half3: "Half3", .half4: "Half4", .float: "Float", .float2: "Float2", .float3: "Float3", .float4: "Float4", .int: "Int", .int2: "Int2", .int3: "Int3", .int4: "Int4", .uint: "UInt", .uint2: "UInt2", .uint3: "UInt3", .uint4: "UInt4", .int1010102Normalized: "Int1010102Normalized", .uint1010102Normalized: "UInt1010102Normalized"]

let vertexFormatMenuOrder: [MTLVertexFormat] = [.invalid, .uchar2, .uchar3, .uchar4, .char2, .char3, .char4, .uchar2Normalized, .uchar3Normalized, .uchar4Normalized, .char2Normalized, .char3Normalized, .char4Normalized, .ushort2, .ushort3, .ushort4, .short2, .short3, .short4, .ushort2Normalized, .ushort3Normalized, .ushort4Normalized, .short2Normalized, .short3Normalized, .short4Normalized, .half2, .half3, .half4, .float, .float2, .float3, .float4, .int, .int2, .int3, .int4, .uint, .uint2, .uint3, .uint4, .int1010102Normalized, .uint1010102Normalized]

func vertexFormatToIndex(_ vertexFormat: MTLVertexFormat) -> Int {
    for i in 0 ..< vertexFormatMenuOrder.count {
        if vertexFormatMenuOrder[i] == vertexFormat {
            return i
        }
    }
    return 0
}

func indexToVertexFormat(_ i: Int) -> MTLVertexFormat {
    return vertexFormatMenuOrder[i]
}

func vertexFormatMenu() -> NSMenu {
    let result = NSMenu()
    for i in MTLVertexFormat.invalid.rawValue ... MTLVertexFormat.uint1010102Normalized.rawValue {
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
    weak var indexObserver: VertexDescriptorObserver!
    var state: RenderPipelineState!
    @IBOutlet var tableView: NSTableView!
    @IBOutlet var indexColumn: NSTableColumn!
    @IBOutlet var formatColumn: NSTableColumn!
    @IBOutlet var offsetColumn: NSTableColumn!
    @IBOutlet var bufferIndexColumn: NSTableColumn!

    func numberOfVertexAttributes() -> Int {
        return state.vertexAttributes.count
    }

    func numberOfRows(in tableView: NSTableView) -> Int {
        return numberOfVertexAttributes()
    }

    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let vertexAttribute = state.vertexAttributes[row] as! VertexAttribute
        switch tableColumn! {
        case indexColumn:
            let result = tableView.make(withIdentifier: "Index", owner: self) as! NSTableCellView
            let textField = result.textField!
            textField.isEditable = true
            textField.integerValue = vertexAttribute.index.intValue
            return result
        case formatColumn:
            let result = tableView.make(withIdentifier: "FormatPopUp", owner: self) as! NSTableCellView
            assert(result.subviews.count == 1)
            let popUp = result.subviews[0] as! NSPopUpButton
            let format = MTLVertexFormat(rawValue: vertexAttribute.format.uintValue)!
            popUp.menu = vertexFormatMenu()
            popUp.selectItem(at: vertexFormatToIndex(format))
            return result
        case offsetColumn:
            let result = tableView.make(withIdentifier: "OffsetField", owner: self) as! NSTableCellView
            let textField = result.textField!
            textField.isEditable = true
            textField.integerValue = vertexAttribute.offset.intValue
            return result
        case bufferIndexColumn:
            let result = tableView.make(withIdentifier: "BufferIndexField", owner: self) as! NSTableCellView
            let textField = result.textField!
            textField.isEditable = true
            textField.integerValue = vertexAttribute.bufferIndex.intValue
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
        let vertexAttribute = state.vertexAttributes[row] as! VertexAttribute
        indexObserver.setVertexAttributeIndex(sender.integerValue, vertexAttribute: vertexAttribute)
    }

    @IBAction func formatSelected(_ sender: NSPopUpButton) {
        let row = tableView.row(for: sender)
        let vertexAttribute = state.vertexAttributes[row] as! VertexAttribute
        let format = indexToVertexFormat(sender.indexOfSelectedItem)
        vertexAttribute.format = NSNumber(value: format.rawValue)
        modelObserver.modelDidChange()
    }

    @IBAction func setOffset(_ sender: NSTextField) {
        let row = tableView.row(for: sender)
        let vertexAttribute = state.vertexAttributes[row] as! VertexAttribute
        vertexAttribute.offset = NSNumber(sender.integerValue)
        modelObserver.modelDidChange()
    }
    
    @IBAction func setBufferIndex(_ sender: NSTextField) {
        let row = tableView.row(for: sender)
        let vertexAttribute = state.vertexAttributes[row] as! VertexAttribute
        indexObserver.setVertexAttributeBufferIndex(sender.integerValue, vertexAttribute: vertexAttribute)
    }
}
