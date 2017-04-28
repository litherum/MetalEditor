//
//  DepthStencilStateViewController.swift
//  MetalEditor
//
//  Created by Litherum on 8/30/15.
//  Copyright © 2015 Litherum. All rights reserved.
//

import Cocoa

class DepthStencilStateViewController: NSViewController {
    var managedObjectContext: NSManagedObjectContext!
    weak var modelObserver: ModelObserver!
    weak var removeObserver: DepthStencilStateRemoveObserver!
    var state: DepthStencilState!
    @IBOutlet var nameTextField: NSTextField!
    @IBOutlet var depthCompareFunctionPopUp: NSPopUpButton!
    @IBOutlet var depthWriteEnabledCheckBox: NSButton!
    @IBOutlet var stencilFailureOperationFrontPopUp: NSPopUpButton!
    @IBOutlet var depthFailureOperationFrontPopUp: NSPopUpButton!
    @IBOutlet var depthStencilPassOperationFrontPopUp: NSPopUpButton!
    @IBOutlet var stencilCompareFunctionFrontPopUp: NSPopUpButton!
    @IBOutlet var readMaskFrontTextField: NSTextField!
    @IBOutlet var writeMaskFrontTextField: NSTextField!
    @IBOutlet var stencilFailureOperationBackPopUp: NSPopUpButton!
    @IBOutlet var depthFailureOperationBackPopUp: NSPopUpButton!
    @IBOutlet var depthStencilPassOperationBackPopUp: NSPopUpButton!
    @IBOutlet var stencilCompareFunctionBackPopUp: NSPopUpButton!
    @IBOutlet var readMaskBackTextField: NSTextField!
    @IBOutlet var writeMaskBackTextField: NSTextField!

    init?(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?, managedObjectContext: NSManagedObjectContext, modelObserver: ModelObserver, state: DepthStencilState, removeObserver: DepthStencilStateRemoveObserver) {
        self.managedObjectContext = managedObjectContext
        self.modelObserver = modelObserver
        self.removeObserver = removeObserver
        self.state = state
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        nameTextField.stringValue = state.name
        depthCompareFunctionPopUp.selectItem(at: state.depthCompareFunction.intValue)
        depthWriteEnabledCheckBox.state = state.depthWriteEnabled.boolValue ? NSOnState : NSOffState
        stencilFailureOperationFrontPopUp.selectItem(at: state.frontFaceStencil.stencilFailureOperation.intValue)
        depthFailureOperationFrontPopUp.selectItem(at: state.frontFaceStencil.depthFailureOperation.intValue)
        depthStencilPassOperationFrontPopUp.selectItem(at: state.frontFaceStencil.depthStencilPassOperation.intValue)
        stencilCompareFunctionFrontPopUp.selectItem(at: state.frontFaceStencil.stencilCompareFunction.intValue)
        readMaskFrontTextField.integerValue = state.frontFaceStencil.readMask.intValue
        writeMaskFrontTextField.integerValue = state.frontFaceStencil.writeMask.intValue
        stencilFailureOperationBackPopUp.selectItem(at: state.backFaceStencil.stencilFailureOperation.intValue)
        depthFailureOperationBackPopUp.selectItem(at: state.backFaceStencil.depthFailureOperation.intValue)
        depthStencilPassOperationBackPopUp.selectItem(at: state.backFaceStencil.depthStencilPassOperation.intValue)
        stencilCompareFunctionBackPopUp.selectItem(at: state.backFaceStencil.stencilCompareFunction.intValue)
        readMaskBackTextField.integerValue = state.backFaceStencil.readMask.intValue
        writeMaskBackTextField.integerValue = state.backFaceStencil.writeMask.intValue
    }

    @IBAction func nameSet(_ sender: NSTextField) {
        state.name = sender.stringValue
        modelObserver.modelDidChange()
    }

    @IBAction func depthCompareFunctionSelected(_ sender: NSPopUpButton) {
        state.depthCompareFunction = NSNumber(sender.indexOfSelectedItem)
        modelObserver.modelDidChange()
    }

    @IBAction func depthWriteEnabledChecked(_ sender: NSButton) {
        state.depthWriteEnabled = NSNumber(value: sender.state == NSOnState)
        modelObserver.modelDidChange()
    }

    @IBAction func stencilFailureOperationFrontSelected(_ sender: NSPopUpButton) {
        state.frontFaceStencil.stencilFailureOperation = NSNumber(sender.indexOfSelectedItem)
        modelObserver.modelDidChange()
    }

    @IBAction func depthFailureOperationFrontSelected(_ sender: NSPopUpButton) {
        state.frontFaceStencil.depthFailureOperation = NSNumber(sender.indexOfSelectedItem)
        modelObserver.modelDidChange()
    }

    @IBAction func depthStencilPassOperationFrontSelected(_ sender: NSPopUpButton) {
        state.frontFaceStencil.depthStencilPassOperation = NSNumber(sender.indexOfSelectedItem)
        modelObserver.modelDidChange()
    }

    @IBAction func stencilCompareFunctionFrontSelected(_ sender: NSPopUpButton) {
        state.frontFaceStencil.stencilCompareFunction = NSNumber(sender.indexOfSelectedItem)
        modelObserver.modelDidChange()
    }

    @IBAction func readMaskFrontSet(_ sender: NSTextField) {
        state.frontFaceStencil.readMask = NSNumber(sender.integerValue)
        modelObserver.modelDidChange()
    }

    @IBAction func writeMaskFrontSet(_ sender: NSTextField) {
        state.frontFaceStencil.writeMask = NSNumber(sender.integerValue)
        modelObserver.modelDidChange()
    }

    @IBAction func stencilFailureOperationBackSelected(_ sender: NSPopUpButton) {
        state.backFaceStencil.stencilFailureOperation = NSNumber(sender.indexOfSelectedItem)
        modelObserver.modelDidChange()
    }

    @IBAction func depthFailureOperationBackSelected(_ sender: NSPopUpButton) {
        state.backFaceStencil.depthFailureOperation = NSNumber(sender.indexOfSelectedItem)
        modelObserver.modelDidChange()
    }

    @IBAction func depthStencilPassOperationBackSelected(_ sender: NSPopUpButton) {
        state.backFaceStencil.depthStencilPassOperation = NSNumber(sender.indexOfSelectedItem)
        modelObserver.modelDidChange()
    }

    @IBAction func stencilCompareFunctionBackSelected(_ sender: NSPopUpButton) {
        state.backFaceStencil.stencilCompareFunction = NSNumber(sender.indexOfSelectedItem)
        modelObserver.modelDidChange()
    }

    @IBAction func readMaskBackSet(_ sender: NSTextField) {
        state.backFaceStencil.readMask = NSNumber(sender.integerValue)
        modelObserver.modelDidChange()
    }

    @IBAction func writeMaskBackSet(_ sender: NSTextField) {
        state.backFaceStencil.writeMask = NSNumber(sender.integerValue)
        modelObserver.modelDidChange()
    }

    @IBAction func removePressed(_ sender: NSButton) {
        removeObserver.removeDepthStencilState(self)
    }
}
