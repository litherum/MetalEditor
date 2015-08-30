//
//  RenderInvocationViewController.swift
//  MetalEditor
//
//  Created by Litherum on 8/10/15.
//  Copyright © 2015 Litherum. All rights reserved.
//

import Cocoa

class RenderInvocationViewController: NSViewController {
    var managedObjectContext: NSManagedObjectContext!
    weak var modelObserver: ModelObserver!
    weak var dismissObserver: DismissObserver!
    var renderInvocation: RenderInvocation!
    var vertexBufferBindingsViewController: BufferBindingsViewController!
    var fragmentBufferBindingsViewController: BufferBindingsViewController!
    var vertexTextureBindingsViewController: TextureBindingsViewController!
    var fragmentTextureBindingsViewController: TextureBindingsViewController!
    @IBOutlet var vertexBufferTableViewPlaceholder: NSView!
    @IBOutlet var fragmentBufferTableViewPlaceholder: NSView!
    @IBOutlet var vertexTextureTableViewPlaceholder: NSView!
    @IBOutlet var fragmentTextureTableViewPlaceholder: NSView!
    @IBOutlet var statePopUp: NSPopUpButton!
    @IBOutlet var primitivePopUp: NSPopUpButton!
    @IBOutlet var vertexStartTextField: NSTextField!
    @IBOutlet var vertexCountTextField: NSTextField!
    @IBOutlet var blendRedSlider: NSSlider!
    @IBOutlet var blendGreenSlider: NSSlider!
    @IBOutlet var blendBlueSlider: NSSlider!
    @IBOutlet var blendAlphaSlider: NSSlider!
    @IBOutlet var blendRedTextField: NSTextField!
    @IBOutlet var blendGreenTextField: NSTextField!
    @IBOutlet var blendBlueTextField: NSTextField!
    @IBOutlet var blendAlphaTextField: NSTextField!
    @IBOutlet var cullModePopUp: NSPopUpButton!
    @IBOutlet var depthBiasTextField: NSTextField!
    @IBOutlet var depthSlopeScaleTextField: NSTextField!
    @IBOutlet var depthClampTextField: NSTextField!
    @IBOutlet var depthClipModePopUp: NSPopUpButton!
    @IBOutlet var depthStencilStatePopUp: NSPopUpButton!
    @IBOutlet var windingOrderPopUp: NSPopUpButton!
    @IBOutlet var scissorRectCheckBox: NSButton!
    @IBOutlet var scissorRectXTextField: NSTextField!
    @IBOutlet var scissorRectYTextField: NSTextField!
    @IBOutlet var scissorRectWidthTextField: NSTextField!
    @IBOutlet var scissorRectHeightTextField: NSTextField!
    @IBOutlet var stencilFrontReferenceValueTextField: NSTextField!
    @IBOutlet var stencilBackReferenceValueTextField: NSTextField!
    @IBOutlet var triangleFillModePopUp: NSPopUpButton!
    @IBOutlet var viewportCheckBox: NSButton!
    @IBOutlet var viewportOriginXTextField: NSTextField!
    @IBOutlet var viewportOriginYTextField: NSTextField!
    @IBOutlet var viewportWidthTextField: NSTextField!
    @IBOutlet var viewportHeightTextField: NSTextField!
    @IBOutlet var viewportZNearTextField: NSTextField!
    @IBOutlet var viewportZFarTextField: NSTextField!
    @IBOutlet var visibilityResultModePopUp: NSPopUpButton!
    @IBOutlet var visibilityResultOffsetTextField: NSTextField!

    init?(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?, managedObjectContext: NSManagedObjectContext, modelObserver: ModelObserver, dismissObserver: DismissObserver, renderInvocation: RenderInvocation) {
        self.managedObjectContext = managedObjectContext
        self.modelObserver = modelObserver
        self.dismissObserver = dismissObserver
        self.renderInvocation = renderInvocation
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    func createStateMenu() -> (NSMenu, NSMenuItem?) {
        let fetchRequest = NSFetchRequest(entityName: "RenderPipelineState")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "id", ascending: true)]

        var selectedItem: NSMenuItem?
        do {
            let states = try managedObjectContext.executeFetchRequest(fetchRequest) as! [RenderPipelineState]
            let result = NSMenu()
            result.addItem(NSMenuItem(title: "None", action: nil, keyEquivalent: ""))
            for state in states {
                let item = NSMenuItem(title: state.name, action: nil, keyEquivalent: "")
                item.representedObject = state
                result.addItem(item)
                if let renderInvocationState = renderInvocation.state {
                    if renderInvocationState == state {
                        selectedItem = item
                    }
                }
            }
            return (result, selectedItem)
        } catch {
            fatalError()
        }
    }

    func createDepthStencilStateMenu() -> (NSMenu, NSMenuItem?) {
        let fetchRequest = NSFetchRequest(entityName: "DepthStencilState")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "id", ascending: true)]

        var selectedItem: NSMenuItem?
        do {
            let states = try managedObjectContext.executeFetchRequest(fetchRequest) as! [DepthStencilState]
            let result = NSMenu()
            result.addItem(NSMenuItem(title: "None", action: nil, keyEquivalent: ""))
            for state in states {
                let item = NSMenuItem(title: state.name, action: nil, keyEquivalent: "")
                item.representedObject = state
                result.addItem(item)
                if let renderInvocationState = renderInvocation.state {
                    if renderInvocationState == state {
                        selectedItem = item
                    }
                }
            }
            return (result, selectedItem)
        } catch {
            fatalError()
        }
    }

    override func viewDidLoad() {
        vertexBufferBindingsViewController = BufferBindingsViewController(nibName: "BindingsView", bundle: nil, managedObjectContext: managedObjectContext, modelObserver: modelObserver, bindings: renderInvocation.vertexBufferBindings)
        addChildViewController(vertexBufferBindingsViewController)
        vertexBufferTableViewPlaceholder.addSubview(vertexBufferBindingsViewController.view)
        vertexBufferTableViewPlaceholder.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|[tableView]|", options: NSLayoutFormatOptions(), metrics: nil, views: ["tableView" : vertexBufferBindingsViewController.view]))
        vertexBufferTableViewPlaceholder.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[tableView]|", options: NSLayoutFormatOptions(), metrics: nil, views: ["tableView" : vertexBufferBindingsViewController.view]))

        fragmentBufferBindingsViewController = BufferBindingsViewController(nibName: "BindingsView", bundle: nil, managedObjectContext: managedObjectContext, modelObserver: modelObserver, bindings: renderInvocation.fragmentBufferBindings)
        addChildViewController(fragmentBufferBindingsViewController)
        fragmentBufferTableViewPlaceholder.addSubview(fragmentBufferBindingsViewController.view)
        fragmentBufferTableViewPlaceholder.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|[tableView]|", options: NSLayoutFormatOptions(), metrics: nil, views: ["tableView" : fragmentBufferBindingsViewController.view]))
        fragmentBufferTableViewPlaceholder.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[tableView]|", options: NSLayoutFormatOptions(), metrics: nil, views: ["tableView" : fragmentBufferBindingsViewController.view]))

        vertexTextureBindingsViewController = TextureBindingsViewController(nibName: "BindingsView", bundle: nil, managedObjectContext: managedObjectContext, modelObserver: modelObserver, bindings: renderInvocation.vertexTextureBindings)
        addChildViewController(vertexTextureBindingsViewController)
        vertexTextureTableViewPlaceholder.addSubview(vertexTextureBindingsViewController.view)
        vertexTextureTableViewPlaceholder.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|[tableView]|", options: NSLayoutFormatOptions(), metrics: nil, views: ["tableView" : vertexTextureBindingsViewController.view]))
        vertexTextureTableViewPlaceholder.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[tableView]|", options: NSLayoutFormatOptions(), metrics: nil, views: ["tableView" : vertexTextureBindingsViewController.view]))

        fragmentTextureBindingsViewController = TextureBindingsViewController(nibName: "BindingsView", bundle: nil, managedObjectContext: managedObjectContext, modelObserver: modelObserver, bindings: renderInvocation.fragmentTextureBindings)
        addChildViewController(fragmentTextureBindingsViewController)
        fragmentTextureTableViewPlaceholder.addSubview(fragmentTextureBindingsViewController.view)
        fragmentTextureTableViewPlaceholder.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|[tableView]|", options: NSLayoutFormatOptions(), metrics: nil, views: ["tableView" : fragmentTextureBindingsViewController.view]))
        fragmentTextureTableViewPlaceholder.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[tableView]|", options: NSLayoutFormatOptions(), metrics: nil, views: ["tableView" : fragmentTextureBindingsViewController.view]))

        let (stateMenu, selectedStateItem) = createStateMenu()
        statePopUp.menu = stateMenu
        if let toSelect = selectedStateItem {
            statePopUp.selectItem(toSelect)
        } else {
            statePopUp.selectItemAtIndex(0)
        }

        assert(renderInvocation.primitive.integerValue >= 0 && renderInvocation.primitive.integerValue <= 4)
        primitivePopUp.selectItemAtIndex(renderInvocation.primitive.integerValue)

        vertexStartTextField.integerValue = renderInvocation.vertexStart.integerValue
        vertexCountTextField.integerValue = renderInvocation.vertexCount.integerValue

        blendRedSlider.doubleValue = renderInvocation.blendColorRed.doubleValue
        blendGreenSlider.doubleValue = renderInvocation.blendColorGreen.doubleValue
        blendBlueSlider.doubleValue = renderInvocation.blendColorBlue.doubleValue
        blendAlphaSlider.doubleValue = renderInvocation.blendColorAlpha.doubleValue
        blendRedTextField.doubleValue = renderInvocation.blendColorRed.doubleValue
        blendGreenTextField.doubleValue = renderInvocation.blendColorGreen.doubleValue
        blendBlueTextField.doubleValue = renderInvocation.blendColorBlue.doubleValue
        blendAlphaTextField.doubleValue = renderInvocation.blendColorAlpha.doubleValue
        cullModePopUp.selectItemAtIndex(renderInvocation.cullMode.integerValue)
        depthBiasTextField.doubleValue = renderInvocation.depthBias.doubleValue
        depthSlopeScaleTextField.doubleValue = renderInvocation.depthSlopeScale.doubleValue
        depthClampTextField.doubleValue = renderInvocation.depthClamp.doubleValue
        depthClipModePopUp.selectItemAtIndex(renderInvocation.depthClipMode.integerValue)

        let (depthStencilMenu, selectedDepthStencilItem) = createDepthStencilStateMenu()
        depthStencilStatePopUp.menu = depthStencilMenu
        if let toSelect = selectedDepthStencilItem {
            depthStencilStatePopUp.selectItem(toSelect)
        } else {
            depthStencilStatePopUp.selectItemAtIndex(0)
        }

        windingOrderPopUp.selectItemAtIndex(renderInvocation.frontFacingWinding.integerValue)
        if let scissorRect = renderInvocation.scissorRect {
            scissorRectCheckBox.state = NSOnState
            scissorRectXTextField.integerValue = scissorRect.x.integerValue
            scissorRectYTextField.integerValue = scissorRect.y.integerValue
            scissorRectWidthTextField.integerValue = scissorRect.width.integerValue
            scissorRectHeightTextField.integerValue = scissorRect.height.integerValue
        } else {
            scissorRectCheckBox.state = NSOffState
            scissorRectXTextField.enabled = false
            scissorRectYTextField.enabled = false
            scissorRectWidthTextField.enabled = false
            scissorRectHeightTextField.enabled = false
        }
        stencilFrontReferenceValueTextField.integerValue = renderInvocation.stencilFrontReferenceValue.integerValue
        stencilBackReferenceValueTextField.integerValue = renderInvocation.stencilBackReferenceValue.integerValue
        triangleFillModePopUp.selectItemAtIndex(renderInvocation.triangleFillMode.integerValue)
        if let viewport = renderInvocation.viewport {
            viewportCheckBox.state = NSOnState
            viewportOriginXTextField.doubleValue = viewport.originX.doubleValue
            viewportOriginYTextField.doubleValue = viewport.originY.doubleValue
            viewportWidthTextField.doubleValue = viewport.width.doubleValue
            viewportHeightTextField.doubleValue = viewport.height.doubleValue
            viewportZNearTextField.doubleValue = viewport.zNear.doubleValue
            viewportZFarTextField.doubleValue = viewport.zFar.doubleValue
        } else {
            viewportCheckBox.state = NSOffState
            viewportOriginXTextField.enabled = false
            viewportOriginYTextField.enabled = false
            viewportWidthTextField.enabled = false
            viewportHeightTextField.enabled = false
            viewportZNearTextField.enabled = false
            viewportZFarTextField.enabled = false
        }
        visibilityResultModePopUp.selectItemAtIndex(renderInvocation.visibilityResultMode.integerValue)
        visibilityResultOffsetTextField.integerValue = renderInvocation.visibilityResultOffset.integerValue
    }

    @IBAction func addRemoveVertexBufferBinding(sender: NSSegmentedControl) {
        if sender.selectedSegment == 0 { // Add
            let bufferBinding = NSEntityDescription.insertNewObjectForEntityForName("BufferBinding", inManagedObjectContext: managedObjectContext) as! BufferBinding
            bufferBinding.buffer = nil
            renderInvocation.mutableOrderedSetValueForKey("vertexBufferBindings").addObject(bufferBinding)
        } else { // Remove
            assert(sender.selectedSegment == 1)
            guard let row = vertexBufferBindingsViewController.selectedRow() else {
                return
            }
            let binding = renderInvocation.vertexBufferBindings[row] as! BufferBinding
            renderInvocation.mutableOrderedSetValueForKey("vertexBufferBindings").removeObject(binding)
            managedObjectContext.deleteObject(binding)
        }
        vertexBufferBindingsViewController.reloadData()
        modelObserver.modelDidChange()
        sender.selectedSegment = -1
    }

    @IBAction func addRemoveFragmentBufferBinding(sender: NSSegmentedControl) {
        if sender.selectedSegment == 0 { // Add
            let bufferBinding = NSEntityDescription.insertNewObjectForEntityForName("BufferBinding", inManagedObjectContext: managedObjectContext) as! BufferBinding
            bufferBinding.buffer = nil
            renderInvocation.mutableOrderedSetValueForKey("fragmentBufferBindings").addObject(bufferBinding)
        } else { // Remove
            assert(sender.selectedSegment == 1)
            guard let row = fragmentBufferBindingsViewController.selectedRow() else {
                return
            }
            let binding = renderInvocation.fragmentBufferBindings[row] as! BufferBinding
            renderInvocation.mutableOrderedSetValueForKey("fragmentBufferBindings").removeObject(binding)
            managedObjectContext.deleteObject(binding)
        }
        fragmentBufferBindingsViewController.reloadData()
        modelObserver.modelDidChange()
        sender.selectedSegment = -1
    }

    @IBAction func addRemoveVertexTextureBinding(sender: NSSegmentedControl) {
        if sender.selectedSegment == 0 { // Add
            let textureBinding = NSEntityDescription.insertNewObjectForEntityForName("TextureBinding", inManagedObjectContext: managedObjectContext) as! TextureBinding
            textureBinding.texture = nil
            renderInvocation.mutableOrderedSetValueForKey("vertexTextureBindings").addObject(textureBinding)
        } else { // Remove
            assert(sender.selectedSegment == 1)
            guard let row = vertexTextureBindingsViewController.selectedRow() else {
                return
            }
            let binding = renderInvocation.vertexTextureBindings[row] as! TextureBinding
            renderInvocation.mutableOrderedSetValueForKey("vertexTextureBindings").removeObject(binding)
            managedObjectContext.deleteObject(binding)
        }
        vertexTextureBindingsViewController.reloadData()
        modelObserver.modelDidChange()
        sender.selectedSegment = -1
    }
    @IBAction func addRemoveFragmentTextureBinding(sender: NSSegmentedControl) {
        if sender.selectedSegment == 0 { // Add
            let textureBinding = NSEntityDescription.insertNewObjectForEntityForName("TextureBinding", inManagedObjectContext: managedObjectContext) as! TextureBinding
            textureBinding.texture = nil
            renderInvocation.mutableOrderedSetValueForKey("fragmentTextureBindings").addObject(textureBinding)
        } else { // Remove
            assert(sender.selectedSegment == 1)
            guard let row = fragmentTextureBindingsViewController.selectedRow() else {
                return
            }
            let binding = renderInvocation.fragmentTextureBindings[row] as! TextureBinding
            renderInvocation.mutableOrderedSetValueForKey("fragmentTextureBindings").removeObject(binding)
            managedObjectContext.deleteObject(binding)
        }
        fragmentTextureBindingsViewController.reloadData()
        modelObserver.modelDidChange()
        sender.selectedSegment = -1
    }

    @IBAction func stateSelected(sender: NSPopUpButton) {
        let selectedItem = sender.selectedItem!

        guard let selectionObject = selectedItem.representedObject else {
            renderInvocation.state = nil
            modelObserver.modelDidChange()
            return
        }

        renderInvocation.state = (selectionObject as! RenderPipelineState)
        modelObserver.modelDidChange()
    }

    @IBAction func primitiveSelected(sender: NSPopUpButton) {
        assert(sender.indexOfSelectedItem >= 0)
        renderInvocation.primitive = sender.indexOfSelectedItem
        modelObserver.modelDidChange()
    }

    @IBAction func setVertexStart(sender: NSTextField) {
        renderInvocation.vertexStart = sender.integerValue
        modelObserver.modelDidChange()
    }

    @IBAction func setVertexCount(sender: NSTextField) {
        renderInvocation.vertexCount = sender.integerValue
        modelObserver.modelDidChange()
    }
    @IBAction func blendColorRedSliderSet(sender: NSSlider) {
        renderInvocation.blendColorRed = sender.doubleValue
        blendRedTextField.doubleValue = sender.doubleValue
        modelObserver.modelDidChange()
    }

    @IBAction func blendColorGreenSliderSet(sender: NSSlider) {
        renderInvocation.blendColorGreen = sender.doubleValue
        blendGreenTextField.doubleValue = sender.doubleValue
        modelObserver.modelDidChange()
    }

    @IBAction func blendColorBlueSliderSet(sender: NSSlider) {
        renderInvocation.blendColorBlue = sender.doubleValue
        blendBlueTextField.doubleValue = sender.doubleValue
        modelObserver.modelDidChange()
    }

    @IBAction func blendColorAlphaSliderSet(sender: NSSlider) {
        renderInvocation.blendColorAlpha = sender.doubleValue
        blendAlphaTextField.doubleValue = sender.doubleValue
        modelObserver.modelDidChange()
    }

    @IBAction func blendColorRedTextFieldSet(sender: NSTextField) {
        renderInvocation.blendColorRed = sender.doubleValue
        blendRedSlider.doubleValue = sender.doubleValue
        modelObserver.modelDidChange()
    }

    @IBAction func blendColorGreenTextFieldSet(sender: NSTextField) {
        renderInvocation.blendColorGreen = sender.doubleValue
        blendGreenSlider.doubleValue = sender.doubleValue
        modelObserver.modelDidChange()
    }

    @IBAction func blendColorBlueTextFieldSet(sender: NSTextField) {
        renderInvocation.blendColorBlue = sender.doubleValue
        blendBlueSlider.doubleValue = sender.doubleValue
        modelObserver.modelDidChange()
    }

    @IBAction func blendColorAlphaTextFieldSet(sender: NSTextField) {
        renderInvocation.blendColorAlpha = sender.doubleValue
        blendAlphaSlider.doubleValue = sender.doubleValue
        modelObserver.modelDidChange()
    }

    @IBAction func cullModeSelected(sender: NSPopUpButton) {
        renderInvocation.cullMode = sender.indexOfSelectedItem
        modelObserver.modelDidChange()
    }

    @IBAction func depthBiasSet(sender: NSTextField) {
        renderInvocation.depthBias = sender.doubleValue
        modelObserver.modelDidChange()
    }

    @IBAction func depthSlopeScaleSet(sender: NSTextField) {
        renderInvocation.depthSlopeScale = sender.doubleValue
        modelObserver.modelDidChange()
    }

    @IBAction func depthClampSet(sender: NSTextField) {
        renderInvocation.depthClamp = sender.doubleValue
        modelObserver.modelDidChange()
    }

    @IBAction func depthClipModeSelected(sender: NSPopUpButton) {
        renderInvocation.depthClipMode = sender.indexOfSelectedItem
        modelObserver.modelDidChange()
    }

    @IBAction func depthStencilStateSelected(sender: NSPopUpButton) {
        let selectedItem = sender.selectedItem!

        guard let selectionObject = selectedItem.representedObject else {
            renderInvocation.depthStencilState = nil
            modelObserver.modelDidChange()
            return
        }

        renderInvocation.depthStencilState = (selectionObject as! DepthStencilState)
        modelObserver.modelDidChange()
    }

    @IBAction func windingOrderSelected(sender: NSPopUpButton) {
        renderInvocation.frontFacingWinding = sender.indexOfSelectedItem
        modelObserver.modelDidChange()
    }

    @IBAction func scissorRectChecked(sender: NSButton) {
        if sender.state == NSOnState {
            let scissorRect = NSEntityDescription.insertNewObjectForEntityForName("ScissorRect", inManagedObjectContext: managedObjectContext!) as! ScissorRect
            scissorRect.x = 0
            scissorRect.y = 0
            scissorRect.width = 0
            scissorRect.height = 0
            renderInvocation.scissorRect = scissorRect
            scissorRectXTextField.integerValue = scissorRect.x.integerValue
            scissorRectYTextField.integerValue = scissorRect.y.integerValue
            scissorRectWidthTextField.integerValue = scissorRect.width.integerValue
            scissorRectHeightTextField.integerValue = scissorRect.height.integerValue
            scissorRectXTextField.enabled = true
            scissorRectYTextField.enabled = true
            scissorRectWidthTextField.enabled = true
            scissorRectHeightTextField.enabled = true
        } else {
            let scissorRect = renderInvocation.scissorRect!
            renderInvocation.scissorRect = nil
            managedObjectContext.deleteObject(scissorRect)
            scissorRectXTextField.stringValue = ""
            scissorRectYTextField.stringValue = ""
            scissorRectWidthTextField.stringValue = ""
            scissorRectHeightTextField.stringValue = ""
            scissorRectXTextField.enabled = false
            scissorRectYTextField.enabled = false
            scissorRectWidthTextField.enabled = false
            scissorRectHeightTextField.enabled = false
        }
        modelObserver.modelDidChange()
    }

    @IBAction func scissorRectXSet(sender: NSTextField) {
        renderInvocation.scissorRect!.x = sender.integerValue
        modelObserver.modelDidChange()
    }

    @IBAction func scissorRectYSet(sender: NSTextField) {
        renderInvocation.scissorRect!.y = sender.integerValue
        modelObserver.modelDidChange()
    }

    @IBAction func scissorRectWidthSet(sender: NSTextField) {
        renderInvocation.scissorRect!.width = sender.integerValue
        modelObserver.modelDidChange()
    }

    @IBAction func scissorRectHeightSet(sender: NSTextField) {
        renderInvocation.scissorRect!.height = sender.integerValue
        modelObserver.modelDidChange()
    }

    @IBAction func stencilFrontReferenceValueSet(sender: NSTextField) {
        renderInvocation.stencilFrontReferenceValue = sender.integerValue
        modelObserver.modelDidChange()
    }

    @IBAction func stencilBackReferenceValueSet(sender: NSTextField) {
        renderInvocation.stencilBackReferenceValue = sender.integerValue
        modelObserver.modelDidChange()
    }

    @IBAction func triangleFillModeSelected(sender: NSPopUpButton) {
        renderInvocation.triangleFillMode = sender.indexOfSelectedItem
        modelObserver.modelDidChange()
    }

    @IBAction func viewportChecked(sender: NSButton) {
        if sender.state == NSOnState {
            let viewport = NSEntityDescription.insertNewObjectForEntityForName("Viewport", inManagedObjectContext: managedObjectContext!) as! Viewport
            viewport.originX = 0
            viewport.originY = 0
            viewport.width = 0
            viewport.height = 0
            viewport.zNear = 0
            viewport.zFar = 0
            renderInvocation.viewport = viewport
            viewportOriginXTextField.doubleValue = viewport.originX.doubleValue
            viewportOriginYTextField.doubleValue = viewport.originY.doubleValue
            viewportWidthTextField.doubleValue = viewport.width.doubleValue
            viewportHeightTextField.doubleValue = viewport.height.doubleValue
            viewportZNearTextField.doubleValue = viewport.zNear.doubleValue
            viewportZFarTextField.doubleValue = viewport.zFar.doubleValue
            viewportOriginXTextField.enabled = true
            viewportOriginYTextField.enabled = true
            viewportWidthTextField.enabled = true
            viewportHeightTextField.enabled = true
            viewportZNearTextField.enabled = true
            viewportZFarTextField.enabled = true
        } else {
            let viewport = renderInvocation.viewport!
            renderInvocation.viewport = nil
            managedObjectContext.deleteObject(viewport)
            viewportOriginXTextField.stringValue = ""
            viewportOriginYTextField.stringValue = ""
            viewportWidthTextField.stringValue = ""
            viewportHeightTextField.stringValue = ""
            viewportZNearTextField.stringValue = ""
            viewportZFarTextField.stringValue = ""
            viewportOriginXTextField.enabled = false
            viewportOriginYTextField.enabled = false
            viewportWidthTextField.enabled = false
            viewportHeightTextField.enabled = false
            viewportZNearTextField.enabled = false
            viewportZFarTextField.enabled = false
        }
        modelObserver.modelDidChange()
    }

    @IBAction func viewportOriginXSet(sender: NSTextField) {
        renderInvocation.viewport!.originX = sender.doubleValue
        modelObserver.modelDidChange()
    }

    @IBAction func viewportOriginYSet(sender: NSTextField) {
        renderInvocation.viewport!.originY = sender.doubleValue
        modelObserver.modelDidChange()
    }

    @IBAction func viewportWidthSet(sender: NSTextField) {
        renderInvocation.viewport!.width = sender.doubleValue
        modelObserver.modelDidChange()
    }

    @IBAction func viewportHeightSet(sender: NSTextField) {
        renderInvocation.viewport!.height = sender.doubleValue
        modelObserver.modelDidChange()
    }

    @IBAction func viewportZNearSet(sender: NSTextField) {
        renderInvocation.viewport!.zNear = sender.doubleValue
        modelObserver.modelDidChange()
    }

    @IBAction func viewportZFarSet(sender: NSTextField) {
        renderInvocation.viewport!.zFar = sender.doubleValue
        modelObserver.modelDidChange()
    }

    @IBAction func visibilityResultModeSelected(sender: NSPopUpButton) {
        renderInvocation.visibilityResultMode = sender.indexOfSelectedItem
        modelObserver.modelDidChange()
    }

    @IBAction func visibilityResultOffsetSet(sender: NSTextField) {
        renderInvocation.visibilityResultOffset = sender.integerValue
        modelObserver.modelDidChange()
    }

    @IBAction func dismiss(sender: NSButton) {
        dismissObserver.dismiss(self)
    }
}