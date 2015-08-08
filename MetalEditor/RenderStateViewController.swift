//
//  RenderStateViewController.swift
//  MetalEditor
//
//  Created by Litherum on 8/3/15.
//  Copyright © 2015 Litherum. All rights reserved.
//

import Cocoa

let pixelFormatMenuOrder: [MTLPixelFormat] = [.Invalid, .A8Unorm, .R8Unorm, .R8Snorm, .R8Uint, .R8Sint, .R16Unorm, .R16Snorm, .R16Uint, .R16Sint, .R16Float, .RG8Unorm, .RG8Snorm, .RG8Uint, .RG8Sint, .R32Uint, .R32Sint, .R32Float, .RG16Unorm, .RG16Snorm, .RG16Uint, .RG16Sint, .RG16Float, .RGBA8Unorm, .RGBA8Unorm_sRGB, .RGBA8Snorm, .RGBA8Uint, .RGBA8Sint, .BGRA8Unorm, .BGRA8Unorm_sRGB, .RGB10A2Unorm, .RGB10A2Uint, .RG11B10Float, .RGB9E5Float, .RG32Uint, .RG32Sint, .RG32Float, .RGBA16Unorm, .RGBA16Snorm, .RGBA16Uint, .RGBA16Sint, .RGBA16Float, .RGBA32Uint, .RGBA32Sint, .RGBA32Float, .BC1_RGBA, .BC1_RGBA_sRGB, .BC2_RGBA, .BC2_RGBA_sRGB, .BC3_RGBA, .BC3_RGBA_sRGB, .BC4_RUnorm, .BC4_RSnorm, .BC5_RGUnorm, .BC5_RGSnorm, .BC6H_RGBFloat, .BC6H_RGBUfloat, .BC7_RGBAUnorm, .BC7_RGBAUnorm_sRGB, .GBGR422, .BGRG422, .Depth32Float, .Stencil8, .Depth24Unorm_Stencil8, .Depth32Float_Stencil8]

let pixelFormatNameMap: [MTLPixelFormat : String] = [.Invalid: "Invalid", .A8Unorm: "A8Unorm", .R8Unorm: "R8Unorm", .R8Snorm: "R8Snorm", .R8Uint: "R8Uint", .R8Sint: "R8Sint", .R16Unorm: "R16Unorm", .R16Snorm: "R16Snorm", .R16Uint: "R16Uint", .R16Sint: "R16Sint", .R16Float: "R16Float", .RG8Unorm: "RG8Unorm", .RG8Snorm: "RG8Snorm", .RG8Uint: "RG8Uint", .RG8Sint: "RG8Sint", .R32Uint: "R32Uint", .R32Sint: "R32Sint", .R32Float: "R32Float", .RG16Unorm: "RG16Unorm", .RG16Snorm: "RG16Snorm", .RG16Uint: "RG16Uint", .RG16Sint: "RG16Sint", .RG16Float: "RG16Float", .RGBA8Unorm: "RGBA8Unorm", .RGBA8Unorm_sRGB: "RGBA8Unorm_sRGB", .RGBA8Snorm: "RGBA8Snorm", .RGBA8Uint: "RGBA8Uint", .RGBA8Sint: "RGBA8Sint", .BGRA8Unorm: "BGRA8Unorm", .BGRA8Unorm_sRGB: "BGRA8Unorm_sRGB", .RGB10A2Unorm: "RGB10A2Unorm", .RGB10A2Uint: "RGB10A2Uint", .RG11B10Float: "RG11B10Float", .RGB9E5Float: "RGB9E5Float", .RG32Uint: "RG32Uint", .RG32Sint: "RG32Sint", .RG32Float: "RG32Float", .RGBA16Unorm: "RGBA16Unorm", .RGBA16Snorm: "RGBA16Snorm", .RGBA16Uint: "RGBA16Uint", .RGBA16Sint: "RGBA16Sint", .RGBA16Float: "RGBA16Float", .RGBA32Uint: "RGBA32Uint", .RGBA32Sint: "RGBA32Sint", .RGBA32Float: "RGBA32Float", .BC1_RGBA: "BC1_RGBA", .BC1_RGBA_sRGB: "BC1_RGBA_sRGB", .BC2_RGBA: "BC2_RGBA", .BC2_RGBA_sRGB: "BC2_RGBA_sRGB", .BC3_RGBA: "BC3_RGBA", .BC3_RGBA_sRGB: "BC3_RGBA_sRGB", .BC4_RUnorm: "BC4_RUnorm", .BC4_RSnorm: "BC4_RSnorm", .BC5_RGUnorm: "BC5_RGUnorm", .BC5_RGSnorm: "BC5_RGSnorm", .BC6H_RGBFloat: "BC6H_RGBFloat", .BC6H_RGBUfloat: "BC6H_RGBUfloat", .BC7_RGBAUnorm: "BC7_RGBAUnorm", .BC7_RGBAUnorm_sRGB: "BC7_RGBAUnorm_sRGB", .GBGR422: "GBGR422", .BGRG422: "BGRG422", .Depth32Float: "Depth32Float", .Stencil8: "Stencil8", .Depth24Unorm_Stencil8: "Depth24Unorm_Stencil8", .Depth32Float_Stencil8: "Depth32Float_Stencil8"]

class RenderStateViewController: NSViewController, NSTextFieldDelegate {
    var managedObjectContext: NSManagedObjectContext!
    weak var modelObserver: ModelObserver!
    weak var removeObserver: RenderPipelineStateRemoveObserver!
    var state: RenderPipelineState!
    @IBOutlet var nameTextField: NSTextField!
    @IBOutlet var vertexFunctionTextField: NSTextField!
    @IBOutlet var fragmentFunctionTextField: NSTextField!
    @IBOutlet var vertexAttributesTableDelegate: VertexAttributesTableDelegate!
    @IBOutlet var vertexBufferLayoutTableDelegate: VertexBufferLayoutTableDelegate!
    @IBOutlet var colorAttachmentsTableDelegate: ColorAttachmentsTableDelegate!
    @IBOutlet var vertexAttributesTableView: NSTableView!
    @IBOutlet var vertexBufferLayoutTableView: NSTableView!
    @IBOutlet var colorAttachmentsTableView: NSTableView!
    @IBOutlet var depthAttachmentPopUp: NSPopUpButton!
    @IBOutlet var stencilAttachmentPopUp: NSPopUpButton!
    @IBOutlet var sampleCountCheckBox: NSButton!
    @IBOutlet var sampleCountTextField: NSTextField!

    class func pixelFormatMenu(includeNone: Bool) -> NSMenu {
        let result = NSMenu()
        if (includeNone) {
            result.addItem(NSMenuItem(title: "None", action: nil, keyEquivalent: ""))
        }
        for i in MTLPixelFormat.Invalid.rawValue ... MTLPixelFormat.Depth32Float_Stencil8.rawValue {
            guard let format = MTLPixelFormat(rawValue: i) else {
                continue
            }
            guard let name = pixelFormatNameMap[format] else {
                continue
            }
            result.addItem(NSMenuItem(title: name, action: nil, keyEquivalent: ""))
        }
        return result
    }

    class func pixelFormatToIndex(pixelFormat: MTLPixelFormat) -> Int {
        for i in 0 ..< pixelFormatMenuOrder.count {
            if pixelFormatMenuOrder[i] == pixelFormat {
                return i
            }
        }
        return 0
    }

    class func indexToPixelFormat(i: Int) -> MTLPixelFormat? {
        guard i > 0 && i < pixelFormatMenuOrder.count else {
            return nil
        }
        return pixelFormatMenuOrder[i]
    }

    init?(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?, managedObjectContext: NSManagedObjectContext, modelObserver: ModelObserver, state: RenderPipelineState, removeObserver: RenderPipelineStateRemoveObserver) {
        self.managedObjectContext = managedObjectContext
        self.modelObserver = modelObserver
        self.state = state
        self.removeObserver = removeObserver
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        nameTextField.stringValue = state.name
        vertexFunctionTextField.stringValue = state.vertexFunction
        fragmentFunctionTextField.stringValue = state.fragmentFunction

        depthAttachmentPopUp.menu = RenderStateViewController.pixelFormatMenu(true)
        if let depthAttachmentPixelFormat = state.depthAttachmentPixelFormat {
            guard let pixelFormat = MTLPixelFormat(rawValue: depthAttachmentPixelFormat.unsignedLongValue) else {
                fatalError()
            }
            depthAttachmentPopUp.selectItemAtIndex(RenderStateViewController.pixelFormatToIndex(pixelFormat) + 1)
        } else {
            depthAttachmentPopUp.selectItemAtIndex(0)
        }

        stencilAttachmentPopUp.menu = RenderStateViewController.pixelFormatMenu(true)
        if let stencilAttachmentPixelFormat = state.stencilAttachmentPixelFormat {
            if let pixelFormat = MTLPixelFormat(rawValue: stencilAttachmentPixelFormat.unsignedLongValue) {
                stencilAttachmentPopUp.selectItemAtIndex(RenderStateViewController.pixelFormatToIndex(pixelFormat) + 1)
            } else {
                stencilAttachmentPopUp.selectItemAtIndex(0)
            }
        } else {
            stencilAttachmentPopUp.selectItemAtIndex(0)
        }

        if let sampleCount = state.sampleCount {
            sampleCountCheckBox.state = NSOnState
            sampleCountTextField.integerValue = sampleCount.integerValue
        } else {
            sampleCountCheckBox.state = NSOffState
            sampleCountTextField.enabled = false
            sampleCountTextField.stringValue = ""
        }

        vertexAttributesTableDelegate.managedObjectContext = managedObjectContext
        vertexAttributesTableDelegate.modelObserver = modelObserver
        vertexAttributesTableDelegate.state = state

        vertexBufferLayoutTableDelegate.managedObjectContext = managedObjectContext
        vertexBufferLayoutTableDelegate.modelObserver = modelObserver
        vertexBufferLayoutTableDelegate.state = state

        colorAttachmentsTableDelegate.managedObjectContext = managedObjectContext
        colorAttachmentsTableDelegate.modelObserver = modelObserver
        colorAttachmentsTableDelegate.state = state
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

    @IBAction func addRemoveVertexAttribute(sender: NSSegmentedControl) {
        if sender.selectedSegment == 0 { // Add
            vertexAttributesTableDelegate.addVertexAttribute()
        } else { // Remove
            assert(sender.selectedSegment == 1)
            vertexAttributesTableDelegate.removeSelectedVertexAttribute()
        }
        vertexAttributesTableView.reloadData()
        modelObserver.modelDidChange()
        sender.selectedSegment = -1
    }

    @IBAction func addRemoveVertexBufferLayout(sender: NSSegmentedControl) {
        if sender.selectedSegment == 0 { // Add
            vertexBufferLayoutTableDelegate.addVertexBufferLayout()
        } else { // Remove
            assert(sender.selectedSegment == 1)
            vertexBufferLayoutTableDelegate.removeSelectedVertexBufferLayout()
        }
        vertexBufferLayoutTableView.reloadData()
        modelObserver.modelDidChange()
        sender.selectedSegment = -1
    }

    @IBAction func addRemoveColorAttachment(sender: NSSegmentedControl) {
        if sender.selectedSegment == 0 { // Add
            colorAttachmentsTableDelegate.addColorAttachment()
        } else { // Remove
            assert(sender.selectedSegment == 1)
            colorAttachmentsTableDelegate.removeSelectedColorAttachment()
        }
        colorAttachmentsTableView.reloadData()
        modelObserver.modelDidChange()
        sender.selectedSegment = -1
    }

    @IBAction func depthAttachmentSelected(sender: NSPopUpButton) {
        guard sender.indexOfSelectedItem >= 0 else {
            return
        }
        guard sender.indexOfSelectedItem > 0 else {
            state.depthAttachmentPixelFormat = nil
            return
        }
        guard let format = RenderStateViewController.indexToPixelFormat(sender.indexOfSelectedItem - 1) else {
            fatalError()
        }
        state.depthAttachmentPixelFormat = format.rawValue
        modelObserver.modelDidChange()
    }

    @IBAction func stencilAttachmentSelected(sender: NSPopUpButton) {
        guard sender.indexOfSelectedItem >= 0 else {
            return
        }
        guard sender.indexOfSelectedItem > 0 else {
            state.depthAttachmentPixelFormat = nil
            return
        }
        guard let format = RenderStateViewController.indexToPixelFormat(sender.indexOfSelectedItem - 1) else {
            return
        }
        state.stencilAttachmentPixelFormat = format.rawValue
        modelObserver.modelDidChange()
    }

    @IBAction func sampleCountEnabled(sender: NSButton) {
        if sender.state == NSOnState {
            state.sampleCount = 1
            sampleCountTextField.integerValue = 1
            sampleCountTextField.enabled = true
        } else {
            assert(sender.state == NSOffState)
            state.sampleCount = nil
            sampleCountTextField.stringValue = ""
            sampleCountTextField.enabled = false
        }
        modelObserver.modelDidChange()
    }

    func control(control: NSControl, isValidObject obj: AnyObject) -> Bool {
        if let s = obj as? String {
            if Int(s) != nil {
                return true
            }
        }
        return false
    }

    @IBAction func sampleCountSet(sender: NSTextField) {
        state.sampleCount = sender.integerValue
        modelObserver.modelDidChange()
    }

    @IBAction func remove(sender: NSButton) {
        removeObserver.removeRenderPipelineState(self)
    }

}
