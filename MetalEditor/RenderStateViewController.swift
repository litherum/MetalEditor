//
//  RenderStateViewController.swift
//  MetalEditor
//
//  Created by Litherum on 8/3/15.
//  Copyright © 2015 Litherum. All rights reserved.
//

import Cocoa

protocol VertexDescriptorObserver: class {
    func setVertexAttributeIndex(_ newValue: Int, vertexAttribute: VertexAttribute)
    func setVertexBufferLayoutIndex(_ newValue: Int, vertexBufferLayout: VertexBufferLayout)
    func setVertexAttributeBufferIndex(_ newValue: Int, vertexAttribute: VertexAttribute)
}

class RenderStateViewController: NSViewController, RenderStateColorAttachmentRemoveObserver, VertexDescriptorObserver {
    var managedObjectContext: NSManagedObjectContext!
    weak var modelObserver: ModelObserver!
    weak var removeObserver: RenderPipelineStateRemoveObserver!
    var state: RenderPipelineState!
    @IBOutlet var nameTextField: NSTextField!
    @IBOutlet var vertexFunctionTextField: NSTextField!
    @IBOutlet var fragmentFunctionTextField: NSTextField!
    @IBOutlet var vertexAttributesTableDelegate: VertexAttributesTableDelegate!
    @IBOutlet var vertexBufferLayoutTableDelegate: VertexBufferLayoutTableDelegate!
    @IBOutlet var vertexAttributesTableView: NSTableView!
    @IBOutlet var vertexBufferLayoutTableView: NSTableView!
    @IBOutlet var colorAttachmentsStackView: NSStackView!
    @IBOutlet var depthAttachmentPopUp: NSPopUpButton!
    @IBOutlet var stencilAttachmentPopUp: NSPopUpButton!
    @IBOutlet var sampleCountCheckBox: NSButton!
    @IBOutlet var sampleCountTextField: NSTextField!
    @IBOutlet var alphaToCoveragePopUp: NSButton!
    @IBOutlet var alphaToOnePopUp: NSButton!
    @IBOutlet var rasterizesPopUp: NSButton!
    @IBOutlet var inputPrimitiveTopologyPopUp: NSPopUpButton!

    init?(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?, managedObjectContext: NSManagedObjectContext, modelObserver: ModelObserver, state: RenderPipelineState, removeObserver: RenderPipelineStateRemoveObserver) {
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

        for attachmentObject in state.colorAttachments {
            addColorAttachmentView(attachmentObject as! RenderPipelineColorAttachment)
        }

        depthAttachmentPopUp.menu = pixelFormatMenu(true)
        if let depthAttachmentPixelFormat = state.depthAttachmentPixelFormat {
            let pixelFormat = MTLPixelFormat(rawValue: depthAttachmentPixelFormat.uintValue)!
            depthAttachmentPopUp.selectItem(at: pixelFormatToIndex(pixelFormat) + 1)
        } else {
            depthAttachmentPopUp.selectItem(at: 0)
        }

        stencilAttachmentPopUp.menu = pixelFormatMenu(true)
        if let stencilAttachmentPixelFormat = state.stencilAttachmentPixelFormat {
            if let pixelFormat = MTLPixelFormat(rawValue: stencilAttachmentPixelFormat.uintValue) {
                stencilAttachmentPopUp.selectItem(at: pixelFormatToIndex(pixelFormat) + 1)
            } else {
                stencilAttachmentPopUp.selectItem(at: 0)
            }
        } else {
            stencilAttachmentPopUp.selectItem(at: 0)
        }

        if let sampleCount = state.sampleCount {
            sampleCountCheckBox.state = NSOnState
            sampleCountTextField.integerValue = sampleCount.intValue
        } else {
            sampleCountCheckBox.state = NSOffState
            sampleCountTextField.isEnabled = false
            sampleCountTextField.stringValue = ""
        }

        vertexAttributesTableDelegate.managedObjectContext = managedObjectContext
        vertexAttributesTableDelegate.modelObserver = modelObserver
        vertexAttributesTableDelegate.indexObserver = self
        vertexAttributesTableDelegate.state = state

        vertexBufferLayoutTableDelegate.managedObjectContext = managedObjectContext
        vertexBufferLayoutTableDelegate.modelObserver = modelObserver
        vertexBufferLayoutTableDelegate.indexObserver = self
        vertexBufferLayoutTableDelegate.state = state

        alphaToCoveragePopUp.state = state.alphaToCoverageEnabled.boolValue ? NSOnState : NSOffState
        alphaToOnePopUp.state = state.alphaToOneEnabled.boolValue ? NSOnState : NSOffState
        rasterizesPopUp.state = state.rasterizationEnabled.boolValue ? NSOnState : NSOffState
        inputPrimitiveTopologyPopUp.selectItem(at: state.inputPrimitiveTopology.intValue)
    }

    @IBAction func setName(_ sender: NSTextField) {
        state.name = sender.stringValue
        modelObserver.modelDidChange()
    }

    @IBAction func setVertexFunction(_ sender: NSTextField) {
        state.vertexFunction = sender.stringValue
        modelObserver.modelDidChange()
    }

    @IBAction func setFragmentFunction(_ sender: NSTextField) {
        state.fragmentFunction = sender.stringValue
        modelObserver.modelDidChange()
    }

    fileprivate func insertRawVertexAttribute() -> VertexAttribute {
        let attributeCount = vertexAttributesTableDelegate.numberOfVertexAttributes()
        let attribute = NSEntityDescription.insertNewObject(forEntityName: "VertexAttribute", into: managedObjectContext) as! VertexAttribute
        attribute.format = NSNumber(value: MTLVertexFormat.float2.rawValue)
        attribute.offset = 0
        attribute.bufferIndex = 0
        attribute.id = NSNumber(attributeCount)
        attribute.index = NSNumber(findNewVertexAttributeIndex())
        return attribute
    }

    fileprivate func findNewVertexAttributeIndex() -> Int {
        var index = 0
        var found = false
        repeat {
            found = false
            for attributeObject in state.vertexAttributes {
                let attribute = attributeObject as! VertexAttribute
                if attribute.index.intValue == index {
                    found = true
                    index += 1
                    break
                }
            }
        } while (found);
        return index
    }

    fileprivate func insertRawVertexBufferLayout() -> VertexBufferLayout {
        let layoutCount = vertexBufferLayoutTableDelegate.numberOfVertexBufferLayouts()
        let layout = NSEntityDescription.insertNewObject(forEntityName: "VertexBufferLayout", into: managedObjectContext) as! VertexBufferLayout
        layout.stepFunction = NSNumber(value: MTLVertexStepFunction.perVertex.rawValue)
        layout.stepRate = 1
        layout.stride = 8
        layout.id = NSNumber(layoutCount)
        layout.index = NSNumber(findNewVertexBufferLayoutIndex())
        return layout
    }

    fileprivate func findNewVertexBufferLayoutIndex() -> Int {
        var index = 0
        var found = false
        repeat {
            found = false
            for layoutObject in state.vertexBufferLayouts {
                let layout = layoutObject as! VertexBufferLayout
                if layout.index.intValue == index {
                    found = true
                    index += 1
                    break
                }
            }
        } while (found);
        return index
    }

    @IBAction func addVertexAttribute(_ sender: NSButton) {
        let attribute = insertRawVertexAttribute()
        if state.vertexBufferLayouts.count == 0 {
            let layout = insertRawVertexBufferLayout()
            state.mutableOrderedSetValue(forKey: "vertexBufferLayouts").add(layout)
            vertexBufferLayoutTableView.reloadData()
        }
        attribute.bufferIndex = (state.vertexBufferLayouts[0] as AnyObject).index
        state.mutableOrderedSetValue(forKey: "vertexAttributes").add(attribute)
        
        vertexAttributesTableView.reloadData()
        modelObserver.modelDidChange()
    }

    @IBAction func removeVertexAttribute(_ sender: NSButton) {
        guard vertexAttributesTableView.selectedRow >= 0 else {
            return
        }
        let vertexAttribute = state.vertexAttributes[vertexAttributesTableView.selectedRow] as! VertexAttribute
        var found = false
        for vertexAttributeObject in state.vertexAttributes {
            let searchVertexAttribute = vertexAttributeObject as! VertexAttribute
            if searchVertexAttribute == vertexAttribute {
                continue
            }
            if searchVertexAttribute.bufferIndex == vertexAttribute.bufferIndex {
                found = true
                break
            }
        }
        if !found {
            for vertexBufferLayoutObject in state.vertexBufferLayouts {
                let vertexBufferLayout = vertexBufferLayoutObject as! VertexBufferLayout
                if vertexBufferLayout.index == vertexAttribute.bufferIndex {
                    managedObjectContext.delete(vertexBufferLayout)
                    vertexBufferLayoutTableView.reloadData()
                    break
                }
            }
        }
        managedObjectContext.delete(vertexAttribute)
        vertexAttributesTableView.reloadData()
        modelObserver.modelDidChange()
    }

    @IBAction func addVertexBufferLayout(_ sender: NSButton) {
        let layout = insertRawVertexBufferLayout()
        let attribute = insertRawVertexAttribute()
        attribute.bufferIndex = layout.index
        state.mutableOrderedSetValue(forKey: "vertexBufferLayouts").add(layout)
        state.mutableOrderedSetValue(forKey: "vertexAttributes").add(attribute)

        vertexBufferLayoutTableView.reloadData()
        vertexAttributesTableView.reloadData()
        modelObserver.modelDidChange()
    }

    @IBAction func removeVertexBufferLayout(_ sender: NSButton) {
        guard vertexBufferLayoutTableView.selectedRow >= 0 else {
            return
        }
        let vertexBufferLayout = state.vertexBufferLayouts[vertexBufferLayoutTableView.selectedRow] as! VertexBufferLayout
        var toRemove: [VertexAttribute] = []
        for vertexAttributeObject in state.vertexAttributes {
            let vertexAttribute = vertexAttributeObject as! VertexAttribute
            if vertexAttribute.bufferIndex == vertexBufferLayout.index {
                toRemove.append(vertexAttribute)
            }
        }
        for attribute in toRemove {
            managedObjectContext.delete(attribute)
        }
        managedObjectContext.delete(vertexBufferLayout)
        vertexBufferLayoutTableView.reloadData()
        vertexAttributesTableView.reloadData()
        modelObserver.modelDidChange()
    }

    func setVertexAttributeIndex(_ newValue: Int, vertexAttribute: VertexAttribute) {
        vertexAttribute.index = NSNumber(newValue)
        modelObserver.modelDidChange()
    }

    func setVertexAttributeBufferIndex(_ newValue: Int, vertexAttribute: VertexAttribute) {
        var found = false
        for vertexBufferLayoutObject in state.vertexBufferLayouts {
            let vertexBufferLayout = vertexBufferLayoutObject as! VertexBufferLayout
            if vertexBufferLayout.index.intValue == newValue {
                found = true
                break
            }
        }
        if !found {
            let layout = insertRawVertexBufferLayout()
            layout.index = NSNumber(newValue)
            state.mutableOrderedSetValue(forKey: "vertexBufferLayouts").add(layout)
            vertexBufferLayoutTableView.reloadData()
        }
        found = false
        for vertexAttributeObject in state.vertexAttributes {
            let searchVertexAttribute = vertexAttributeObject as! VertexAttribute
            if searchVertexAttribute != vertexAttribute && searchVertexAttribute.bufferIndex.intValue == vertexAttribute.bufferIndex.intValue {
                found = true
                break
            }
        }
        if !found {
            for vertexBufferLayoutObject in state.vertexBufferLayouts {
                let vertexBufferLayout = vertexBufferLayoutObject as! VertexBufferLayout
                if vertexBufferLayout.index == vertexAttribute.bufferIndex {
                    managedObjectContext.delete(vertexBufferLayout)
                    vertexBufferLayoutTableView.reloadData()
                    break
                }
            }
        }
        vertexAttribute.bufferIndex = NSNumber(newValue)
    }

    func setVertexBufferLayoutIndex(_ newValue: Int, vertexBufferLayout: VertexBufferLayout) {
        for vertexAttributeObject in state.vertexAttributes {
            let vertexAttribute = vertexAttributeObject as! VertexAttribute
            if vertexAttribute.bufferIndex.intValue == vertexBufferLayout.index.intValue {
                vertexAttribute.bufferIndex = NSNumber(newValue)
            }
        }
        vertexBufferLayout.index = NSNumber(newValue)
        vertexAttributesTableView.reloadData()
        modelObserver.modelDidChange()
    }

    func addColorAttachmentView(_ colorAttachment: RenderPipelineColorAttachment) {
        let controller = RenderStateColorAttachmentViewController(nibName: "RenderStateColorAttachmentView", bundle: nil, modelObserver: modelObserver, removeObserver: self, colorAttachment: colorAttachment)!
        addChildViewController(controller)
        colorAttachmentsStackView.addArrangedSubview(controller.view)
    }

    @IBAction func addColorAttachment(_ sender: NSButton) {
        let attachment = NSEntityDescription.insertNewObject(forEntityName: "RenderPipelineColorAttachment", into: managedObjectContext) as! RenderPipelineColorAttachment
        attachment.pixelFormat = nil
        attachment.writeAlpha = true
        attachment.writeRed = true
        attachment.writeGreen = true
        attachment.writeBlue = true
        attachment.blendingEnabled = true
        attachment.alphaBlendOperation = NSNumber(value: MTLBlendOperation.add.rawValue)
        attachment.rgbBlendOperation =  NSNumber(value: MTLBlendOperation.add.rawValue)
        attachment.destinationAlphaBlendFactor =  NSNumber(value: MTLBlendFactor.zero.rawValue)
        attachment.destinationRGBBlendFactor =  NSNumber(value: MTLBlendFactor.zero.rawValue)
        attachment.sourceAlphaBlendFactor =  NSNumber(value: MTLBlendFactor.one.rawValue)
        attachment.sourceRGBBlendFactor =  NSNumber(value: MTLBlendFactor.one.rawValue)
        state.mutableOrderedSetValue(forKey: "colorAttachments").add(attachment)
        addColorAttachmentView(attachment)
        modelObserver.modelDidChange()
    }

    func remove(_ viewController: RenderStateColorAttachmentViewController) {
        for i in 0 ..< childViewControllers.count {
            if childViewControllers[i] == viewController {
                childViewControllers.remove(at: i)
                break
            }
        }
        viewController.view.removeFromSuperview()
        state.mutableOrderedSetValue(forKey: "colorAttachments").remove(viewController.colorAttachment)
        managedObjectContext.delete(viewController.colorAttachment)
        modelObserver.modelDidChange()
    }

    @IBAction func depthAttachmentSelected(_ sender: NSPopUpButton) {
        assert(sender.indexOfSelectedItem >= 0)
        guard sender.indexOfSelectedItem > 0 else {
            state.depthAttachmentPixelFormat = nil
            return
        }
        let format = indexToPixelFormat(sender.indexOfSelectedItem - 1)!
        state.depthAttachmentPixelFormat =  NSNumber(value: format.rawValue)
        modelObserver.modelDidChange()
    }

    @IBAction func stencilAttachmentSelected(_ sender: NSPopUpButton) {
        assert(sender.indexOfSelectedItem >= 0)
        guard sender.indexOfSelectedItem > 0 else {
            state.depthAttachmentPixelFormat = nil
            return
        }
        let format = indexToPixelFormat(sender.indexOfSelectedItem - 1)!
        state.stencilAttachmentPixelFormat =  NSNumber(value: format.rawValue)
        modelObserver.modelDidChange()
    }

    @IBAction func sampleCountEnabled(_ sender: NSButton) {
        if sender.state == NSOnState {
            state.sampleCount = 1
            sampleCountTextField.integerValue = 1
            sampleCountTextField.isEnabled = true
        } else {
            assert(sender.state == NSOffState)
            state.sampleCount = nil
            sampleCountTextField.stringValue = ""
            sampleCountTextField.isEnabled = false
        }
        modelObserver.modelDidChange()
    }

    @IBAction func sampleCountSet(_ sender: NSTextField) {
        state.sampleCount = sender.integerValue as NSNumber
        modelObserver.modelDidChange()
    }

    @IBAction func removeRenderPipelineState(_ sender: NSButton) {
        removeObserver.removeRenderPipelineState(self)
    }

    @IBAction func setAlphaToCoverage(_ sender: NSButton) {
        state.alphaToCoverageEnabled = NSNumber(value: sender.state == NSOnState)
        modelObserver.modelDidChange()
    }

    @IBAction func setAlphaToOne(_ sender: NSButton) {
        state.alphaToOneEnabled = NSNumber(value: sender.state == NSOnState)
        modelObserver.modelDidChange()
    }

    @IBAction func setRasterizes(_ sender: NSButton) {
        state.rasterizationEnabled = NSNumber(value: sender.state == NSOnState)
        modelObserver.modelDidChange()
    }

    @IBAction func inputPrimitiveTopologySelected(_ sender: NSPopUpButton) {
        state.inputPrimitiveTopology = NSNumber(sender.indexOfSelectedItem)
        assert(state.inputPrimitiveTopology.intValue >= 0 && state.inputPrimitiveTopology.intValue <= 3)
        modelObserver.modelDidChange()
    }

}
