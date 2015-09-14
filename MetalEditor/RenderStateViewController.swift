//
//  RenderStateViewController.swift
//  MetalEditor
//
//  Created by Litherum on 8/3/15.
//  Copyright © 2015 Litherum. All rights reserved.
//

import Cocoa

class RenderStateViewController: NSViewController, RenderStateColorAttachmentRemoveObserver {
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

        for attachmentObject in state.colorAttachments {
            addColorAttachmentView(attachmentObject as! RenderPipelineColorAttachment)
        }

        depthAttachmentPopUp.menu = pixelFormatMenu(true)
        if let depthAttachmentPixelFormat = state.depthAttachmentPixelFormat {
            let pixelFormat = MTLPixelFormat(rawValue: depthAttachmentPixelFormat.unsignedLongValue)!
            depthAttachmentPopUp.selectItemAtIndex(pixelFormatToIndex(pixelFormat) + 1)
        } else {
            depthAttachmentPopUp.selectItemAtIndex(0)
        }

        stencilAttachmentPopUp.menu = pixelFormatMenu(true)
        if let stencilAttachmentPixelFormat = state.stencilAttachmentPixelFormat {
            if let pixelFormat = MTLPixelFormat(rawValue: stencilAttachmentPixelFormat.unsignedLongValue) {
                stencilAttachmentPopUp.selectItemAtIndex(pixelFormatToIndex(pixelFormat) + 1)
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

        alphaToCoveragePopUp.state = state.alphaToCoverageEnabled.boolValue ? NSOnState : NSOffState
        alphaToOnePopUp.state = state.alphaToOneEnabled.boolValue ? NSOnState : NSOffState
        rasterizesPopUp.state = state.rasterizationEnabled.boolValue ? NSOnState : NSOffState
        inputPrimitiveTopologyPopUp.selectItemAtIndex(state.inputPrimitiveTopology.integerValue)
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

    private func insertRawVertexAttribute() -> VertexAttribute {
        let attributeCount = vertexAttributesTableDelegate.numberOfVertexAttributes()
        let attribute = NSEntityDescription.insertNewObjectForEntityForName("VertexAttribute", inManagedObjectContext: managedObjectContext) as! VertexAttribute
        attribute.format = MTLVertexFormat.Float2.rawValue
        attribute.offset = 0
        attribute.bufferIndex = 0
        attribute.id = attributeCount
        attribute.index = findNewVertexAttributeIndex()
        return attribute
    }

    private func findNewVertexAttributeIndex() -> Int {
        var index = 0
        var found = false
        repeat {
            found = false
            for attributeObject in state.vertexAttributes {
                let attribute = attributeObject as! VertexAttribute
                if attribute.index == index {
                    found = true
                    ++index
                    break
                }
            }
        } while (found);
        return index
    }

    private func insertRawVertexBufferLayout() -> VertexBufferLayout {
        let layoutCount = vertexBufferLayoutTableDelegate.numberOfVertexBufferLayouts()
        let layout = NSEntityDescription.insertNewObjectForEntityForName("VertexBufferLayout", inManagedObjectContext: managedObjectContext) as! VertexBufferLayout
        layout.stepFunction = MTLVertexStepFunction.PerVertex.rawValue
        layout.stepRate = 1
        layout.stride = 8
        layout.id = layoutCount
        layout.index = findNewVertexBufferLayoutIndex()
        return layout
    }

    private func findNewVertexBufferLayoutIndex() -> Int {
        var index = 0
        var found = false
        repeat {
            found = false
            for layoutObject in state.vertexBufferLayouts {
                let layout = layoutObject as! VertexBufferLayout
                if layout.index == index {
                    found = true
                    ++index
                    break
                }
            }
        } while (found);
        return index
    }

    @IBAction func addVertexAttribute(sender: NSButton) {
        let attribute = insertRawVertexAttribute()
        if state.vertexBufferLayouts.count == 0 {
            let layout = insertRawVertexBufferLayout()
            state.mutableOrderedSetValueForKey("vertexBufferLayouts").addObject(layout)
            vertexBufferLayoutTableView.reloadData()
        }
        attribute.bufferIndex = state.vertexBufferLayouts[0].index
        state.mutableOrderedSetValueForKey("vertexAttributes").addObject(attribute)
        
        vertexAttributesTableView.reloadData()
        modelObserver.modelDidChange()
    }

    @IBAction func removeVertexAttribute(sender: NSButton) {
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
                    managedObjectContext.deleteObject(vertexBufferLayout)
                    vertexBufferLayoutTableView.reloadData()
                    break
                }
            }
        }
        managedObjectContext.deleteObject(vertexAttribute)
        vertexAttributesTableView.reloadData()
        modelObserver.modelDidChange()
    }

    @IBAction func addVertexBufferLayout(sender: NSButton) {
        let layout = insertRawVertexBufferLayout()
        let attribute = insertRawVertexAttribute()
        attribute.bufferIndex = layout.index
        state.mutableOrderedSetValueForKey("vertexBufferLayouts").addObject(layout)
        state.mutableOrderedSetValueForKey("vertexAttributes").addObject(attribute)

        vertexBufferLayoutTableView.reloadData()
        vertexAttributesTableView.reloadData()
        modelObserver.modelDidChange()
    }

    @IBAction func removeVertexBufferLayout(sender: NSButton) {
        guard vertexBufferLayoutTableView.selectedRow >= 0 else {
            return
        }
        let vertexBufferLayout = state.vertexBufferLayouts[vertexBufferLayoutTableView.selectedRow] as! VertexBufferLayout
        var toRemove: [VertexAttribute] = []
        for vertexAttributeObject in state.vertexAttributes {
            let vertexAttribute = vertexAttributeObject as! VertexAttribute
            if vertexAttribute.bufferIndex.integerValue == vertexBufferLayout.index {
                toRemove.append(vertexAttribute)
            }
        }
        for attribute in toRemove {
            managedObjectContext.deleteObject(attribute)
        }
        managedObjectContext.deleteObject(vertexBufferLayout)
        vertexBufferLayoutTableView.reloadData()
        vertexAttributesTableView.reloadData()
        modelObserver.modelDidChange()
    }

    @IBAction func setVertexAttributeIndex(sender: NSTextField) {
        let row = vertexAttributesTableView.rowForView(sender)
        let vertexAttribute = state.vertexAttributes[row] as! VertexAttribute
        vertexAttribute.index = sender.integerValue
        modelObserver.modelDidChange()
    }

    @IBAction func setVertexBufferLayoutIndex(sender: NSTextField) {
        let row = vertexBufferLayoutTableView.rowForView(sender)
        let vertexBufferLayout = state.vertexBufferLayouts[row] as! VertexBufferLayout
        for vertexAttributeObject in state.vertexAttributes {
            let vertexAttribute = vertexAttributeObject as! VertexAttribute
            if vertexAttribute.bufferIndex.integerValue == vertexBufferLayout.index.integerValue {
                vertexAttribute.bufferIndex = vertexBufferLayout.index
            }
        }
        vertexBufferLayout.index = sender.integerValue
        vertexAttributesTableView.reloadData()
        modelObserver.modelDidChange()
    }

    func addColorAttachmentView(colorAttachment: RenderPipelineColorAttachment) {
        let controller = RenderStateColorAttachmentViewController(nibName: "RenderStateColorAttachmentView", bundle: nil, modelObserver: modelObserver, removeObserver: self, colorAttachment: colorAttachment)!
        addChildViewController(controller)
        colorAttachmentsStackView.addArrangedSubview(controller.view)
    }

    @IBAction func addColorAttachment(sender: NSButton) {
        let attachment = NSEntityDescription.insertNewObjectForEntityForName("RenderPipelineColorAttachment", inManagedObjectContext: managedObjectContext) as! RenderPipelineColorAttachment
        attachment.pixelFormat = nil
        attachment.writeAlpha = true
        attachment.writeRed = true
        attachment.writeGreen = true
        attachment.writeBlue = true
        attachment.blendingEnabled = true
        attachment.alphaBlendOperation = MTLBlendOperation.Add.rawValue
        attachment.rgbBlendOperation = MTLBlendOperation.Add.rawValue
        attachment.destinationAlphaBlendFactor = MTLBlendFactor.Zero.rawValue
        attachment.destinationRGBBlendFactor = MTLBlendFactor.Zero.rawValue
        attachment.sourceAlphaBlendFactor = MTLBlendFactor.One.rawValue
        attachment.sourceRGBBlendFactor = MTLBlendFactor.One.rawValue
        state.mutableOrderedSetValueForKey("colorAttachments").addObject(attachment)
        addColorAttachmentView(attachment)
        modelObserver.modelDidChange()
    }

    func remove(viewController: RenderStateColorAttachmentViewController) {
        for i in 0 ..< childViewControllers.count {
            if childViewControllers[i] == viewController {
                childViewControllers.removeAtIndex(i)
                break
            }
        }
        viewController.view.removeFromSuperview()
        state.mutableOrderedSetValueForKey("colorAttachments").removeObject(viewController.colorAttachment)
        managedObjectContext.deleteObject(viewController.colorAttachment)
        modelObserver.modelDidChange()
    }

    @IBAction func depthAttachmentSelected(sender: NSPopUpButton) {
        assert(sender.indexOfSelectedItem >= 0)
        guard sender.indexOfSelectedItem > 0 else {
            state.depthAttachmentPixelFormat = nil
            return
        }
        let format = indexToPixelFormat(sender.indexOfSelectedItem - 1)!
        state.depthAttachmentPixelFormat = format.rawValue
        modelObserver.modelDidChange()
    }

    @IBAction func stencilAttachmentSelected(sender: NSPopUpButton) {
        assert(sender.indexOfSelectedItem >= 0)
        guard sender.indexOfSelectedItem > 0 else {
            state.depthAttachmentPixelFormat = nil
            return
        }
        let format = indexToPixelFormat(sender.indexOfSelectedItem - 1)!
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

    @IBAction func sampleCountSet(sender: NSTextField) {
        state.sampleCount = sender.integerValue
        modelObserver.modelDidChange()
    }

    @IBAction func removeRenderPipelineState(sender: NSButton) {
        removeObserver.removeRenderPipelineState(self)
    }

    @IBAction func setAlphaToCoverage(sender: NSButton) {
        state.alphaToCoverageEnabled = sender.state == NSOnState
        modelObserver.modelDidChange()
    }

    @IBAction func setAlphaToOne(sender: NSButton) {
        state.alphaToOneEnabled = sender.state == NSOnState
        modelObserver.modelDidChange()
    }

    @IBAction func setRasterizes(sender: NSButton) {
        state.rasterizationEnabled = sender.state == NSOnState
        modelObserver.modelDidChange()
    }

    @IBAction func inputPrimitiveTopologySelected(sender: NSPopUpButton) {
        state.inputPrimitiveTopology = sender.indexOfSelectedItem
        assert(state.inputPrimitiveTopology.integerValue >= 0 && state.inputPrimitiveTopology.integerValue <= 3)
        modelObserver.modelDidChange()
    }

}
