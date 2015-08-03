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

    private class func numberToPixelFormat(pixelFormat: NSNumber?) -> MTLPixelFormat? {
        guard let number = pixelFormat else {
            return nil
        }
        return MTLPixelFormat(rawValue: number.unsignedLongValue)
    }

    private class func pixelFormatToIndex(pixelFormat: MTLPixelFormat?) -> Int {
        guard let format = pixelFormat else {
            return 0
        }
        // Suuuuuuuper slow
        var index = 0
        for i in MTLPixelFormat.A8Unorm.rawValue ... MTLPixelFormat.Depth32Float_Stencil8.rawValue {
            guard let probe = MTLPixelFormat(rawValue: i) else {
                continue
            }
            guard RenderStateDetailView.pixelFormatName(probe) != nil else {
                continue
            }
            if format == probe {
                return index
            }
            ++index
        }
        return 0
    }

    private class func pixelFormatName(format: MTLPixelFormat) -> String? {
        switch format {
        case .Invalid:
            return "Invalid"
        case .A8Unorm:
            return "A8Unorm"
        case .R8Unorm:
            return "R8Unorm"
        case .R8Snorm:
            return "R8Snorm"
        case .R8Uint:
            return "R8Uint"
        case .R8Sint:
            return "R8Sint"
        case .R16Unorm:
            return "R16Unorm"
        case .R16Snorm:
            return "R16Snorm"
        case .R16Uint:
            return "R16Uint"
        case .R16Sint:
            return "R16Sint"
        case .R16Float:
            return "R16Float"
        case .RG8Unorm:
            return "RG8Unorm"
        case .RG8Snorm:
            return "RG8Snorm"
        case .RG8Uint:
            return "RG8Uint"
        case .RG8Sint:
            return "RG8Sint"
        case .R32Uint:
            return "R32Uint"
        case .R32Sint:
            return "R32Sint"
        case .R32Float:
            return "R32Float"
        case .RG16Unorm:
            return "RG16Unorm"
        case .RG16Snorm:
            return "RG16Snorm"
        case .RG16Uint:
            return "RG16Uint"
        case .RG16Sint:
            return "RG16Sint"
        case .RG16Float:
            return "RG16Float"
        case .RGBA8Unorm:
            return "RGBA8Unorm"
        case .RGBA8Unorm_sRGB:
            return "RGBA8Unorm_sRGB"
        case .RGBA8Snorm:
            return "RGBA8Snorm"
        case .RGBA8Uint:
            return "RGBA8Uint"
        case .RGBA8Sint:
            return "RGBA8Sint"
        case .BGRA8Unorm:
            return "BGRA8Unorm"
        case .BGRA8Unorm_sRGB:
            return "BGRA8Unorm_sRGB"
        case .RGB10A2Unorm:
            return "RGB10A2Unorm"
        case .RGB10A2Uint:
            return "RGB10A2Uint"
        case .RG11B10Float:
            return "RG11B10Float"
        case .RGB9E5Float:
            return "RGB9E5Float"
        case .RG32Uint:
            return "RG32Uint"
        case .RG32Sint:
            return "RG32Sint"
        case .RG32Float:
            return "RG32Float"
        case .RGBA16Unorm:
            return "RGBA16Unorm"
        case .RGBA16Snorm:
            return "RGBA16Snorm"
        case .RGBA16Uint:
            return "RGBA16Uint"
        case .RGBA16Sint:
            return "RGBA16Sint"
        case .RGBA16Float:
            return "RGBA16Float"
        case .RGBA32Uint:
            return "RGBA32Uint"
        case .RGBA32Sint:
            return "RGBA32Sint"
        case .RGBA32Float:
            return "RGBA32Float"
        case .BC1_RGBA:
            return "BC1_RGBA"
        case .BC1_RGBA_sRGB:
            return "BC1_RGBA_sRGB"
        case .BC2_RGBA:
            return "BC2_RGBA"
        case .BC2_RGBA_sRGB:
            return "BC2_RGBA_sRGB"
        case .BC3_RGBA:
            return "BC3_RGBA"
        case .BC3_RGBA_sRGB:
            return "BC3_RGBA_sRGB"
        case .BC4_RUnorm:
            return "BC4_RUnorm"
        case .BC4_RSnorm:
            return "BC4_RSnorm"
        case .BC5_RGUnorm:
            return "BC5_RGUnorm"
        case .BC5_RGSnorm:
            return "BC5_RGSnorm"
        case .BC6H_RGBFloat:
            return "BC6H_RGBFloat"
        case .BC6H_RGBUfloat:
            return "BC6H_RGBUfloat"
        case .BC7_RGBAUnorm:
            return "BC7_RGBAUnorm"
        case .BC7_RGBAUnorm_sRGB:
            return "BC7_RGBAUnorm_sRGB"
        case .GBGR422:
            return "GBGR422"
        case .BGRG422:
            return "BGRG422"
        case .Depth32Float:
            return "Depth32Float"
        case .Stencil8:
            return "Stencil8"
        case .Depth24Unorm_Stencil8:
            return "Depth24Unorm_Stencil8"
        case .Depth32Float_Stencil8:
            return "Depth32Float_Stencil8"
        default:
            return nil
        }
    }

    private class func pixelFormatMenu() -> NSMenu {
        let result = NSMenu()
            result.addItem(NSMenuItem(title: "None", action: nil, keyEquivalent: ""))
        for i in MTLPixelFormat.A8Unorm.rawValue ... MTLPixelFormat.Depth32Float_Stencil8.rawValue {
            guard let format = MTLPixelFormat(rawValue: i) else {
                continue
            }
            guard let name = RenderStateDetailView.pixelFormatName(format) else {
                continue
            }
            result.addItem(NSMenuItem(title: name, action: nil, keyEquivalent: ""))
        }
        return result
    }

    private class func vertexFormatName(format: MTLVertexFormat) -> String {
        switch format {
        case .Invalid:
            return "Invalid"
        case .UChar2:
            return "UChar2"
        case .UChar3:
            return "UChar3"
        case .UChar4:
            return "UChar4"
        case .Char2:
            return "Char2"
        case .Char3:
            return "Char3"
        case .Char4:
            return "Char4"
        case .UChar2Normalized:
            return "UChar2Normalized"
        case .UChar3Normalized:
            return "UChar3Normalized"
        case .UChar4Normalized:
            return "UChar4Normalized"
        case .Char2Normalized:
            return "Char2Normalized"
        case .Char3Normalized:
            return "Char3Normalized"
        case .Char4Normalized:
            return "Char4Normalized"
        case .UShort2:
            return "UShort2"
        case .UShort3:
            return "UShort3"
        case .UShort4:
            return "UShort4"
        case .Short2:
            return "Short2"
        case .Short3:
            return "Short3"
        case .Short4:
            return "Short4"
        case .UShort2Normalized:
            return "UShort2Normalized"
        case .UShort3Normalized:
            return "UShort3Normalized"
        case .UShort4Normalized:
            return "UShort4Normalized"
        case .Short2Normalized:
            return "Short2Normalized"
        case .Short3Normalized:
            return "Short3Normalized"
        case .Short4Normalized:
            return "Short4Normalized"
        case .Half2:
            return "Half2"
        case .Half3:
            return "Half3"
        case .Half4:
            return "Half4"
        case .Float:
            return "Float"
        case .Float2:
            return "Float2"
        case .Float3:
            return "Float3"
        case .Float4:
            return "Float4"
        case .Int:
            return "Int"
        case .Int2:
            return "Int2"
        case .Int3:
            return "Int3"
        case .Int4:
            return "Int4"
        case .UInt:
            return "UInt"
        case .UInt2:
            return "UInt2"
        case .UInt3:
            return "UInt3"
        case .UInt4:
            return "UInt4"
        case .Int1010102Normalized:
            return "Int1010102Normalized"
        case .UInt1010102Normalized:
            return "UInt1010102Normalized"
        }
    }

    private class func vertexFormatMenu() -> NSMenu {
        let result = NSMenu()
        for i in MTLVertexFormat.UChar2.rawValue ... MTLVertexFormat.UInt1010102Normalized.rawValue {
            guard let format = MTLVertexFormat(rawValue: i) else {
                break
            }
            result.addItem(NSMenuItem(title: RenderStateDetailView.vertexFormatName(format), action: nil, keyEquivalent: ""))
        }
        return result
    }

    private class func vertexFormatToIndex(vertexFormat: MTLVertexFormat) -> Int {
        return Int(vertexFormat.rawValue - 1)
    }

    func tableView(tableView: NSTableView, viewForTableColumn tableColumn: NSTableColumn?, row: Int) -> NSView? {
        guard initialized else {
            return nil
        }
        guard let column = tableColumn else {
            return nil
        }

        // FIXME: Set target / action and validation
        switch tableView {
        case colorAttachmentTableView:
            let colorAttachment = state.colorAttachments[row] as! RenderPipelineColorAttachment
            switch column {
            case pixelFormatColumn:
                guard let result = tableView.makeViewWithIdentifier("PixelFormatPopUp", owner: self) as? NSTableCellView else {
                    return nil
                }
                guard result.subviews.count == 1 else {
                    return nil
                }
                guard let popUp = result.subviews[0] as? NSPopUpButton else {
                    return nil
                }
                popUp.menu = RenderStateDetailView.pixelFormatMenu()
                popUp.selectItemAtIndex(RenderStateDetailView.pixelFormatToIndex(RenderStateDetailView.numberToPixelFormat(colorAttachment.pixelFormat)))
                return result
            default:
                return nil
            }
        case vertexAttributesTableView:
            let vertexAttribute = state.vertexAttributes[row] as! VertexAttribute
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
                popUp.menu = RenderStateDetailView.vertexFormatMenu()
                popUp.selectItemAtIndex(RenderStateDetailView.vertexFormatToIndex(format))
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
                return nil
            }
        case vertexBufferLayoutsTableView:
            let vertexBufferLayout = state.vertexBufferLayouts[row] as! VertexBufferLayout
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
                guard let function = MTLVertexFormat(rawValue: vertexBufferLayout.stepFunction.unsignedLongValue) else {
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
                return nil
            }
        default:
            return nil
        }
    }
}
