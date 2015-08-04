//
//  RenderStateViewController.swift
//  MetalEditor
//
//  Created by Litherum on 8/3/15.
//  Copyright © 2015 Litherum. All rights reserved.
//

import Cocoa

private func numberToPixelFormat(pixelFormat: NSNumber?) -> MTLPixelFormat? {
    guard let number = pixelFormat else {
        return nil
    }
    return MTLPixelFormat(rawValue: number.unsignedLongValue)
}

private func pixelFormatToIndex(pixelFormat: MTLPixelFormat?) -> Int {
    guard let format = pixelFormat else {
        return 0
    }
    // Suuuuuuuper slow
    var index = 0
    for i in MTLPixelFormat.A8Unorm.rawValue ... MTLPixelFormat.Depth32Float_Stencil8.rawValue {
        guard let probe = MTLPixelFormat(rawValue: i) else {
            continue
        }
        guard pixelFormatName(probe) != nil else {
            continue
        }
        if format == probe {
            return index
        }
        ++index
    }
    return 0
}

private func pixelFormatName(format: MTLPixelFormat) -> String? {
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

private func pixelFormatMenu() -> NSMenu {
    let result = NSMenu()
        result.addItem(NSMenuItem(title: "None", action: nil, keyEquivalent: ""))
    for i in MTLPixelFormat.A8Unorm.rawValue ... MTLPixelFormat.Depth32Float_Stencil8.rawValue {
        guard let format = MTLPixelFormat(rawValue: i) else {
            continue
        }
        guard let name = pixelFormatName(format) else {
            continue
        }
        result.addItem(NSMenuItem(title: name, action: nil, keyEquivalent: ""))
    }
    return result
}

private func vertexFormatName(format: MTLVertexFormat) -> String {
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

private func vertexFormatMenu() -> NSMenu {
    let result = NSMenu()
    for i in MTLVertexFormat.UChar2.rawValue ... MTLVertexFormat.UInt1010102Normalized.rawValue {
        guard let format = MTLVertexFormat(rawValue: i) else {
            break
        }
        result.addItem(NSMenuItem(title: vertexFormatName(format), action: nil, keyEquivalent: ""))
    }
    return result
}

private func vertexFormatToIndex(vertexFormat: MTLVertexFormat) -> Int {
    return Int(vertexFormat.rawValue - 1)
}

class VertexAttributesTableDelegate: NSObject, NSTableViewDelegate, NSTableViewDataSource {
    var managedObjectContext: NSManagedObjectContext!
    weak var modelObserver: ModelObserver!
    var state: RenderPipelineState!
    @IBOutlet var formatColumn: NSTableColumn!
    @IBOutlet var offsetColumn: NSTableColumn!
    @IBOutlet var bufferIndexColumn: NSTableColumn!

    func numberOfVertexAttributes() -> Int {
        let fetchRequest = NSFetchRequest(entityName: "VertexAttribute")
        var error: NSError?
        let result = managedObjectContext.countForFetchRequest(fetchRequest, error: &error)
        assert(error == nil)
        return result
    }

    func numberOfRowsInTableView(tableView: NSTableView) -> Int {
        return numberOfVertexAttributes()
    }

    func getVertexAttribute(index: Int) -> VertexAttribute? {
        let fetchRequest = NSFetchRequest(entityName: "VertexAttribute")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "id", ascending: true)]
        // <rdar://problem/22108925> managedObjectContext.executeFetchRequest() crashes if you add two objects.
        // FIXME: This is a hack.
        //fetchRequest.fetchLimit = 1
        //fetchRequest.fetchOffset = index
        
        do {
            let attributes = try managedObjectContext.executeFetchRequest(fetchRequest) as! [VertexAttribute]
            if attributes.count < index {
                return nil
            }
            return attributes[index]
        } catch {
            return nil
        }
    }

    func tableView(tableView: NSTableView, viewForTableColumn tableColumn: NSTableColumn?, row: Int) -> NSView? {
        guard let column = tableColumn else {
            return nil
        }
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
            return nil
        }
    }
}

class VertexBufferLayoutTableDelegate: NSObject, NSTableViewDelegate, NSTableViewDataSource {
    var managedObjectContext: NSManagedObjectContext!
    weak var modelObserver: ModelObserver!
    var state: RenderPipelineState!
    @IBOutlet var stepFunctionColumn: NSTableColumn!
    @IBOutlet var stepRateColumn: NSTableColumn!
    @IBOutlet weak var strideColumn: NSTableColumn!

    func numberOfVertexBufferLayouts() -> Int {
        let fetchRequest = NSFetchRequest(entityName: "VertexBufferLayout")
        var error: NSError?
        let result = managedObjectContext.countForFetchRequest(fetchRequest, error: &error)
        assert(error == nil)
        return result
    }

    func numberOfRowsInTableView(tableView: NSTableView) -> Int {
        return numberOfVertexBufferLayouts()
    }

    func getVertexBufferLayout(index: Int) -> VertexBufferLayout? {
        let fetchRequest = NSFetchRequest(entityName: "VertexBufferLayout")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "id", ascending: true)]
        // <rdar://problem/22108925> managedObjectContext.executeFetchRequest() crashes if you add two objects.
        // FIXME: This is a hack.
        //fetchRequest.fetchLimit = 1
        //fetchRequest.fetchOffset = index
        
        do {
            let layouts = try managedObjectContext.executeFetchRequest(fetchRequest) as! [VertexBufferLayout]
            if layouts.count < index {
                return nil
            }
            return layouts[index]
        } catch {
            return nil
        }
    }

    func tableView(tableView: NSTableView, viewForTableColumn tableColumn: NSTableColumn?, row: Int) -> NSView? {
        guard let column = tableColumn else {
            return nil
        }
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
    }
}

class ColorAttachmentsTableDelegate: NSObject, NSTableViewDelegate, NSTableViewDataSource {
    var managedObjectContext: NSManagedObjectContext!
    weak var modelObserver: ModelObserver!
    var state: RenderPipelineState!
    @IBOutlet var pixelFormatColumn: NSTableColumn!

    func numberOfColorAttachments() -> Int {
        let fetchRequest = NSFetchRequest(entityName: "RenderPipelineColorAttachment")
        var error: NSError?
        let result = managedObjectContext.countForFetchRequest(fetchRequest, error: &error)
        assert(error == nil)
        return result
    }

    func numberOfRowsInTableView(tableView: NSTableView) -> Int {
        return numberOfColorAttachments()
    }

    func getColorAttachment(index: Int) -> RenderPipelineColorAttachment? {
        let fetchRequest = NSFetchRequest(entityName: "RenderPipelineColorAttachment")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "id", ascending: true)]
        // <rdar://problem/22108925> managedObjectContext.executeFetchRequest() crashes if you add two objects.
        // FIXME: This is a hack.
        //fetchRequest.fetchLimit = 1
        //fetchRequest.fetchOffset = index
        
        do {
            let attachments = try managedObjectContext.executeFetchRequest(fetchRequest) as! [RenderPipelineColorAttachment]
            if attachments.count < index {
                return nil
            }
            return attachments[index]
        } catch {
            return nil
        }
    }

    func tableView(tableView: NSTableView, viewForTableColumn tableColumn: NSTableColumn?, row: Int) -> NSView? {
        guard let column = tableColumn else {
            return nil
        }
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
            popUp.menu = pixelFormatMenu()
            popUp.selectItemAtIndex(pixelFormatToIndex(numberToPixelFormat(colorAttachment.pixelFormat)))
            return result
        default:
            return nil
        }
    }
}

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

        depthAttachmentPopUp.menu = pixelFormatMenu()
        stencilAttachmentPopUp.menu = pixelFormatMenu()
        // FIXME: Set depthAttachmentPopUp and stencilAttachmentPopUp

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
        if sender.selectedSegment == 0 {
            // Add
            let attributeCount = vertexAttributesTableDelegate.numberOfVertexAttributes()
            let attribute = NSEntityDescription.insertNewObjectForEntityForName("VertexAttribute", inManagedObjectContext: managedObjectContext) as! VertexAttribute
            attribute.format = MTLVertexFormat.Float2.rawValue
            attribute.offset = 0
            attribute.bufferIndex = 0
            attribute.id = attributeCount
            state.mutableOrderedSetValueForKey("vertexAttributes").addObject(attribute)
        } else {
            assert(sender.selectedSegment == 1)
            // Remove
            for index in vertexAttributesTableView.selectedRowIndexes {
                // FIXME: These deletion loops don't quite work
                managedObjectContext.deleteObject(state.vertexAttributes[index] as! NSManagedObject)
            }
        }
        vertexAttributesTableView.reloadData()
        modelObserver.modelDidChange()
        sender.selectedSegment = -1
    }

    @IBAction func addRemoveVertexBufferLayout(sender: NSSegmentedControl) {
        if sender.selectedSegment == 0 {
            // Add
            let layoutCount = vertexBufferLayoutTableDelegate.numberOfVertexBufferLayouts()
            let layout = NSEntityDescription.insertNewObjectForEntityForName("VertexBufferLayout", inManagedObjectContext: managedObjectContext) as! VertexBufferLayout
            layout.stepFunction = MTLVertexStepFunction.PerVertex.rawValue
            layout.stepRate = 1
            layout.stride = 8
            layout.id = layoutCount
            state.mutableOrderedSetValueForKey("vertexBufferLayouts").addObject(layout)
        } else {
            assert(sender.selectedSegment == 1)
            // Remove
            for index in vertexBufferLayoutTableView.selectedRowIndexes {
                managedObjectContext.deleteObject(state.vertexBufferLayouts[index] as! NSManagedObject)
            }
        }
        vertexBufferLayoutTableView.reloadData()
        modelObserver.modelDidChange()
        sender.selectedSegment = -1
    }

    @IBAction func addRemoveColorAttachment(sender: NSSegmentedControl) {
        if sender.selectedSegment == 0 {
            // Add
            let attachmentCount = colorAttachmentsTableDelegate.numberOfColorAttachments()
            let attachment = NSEntityDescription.insertNewObjectForEntityForName("RenderPipelineColorAttachment", inManagedObjectContext: managedObjectContext) as! RenderPipelineColorAttachment
            attachment.pixelFormat = nil
            attachment.id = attachmentCount
            state.mutableOrderedSetValueForKey("colorAttachments").addObject(attachment)
        } else {
            assert(sender.selectedSegment == 1)
            // Remove
            for index in colorAttachmentsTableView.selectedRowIndexes {
                managedObjectContext.deleteObject(state.colorAttachments[index] as! NSManagedObject)
            }
        }
        colorAttachmentsTableView.reloadData()
        modelObserver.modelDidChange()
        sender.selectedSegment = -1
    }

    @IBAction func depthAttachmentSelected(sender: NSPopUpButton) {
        // FIXME: Implement this
        state.depthAttachmentPixelFormat = nil
        modelObserver.modelDidChange()
    }

    @IBAction func stencilAttachmentSelected(sender: NSPopUpButton) {
        // FIXME: Implement this
        state.stencilAttachmentPixelFormat = nil
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
