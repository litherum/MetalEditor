//
//  RenderStateViewController.swift
//  MetalEditor
//
//  Created by Litherum on 8/3/15.
//  Copyright © 2015 Litherum. All rights reserved.
//

import Cocoa

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

    func control(control: NSControl, isValidObject obj: AnyObject) -> Bool {
        return Int(obj as! String) != nil
    }

    @IBAction func sampleCountSet(sender: NSTextField) {
        state.sampleCount = sender.integerValue
        modelObserver.modelDidChange()
    }

    @IBAction func remove(sender: NSButton) {
        removeObserver.removeRenderPipelineState(self)
    }

}
