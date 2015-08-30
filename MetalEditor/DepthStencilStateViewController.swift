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

    init?(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?, managedObjectContext: NSManagedObjectContext, modelObserver: ModelObserver, state: DepthStencilState, removeObserver: DepthStencilStateRemoveObserver) {
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
        depthCompareFunctionPopUp.selectItemAtIndex(state.depthCompareFunction.integerValue)
        depthWriteEnabledCheckBox.state = state.depthWriteEnabled.boolValue ? NSOnState : NSOffState
        stencilFailureOperationFrontPopUp.selectItemAtIndex(state.frontFaceStencil.stencilFailureOperation.integerValue)
        depthFailureOperationFrontPopUp.selectItemAtIndex(state.frontFaceStencil.depthFailureOperation.integerValue)
        depthStencilPassOperationFrontPopUp.selectItemAtIndex(state.frontFaceStencil.depthStencilPassOperation.integerValue)
        stencilCompareFunctionFrontPopUp.selectItemAtIndex(state.frontFaceStencil.stencilCompareFunction.integerValue)
        readMaskFrontTextField.integerValue = state.frontFaceStencil.readMask.integerValue
        writeMaskFrontTextField.integerValue = state.frontFaceStencil.writeMask.integerValue
        stencilFailureOperationBackPopUp.selectItemAtIndex(state.backFaceStencil.stencilFailureOperation.integerValue)
        depthFailureOperationBackPopUp.selectItemAtIndex(state.backFaceStencil.depthFailureOperation.integerValue)
        depthStencilPassOperationBackPopUp.selectItemAtIndex(state.backFaceStencil.depthStencilPassOperation.integerValue)
        stencilCompareFunctionBackPopUp.selectItemAtIndex(state.backFaceStencil.stencilCompareFunction.integerValue)
        readMaskBackTextField.integerValue = state.backFaceStencil.readMask.integerValue
        writeMaskBackTextField.integerValue = state.backFaceStencil.writeMask.integerValue
    }

    @IBAction func nameSet(sender: NSTextField) {
        state.name = sender.stringValue
        modelObserver.modelDidChange()
    }

    @IBAction func depthCompareFunctionSelected(sender: NSPopUpButton) {
        state.depthCompareFunction = sender.indexOfSelectedItem
        modelObserver.modelDidChange()
    }

    @IBAction func depthWriteEnabledChecked(sender: NSButton) {
        state.depthWriteEnabled = sender.state == NSOnState
        modelObserver.modelDidChange()
    }

    @IBAction func stencilFailureOperationFrontSelected(sender: NSPopUpButton) {
        state.frontFaceStencil.stencilFailureOperation = sender.indexOfSelectedItem
        modelObserver.modelDidChange()
    }

    @IBAction func depthFailureOperationFrontSelected(sender: NSPopUpButton) {
        state.frontFaceStencil.depthFailureOperation = sender.indexOfSelectedItem
        modelObserver.modelDidChange()
    }

    @IBAction func depthStencilPassOperationFrontSelected(sender: NSPopUpButton) {
        state.frontFaceStencil.depthStencilPassOperation = sender.indexOfSelectedItem
        modelObserver.modelDidChange()
    }

    @IBAction func stencilCompareFunctionFrontSelected(sender: NSPopUpButton) {
        state.frontFaceStencil.stencilCompareFunction = sender.indexOfSelectedItem
        modelObserver.modelDidChange()
    }

    @IBAction func readMaskFrontSet(sender: NSTextField) {
        state.frontFaceStencil.readMask = sender.integerValue
        modelObserver.modelDidChange()
    }

    @IBAction func writeMaskFrontSet(sender: NSTextField) {
        state.frontFaceStencil.writeMask = sender.integerValue
        modelObserver.modelDidChange()
    }

    @IBAction func stencilFailureOperationBackSelected(sender: NSPopUpButton) {
        state.backFaceStencil.stencilFailureOperation = sender.indexOfSelectedItem
        modelObserver.modelDidChange()
    }

    @IBAction func depthFailureOperationBackSelected(sender: NSPopUpButton) {
        state.backFaceStencil.depthFailureOperation = sender.indexOfSelectedItem
        modelObserver.modelDidChange()
    }

    @IBAction func depthStencilPassOperationBackSelected(sender: NSPopUpButton) {
        state.backFaceStencil.depthStencilPassOperation = sender.indexOfSelectedItem
        modelObserver.modelDidChange()
    }

    @IBAction func stencilCompareFunctionBackSelected(sender: NSPopUpButton) {
        state.backFaceStencil.stencilCompareFunction = sender.indexOfSelectedItem
        modelObserver.modelDidChange()
    }

    @IBAction func readMaskBackSet(sender: NSTextField) {
        state.backFaceStencil.readMask = sender.integerValue
        modelObserver.modelDidChange()
    }

    @IBAction func writeMaskBackSet(sender: NSTextField) {
        state.backFaceStencil.writeMask = sender.integerValue
        modelObserver.modelDidChange()
    }

    @IBAction func removePressed(sender: NSButton) {
        removeObserver.removeDepthStencilState(self)
    }
}
