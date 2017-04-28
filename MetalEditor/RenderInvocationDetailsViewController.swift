//
//  RenderInvocationDetailsViewController.swift
//  MetalEditor
//
//  Created by Litherum on 8/10/15.
//  Copyright © 2015 Litherum. All rights reserved.
//

import Cocoa

class RenderInvocationDetailsViewController: NSViewController {
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

    init?(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?, managedObjectContext: NSManagedObjectContext, modelObserver: ModelObserver, dismissObserver: DismissObserver, renderInvocation: RenderInvocation) {
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
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "RenderPipelineState")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "id", ascending: true)]

        var selectedItem: NSMenuItem?
        do {
            let states = try managedObjectContext.fetch(fetchRequest) as! [RenderPipelineState]
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
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "DepthStencilState")

        var selectedItem: NSMenuItem?
        do {
            let states = try managedObjectContext.fetch(fetchRequest) as! [DepthStencilState]
            let result = NSMenu()
            result.addItem(NSMenuItem(title: "None", action: nil, keyEquivalent: ""))
            for state in states {
                let item = NSMenuItem(title: state.name, action: nil, keyEquivalent: "")
                item.representedObject = state
                result.addItem(item)
                if let renderInvocationState = renderInvocation.depthStencilState {
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
        vertexBufferTableViewPlaceholder.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "|[tableView]|", options: NSLayoutFormatOptions(), metrics: nil, views: ["tableView" : vertexBufferBindingsViewController.view]))
        vertexBufferTableViewPlaceholder.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[tableView]|", options: NSLayoutFormatOptions(), metrics: nil, views: ["tableView" : vertexBufferBindingsViewController.view]))

        fragmentBufferBindingsViewController = BufferBindingsViewController(nibName: "BindingsView", bundle: nil, managedObjectContext: managedObjectContext, modelObserver: modelObserver, bindings: renderInvocation.fragmentBufferBindings)
        addChildViewController(fragmentBufferBindingsViewController)
        fragmentBufferTableViewPlaceholder.addSubview(fragmentBufferBindingsViewController.view)
        fragmentBufferTableViewPlaceholder.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "|[tableView]|", options: NSLayoutFormatOptions(), metrics: nil, views: ["tableView" : fragmentBufferBindingsViewController.view]))
        fragmentBufferTableViewPlaceholder.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[tableView]|", options: NSLayoutFormatOptions(), metrics: nil, views: ["tableView" : fragmentBufferBindingsViewController.view]))

        vertexTextureBindingsViewController = TextureBindingsViewController(nibName: "BindingsView", bundle: nil, managedObjectContext: managedObjectContext, modelObserver: modelObserver, bindings: renderInvocation.vertexTextureBindings)
        addChildViewController(vertexTextureBindingsViewController)
        vertexTextureTableViewPlaceholder.addSubview(vertexTextureBindingsViewController.view)
        vertexTextureTableViewPlaceholder.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "|[tableView]|", options: NSLayoutFormatOptions(), metrics: nil, views: ["tableView" : vertexTextureBindingsViewController.view]))
        vertexTextureTableViewPlaceholder.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[tableView]|", options: NSLayoutFormatOptions(), metrics: nil, views: ["tableView" : vertexTextureBindingsViewController.view]))

        fragmentTextureBindingsViewController = TextureBindingsViewController(nibName: "BindingsView", bundle: nil, managedObjectContext: managedObjectContext, modelObserver: modelObserver, bindings: renderInvocation.fragmentTextureBindings)
        addChildViewController(fragmentTextureBindingsViewController)
        fragmentTextureTableViewPlaceholder.addSubview(fragmentTextureBindingsViewController.view)
        fragmentTextureTableViewPlaceholder.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "|[tableView]|", options: NSLayoutFormatOptions(), metrics: nil, views: ["tableView" : fragmentTextureBindingsViewController.view]))
        fragmentTextureTableViewPlaceholder.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[tableView]|", options: NSLayoutFormatOptions(), metrics: nil, views: ["tableView" : fragmentTextureBindingsViewController.view]))

        let (stateMenu, selectedStateItem) = createStateMenu()
        statePopUp.menu = stateMenu
        if let toSelect = selectedStateItem {
            statePopUp.select(toSelect)
        } else {
            statePopUp.selectItem(at: 0)
        }

        assert(renderInvocation.primitive.intValue >= 0 && renderInvocation.primitive.intValue <= 4)
        primitivePopUp.selectItem(at: renderInvocation.primitive.intValue)

        vertexStartTextField.integerValue = renderInvocation.vertexStart.intValue
        vertexCountTextField.integerValue = renderInvocation.vertexCount.intValue

        blendRedSlider.doubleValue = renderInvocation.blendColorRed.doubleValue
        blendGreenSlider.doubleValue = renderInvocation.blendColorGreen.doubleValue
        blendBlueSlider.doubleValue = renderInvocation.blendColorBlue.doubleValue
        blendAlphaSlider.doubleValue = renderInvocation.blendColorAlpha.doubleValue
        blendRedTextField.doubleValue = renderInvocation.blendColorRed.doubleValue
        blendGreenTextField.doubleValue = renderInvocation.blendColorGreen.doubleValue
        blendBlueTextField.doubleValue = renderInvocation.blendColorBlue.doubleValue
        blendAlphaTextField.doubleValue = renderInvocation.blendColorAlpha.doubleValue
        cullModePopUp.selectItem(at: renderInvocation.cullMode.intValue)
        depthBiasTextField.doubleValue = renderInvocation.depthBias.doubleValue
        depthSlopeScaleTextField.doubleValue = renderInvocation.depthSlopeScale.doubleValue
        depthClampTextField.doubleValue = renderInvocation.depthClamp.doubleValue
        depthClipModePopUp.selectItem(at: renderInvocation.depthClipMode.intValue)

        let (depthStencilMenu, selectedDepthStencilItem) = createDepthStencilStateMenu()
        depthStencilStatePopUp.menu = depthStencilMenu
        if let toSelect = selectedDepthStencilItem {
            depthStencilStatePopUp.select(toSelect)
        } else {
            depthStencilStatePopUp.selectItem(at: 0)
        }

        windingOrderPopUp.selectItem(at: renderInvocation.frontFacingWinding.intValue)
        if let scissorRect = renderInvocation.scissorRect {
            scissorRectCheckBox.state = NSOnState
            scissorRectXTextField.integerValue = scissorRect.x.intValue
            scissorRectYTextField.integerValue = scissorRect.y.intValue
            scissorRectWidthTextField.integerValue = scissorRect.width.intValue
            scissorRectHeightTextField.integerValue = scissorRect.height.intValue
        } else {
            scissorRectCheckBox.state = NSOffState
            scissorRectXTextField.isEnabled = false
            scissorRectYTextField.isEnabled = false
            scissorRectWidthTextField.isEnabled = false
            scissorRectHeightTextField.isEnabled = false
        }
        stencilFrontReferenceValueTextField.integerValue = renderInvocation.stencilFrontReferenceValue.intValue
        stencilBackReferenceValueTextField.integerValue = renderInvocation.stencilBackReferenceValue.intValue
        triangleFillModePopUp.selectItem(at: renderInvocation.triangleFillMode.intValue)
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
            viewportOriginXTextField.isEnabled = false
            viewportOriginYTextField.isEnabled = false
            viewportWidthTextField.isEnabled = false
            viewportHeightTextField.isEnabled = false
            viewportZNearTextField.isEnabled = false
            viewportZFarTextField.isEnabled = false
        }
        visibilityResultModePopUp.selectItem(at: renderInvocation.visibilityResultMode.intValue)
        visibilityResultOffsetTextField.integerValue = renderInvocation.visibilityResultOffset.intValue
    }

    @IBAction func addRemoveVertexBufferBinding(_ sender: NSSegmentedControl) {
        if sender.selectedSegment == 0 { // Add
            let bufferBinding = NSEntityDescription.insertNewObject(forEntityName: "BufferBinding", into: managedObjectContext) as! BufferBinding
            bufferBinding.buffer = nil
            renderInvocation.mutableOrderedSetValue(forKey: "vertexBufferBindings").add(bufferBinding)
        } else { // Remove
            assert(sender.selectedSegment == 1)
            guard let row = vertexBufferBindingsViewController.selectedRow() else {
                return
            }
            let binding = renderInvocation.vertexBufferBindings[row] as! BufferBinding
            renderInvocation.mutableOrderedSetValue(forKey: "vertexBufferBindings").remove(binding)
            managedObjectContext.delete(binding)
        }
        vertexBufferBindingsViewController.reloadData()
        modelObserver.modelDidChange()
        sender.selectedSegment = -1
    }

    @IBAction func addRemoveFragmentBufferBinding(_ sender: NSSegmentedControl) {
        if sender.selectedSegment == 0 { // Add
            let bufferBinding = NSEntityDescription.insertNewObject(forEntityName: "BufferBinding", into: managedObjectContext) as! BufferBinding
            bufferBinding.buffer = nil
            renderInvocation.mutableOrderedSetValue(forKey: "fragmentBufferBindings").add(bufferBinding)
        } else { // Remove
            assert(sender.selectedSegment == 1)
            guard let row = fragmentBufferBindingsViewController.selectedRow() else {
                return
            }
            let binding = renderInvocation.fragmentBufferBindings[row] as! BufferBinding
            renderInvocation.mutableOrderedSetValue(forKey: "fragmentBufferBindings").remove(binding)
            managedObjectContext.delete(binding)
        }
        fragmentBufferBindingsViewController.reloadData()
        modelObserver.modelDidChange()
        sender.selectedSegment = -1
    }

    @IBAction func addRemoveVertexTextureBinding(_ sender: NSSegmentedControl) {
        if sender.selectedSegment == 0 { // Add
            let textureBinding = NSEntityDescription.insertNewObject(forEntityName: "TextureBinding", into: managedObjectContext) as! TextureBinding
            textureBinding.texture = nil
            renderInvocation.mutableOrderedSetValue(forKey: "vertexTextureBindings").add(textureBinding)
        } else { // Remove
            assert(sender.selectedSegment == 1)
            guard let row = vertexTextureBindingsViewController.selectedRow() else {
                return
            }
            let binding = renderInvocation.vertexTextureBindings[row] as! TextureBinding
            renderInvocation.mutableOrderedSetValue(forKey: "vertexTextureBindings").remove(binding)
            managedObjectContext.delete(binding)
        }
        vertexTextureBindingsViewController.reloadData()
        modelObserver.modelDidChange()
        sender.selectedSegment = -1
    }
    @IBAction func addRemoveFragmentTextureBinding(_ sender: NSSegmentedControl) {
        if sender.selectedSegment == 0 { // Add
            let textureBinding = NSEntityDescription.insertNewObject(forEntityName: "TextureBinding", into: managedObjectContext) as! TextureBinding
            textureBinding.texture = nil
            renderInvocation.mutableOrderedSetValue(forKey: "fragmentTextureBindings").add(textureBinding)
        } else { // Remove
            assert(sender.selectedSegment == 1)
            guard let row = fragmentTextureBindingsViewController.selectedRow() else {
                return
            }
            let binding = renderInvocation.fragmentTextureBindings[row] as! TextureBinding
            renderInvocation.mutableOrderedSetValue(forKey: "fragmentTextureBindings").remove(binding)
            managedObjectContext.delete(binding)
        }
        fragmentTextureBindingsViewController.reloadData()
        modelObserver.modelDidChange()
        sender.selectedSegment = -1
    }

    @IBAction func stateSelected(_ sender: NSPopUpButton) {
        let selectedItem = sender.selectedItem!

        guard let selectionObject = selectedItem.representedObject else {
            renderInvocation.state = nil
            modelObserver.modelDidChange()
            return
        }

        renderInvocation.state = (selectionObject as! RenderPipelineState)
        modelObserver.modelDidChange()
    }

    @IBAction func primitiveSelected(_ sender: NSPopUpButton) {
        assert(sender.indexOfSelectedItem >= 0)
        renderInvocation.primitive = NSNumber(sender.indexOfSelectedItem)
        modelObserver.modelDidChange()
    }

    @IBAction func setVertexStart(_ sender: NSTextField) {
        renderInvocation.vertexStart = NSNumber(sender.integerValue)
        modelObserver.modelDidChange()
    }

    @IBAction func setVertexCount(_ sender: NSTextField) {
        renderInvocation.vertexCount = NSNumber(sender.integerValue)
        modelObserver.modelDidChange()
    }
    @IBAction func blendColorRedSliderSet(_ sender: NSSlider) {
        renderInvocation.blendColorRed = NSNumber(value: sender.doubleValue)
        blendRedTextField.doubleValue = sender.doubleValue
        modelObserver.modelDidChange()
    }

    @IBAction func blendColorGreenSliderSet(_ sender: NSSlider) {
        renderInvocation.blendColorGreen = NSNumber(value: sender.doubleValue)
        blendGreenTextField.doubleValue = sender.doubleValue
        modelObserver.modelDidChange()
    }

    @IBAction func blendColorBlueSliderSet(_ sender: NSSlider) {
        renderInvocation.blendColorBlue = NSNumber(value: sender.doubleValue)
        blendBlueTextField.doubleValue = sender.doubleValue
        modelObserver.modelDidChange()
    }

    @IBAction func blendColorAlphaSliderSet(_ sender: NSSlider) {
        renderInvocation.blendColorAlpha = NSNumber(value: sender.doubleValue)
        blendAlphaTextField.doubleValue = sender.doubleValue
        modelObserver.modelDidChange()
    }

    @IBAction func blendColorRedTextFieldSet(_ sender: NSTextField) {
        renderInvocation.blendColorRed = NSNumber(value: sender.doubleValue)
        blendRedSlider.doubleValue = sender.doubleValue
        modelObserver.modelDidChange()
    }

    @IBAction func blendColorGreenTextFieldSet(_ sender: NSTextField) {
        renderInvocation.blendColorGreen = NSNumber(value: sender.doubleValue)
        blendGreenSlider.doubleValue = sender.doubleValue
        modelObserver.modelDidChange()
    }

    @IBAction func blendColorBlueTextFieldSet(_ sender: NSTextField) {
        renderInvocation.blendColorBlue = NSNumber(value: sender.doubleValue)
        blendBlueSlider.doubleValue = sender.doubleValue
        modelObserver.modelDidChange()
    }

    @IBAction func blendColorAlphaTextFieldSet(_ sender: NSTextField) {
        renderInvocation.blendColorAlpha = NSNumber(value: sender.doubleValue)
        blendAlphaSlider.doubleValue = sender.doubleValue
        modelObserver.modelDidChange()
    }

    @IBAction func cullModeSelected(_ sender: NSPopUpButton) {
        renderInvocation.cullMode = NSNumber(value: sender.indexOfSelectedItem)
        modelObserver.modelDidChange()
    }

    @IBAction func depthBiasSet(_ sender: NSTextField) {
        renderInvocation.depthBias = NSNumber(value: sender.doubleValue)
        modelObserver.modelDidChange()
    }

    @IBAction func depthSlopeScaleSet(_ sender: NSTextField) {
        renderInvocation.depthSlopeScale = NSNumber(value: sender.doubleValue)
        modelObserver.modelDidChange()
    }

    @IBAction func depthClampSet(_ sender: NSTextField) {
        renderInvocation.depthClamp = NSNumber(value: sender.doubleValue)
        modelObserver.modelDidChange()
    }

    @IBAction func depthClipModeSelected(_ sender: NSPopUpButton) {
        renderInvocation.depthClipMode = NSNumber(sender.indexOfSelectedItem)
        modelObserver.modelDidChange()
    }

    @IBAction func depthStencilStateSelected(_ sender: NSPopUpButton) {
        let selectedItem = sender.selectedItem!

        guard let selectionObject = selectedItem.representedObject else {
            renderInvocation.depthStencilState = nil
            modelObserver.modelDidChange()
            return
        }

        renderInvocation.depthStencilState = (selectionObject as! DepthStencilState)
        modelObserver.modelDidChange()
    }

    @IBAction func windingOrderSelected(_ sender: NSPopUpButton) {
        renderInvocation.frontFacingWinding = NSNumber(sender.indexOfSelectedItem)
        modelObserver.modelDidChange()
    }

    @IBAction func scissorRectChecked(_ sender: NSButton) {
        if sender.state == NSOnState {
            let scissorRect = NSEntityDescription.insertNewObject(forEntityName: "ScissorRect", into: managedObjectContext!) as! ScissorRect
            scissorRect.x = 0
            scissorRect.y = 0
            scissorRect.width = 0
            scissorRect.height = 0
            renderInvocation.scissorRect = scissorRect
            scissorRectXTextField.integerValue = scissorRect.x.intValue
            scissorRectYTextField.integerValue = scissorRect.y.intValue
            scissorRectWidthTextField.integerValue = scissorRect.width.intValue
            scissorRectHeightTextField.integerValue = scissorRect.height.intValue
            scissorRectXTextField.isEnabled = true
            scissorRectYTextField.isEnabled = true
            scissorRectWidthTextField.isEnabled = true
            scissorRectHeightTextField.isEnabled = true
        } else {
            let scissorRect = renderInvocation.scissorRect!
            renderInvocation.scissorRect = nil
            managedObjectContext.delete(scissorRect)
            scissorRectXTextField.stringValue = ""
            scissorRectYTextField.stringValue = ""
            scissorRectWidthTextField.stringValue = ""
            scissorRectHeightTextField.stringValue = ""
            scissorRectXTextField.isEnabled = false
            scissorRectYTextField.isEnabled = false
            scissorRectWidthTextField.isEnabled = false
            scissorRectHeightTextField.isEnabled = false
        }
        modelObserver.modelDidChange()
    }

    @IBAction func scissorRectXSet(_ sender: NSTextField) {
        renderInvocation.scissorRect!.x = NSNumber(sender.integerValue)
        modelObserver.modelDidChange()
    }

    @IBAction func scissorRectYSet(_ sender: NSTextField) {
        renderInvocation.scissorRect!.y = NSNumber(sender.integerValue)
        modelObserver.modelDidChange()
    }

    @IBAction func scissorRectWidthSet(_ sender: NSTextField) {
        renderInvocation.scissorRect!.width = NSNumber(sender.integerValue)
        modelObserver.modelDidChange()
    }

    @IBAction func scissorRectHeightSet(_ sender: NSTextField) {
        renderInvocation.scissorRect!.height = NSNumber(sender.integerValue)
        modelObserver.modelDidChange()
    }

    @IBAction func stencilFrontReferenceValueSet(_ sender: NSTextField) {
        renderInvocation.stencilFrontReferenceValue = NSNumber(sender.integerValue)
        modelObserver.modelDidChange()
    }

    @IBAction func stencilBackReferenceValueSet(_ sender: NSTextField) {
        renderInvocation.stencilBackReferenceValue = NSNumber(sender.integerValue)
        modelObserver.modelDidChange()
    }

    @IBAction func triangleFillModeSelected(_ sender: NSPopUpButton) {
        renderInvocation.triangleFillMode = NSNumber(sender.indexOfSelectedItem)
        modelObserver.modelDidChange()
    }

    @IBAction func viewportChecked(_ sender: NSButton) {
        if sender.state == NSOnState {
            let viewport = NSEntityDescription.insertNewObject(forEntityName: "Viewport", into: managedObjectContext!) as! Viewport
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
            viewportOriginXTextField.isEnabled = true
            viewportOriginYTextField.isEnabled = true
            viewportWidthTextField.isEnabled = true
            viewportHeightTextField.isEnabled = true
            viewportZNearTextField.isEnabled = true
            viewportZFarTextField.isEnabled = true
        } else {
            let viewport = renderInvocation.viewport!
            renderInvocation.viewport = nil
            managedObjectContext.delete(viewport)
            viewportOriginXTextField.stringValue = ""
            viewportOriginYTextField.stringValue = ""
            viewportWidthTextField.stringValue = ""
            viewportHeightTextField.stringValue = ""
            viewportZNearTextField.stringValue = ""
            viewportZFarTextField.stringValue = ""
            viewportOriginXTextField.isEnabled = false
            viewportOriginYTextField.isEnabled = false
            viewportWidthTextField.isEnabled = false
            viewportHeightTextField.isEnabled = false
            viewportZNearTextField.isEnabled = false
            viewportZFarTextField.isEnabled = false
        }
        modelObserver.modelDidChange()
    }

    @IBAction func viewportOriginXSet(_ sender: NSTextField) {
        renderInvocation.viewport!.originX = NSNumber(value: sender.doubleValue)
        modelObserver.modelDidChange()
    }

    @IBAction func viewportOriginYSet(_ sender: NSTextField) {
        renderInvocation.viewport!.originY = NSNumber(value: sender.doubleValue)
        modelObserver.modelDidChange()
    }

    @IBAction func viewportWidthSet(_ sender: NSTextField) {
        renderInvocation.viewport!.width = NSNumber(value: sender.doubleValue)
        modelObserver.modelDidChange()
    }

    @IBAction func viewportHeightSet(_ sender: NSTextField) {
        renderInvocation.viewport!.height = NSNumber(value: sender.doubleValue)
        modelObserver.modelDidChange()
    }

    @IBAction func viewportZNearSet(_ sender: NSTextField) {
        renderInvocation.viewport!.zNear = NSNumber(value: sender.doubleValue)
        modelObserver.modelDidChange()
    }

    @IBAction func viewportZFarSet(_ sender: NSTextField) {
        renderInvocation.viewport!.zFar = NSNumber(value: sender.doubleValue)
        modelObserver.modelDidChange()
    }

    @IBAction func visibilityResultModeSelected(_ sender: NSPopUpButton) {
        renderInvocation.visibilityResultMode = NSNumber(sender.indexOfSelectedItem)
        modelObserver.modelDidChange()
    }

    @IBAction func visibilityResultOffsetSet(_ sender: NSTextField) {
        renderInvocation.visibilityResultOffset = NSNumber(sender.integerValue)
        modelObserver.modelDidChange()
    }

    @IBAction func dismiss(_ sender: NSButton) {
        dismissObserver.dismiss(self)
    }
}
