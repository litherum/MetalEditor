//
//  RenderStateColorAttachmentViewController.swift
//  MetalEditor
//
//  Created by Litherum on 9/12/15.
//  Copyright © 2015 Litherum. All rights reserved.
//

import Cocoa

protocol RenderStateColorAttachmentRemoveObserver: class {
    func remove(_ viewController: RenderStateColorAttachmentViewController)
}

class RenderStateColorAttachmentViewController: NSViewController {
    weak var modelObserver: ModelObserver!
    weak var removeObserver: RenderStateColorAttachmentRemoveObserver!
    var colorAttachment: RenderPipelineColorAttachment
    @IBOutlet var pixelFormatPopUp: NSPopUpButton!
    @IBOutlet var redWriteMaskCheckBox: NSButton!
    @IBOutlet var greenWriteMaskCheckBox: NSButton!
    @IBOutlet var blueWriteMaskCheckBox: NSButton!
    @IBOutlet var alphaWriteMaskCheckBox: NSButton!
    @IBOutlet var blendingCheckBox: NSButton!
    @IBOutlet var rgbBlendOpCheckBox: NSPopUpButton!
    @IBOutlet var alphaBlendOpCheckBox: NSPopUpButton!
    @IBOutlet var rgbSourceBlendFactorCheckBox: NSPopUpButton!
    @IBOutlet var alphaSourceBlendFactorCheckBox: NSPopUpButton!
    @IBOutlet var rgbDestBlendFactorCheckBox: NSPopUpButton!
    @IBOutlet var alphaDestBlendFactorCheckBox: NSPopUpButton!

    init?(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?, modelObserver: ModelObserver, removeObserver: RenderStateColorAttachmentRemoveObserver, colorAttachment: RenderPipelineColorAttachment) {
        self.modelObserver = modelObserver
        self.removeObserver = removeObserver
        self.colorAttachment = colorAttachment
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    func setFieldsFromColorAttachment() {
        if let attachmentPixelFormat = colorAttachment.pixelFormat {
            let pixelFormat = MTLPixelFormat(rawValue: attachmentPixelFormat.uintValue)!
            pixelFormatPopUp.selectItem(at: pixelFormatToIndex(pixelFormat) + 1)
        } else {
            pixelFormatPopUp.selectItem(at: 0)
        }
        redWriteMaskCheckBox.state = colorAttachment.writeRed.boolValue ? NSOnState : NSOffState
        greenWriteMaskCheckBox.state = colorAttachment.writeGreen.boolValue ? NSOnState : NSOffState
        blueWriteMaskCheckBox.state = colorAttachment.writeBlue.boolValue ? NSOnState : NSOffState
        alphaWriteMaskCheckBox.state = colorAttachment.writeAlpha.boolValue ? NSOnState : NSOffState
        blendingCheckBox.state = colorAttachment.blendingEnabled.boolValue ? NSOnState : NSOffState
        rgbBlendOpCheckBox.isEnabled = colorAttachment.blendingEnabled.boolValue
        alphaBlendOpCheckBox.isEnabled = colorAttachment.blendingEnabled.boolValue
        rgbSourceBlendFactorCheckBox.isEnabled = colorAttachment.blendingEnabled.boolValue
        alphaSourceBlendFactorCheckBox.isEnabled = colorAttachment.blendingEnabled.boolValue
        rgbDestBlendFactorCheckBox.isEnabled = colorAttachment.blendingEnabled.boolValue
        alphaDestBlendFactorCheckBox.isEnabled = colorAttachment.blendingEnabled.boolValue
        rgbBlendOpCheckBox.selectItem(at: colorAttachment.rgbBlendOperation.intValue)
        alphaBlendOpCheckBox.selectItem(at: colorAttachment.alphaBlendOperation.intValue)
        rgbSourceBlendFactorCheckBox.selectItem(at: colorAttachment.sourceRGBBlendFactor.intValue)
        alphaSourceBlendFactorCheckBox.selectItem(at: colorAttachment.sourceAlphaBlendFactor.intValue)
        rgbDestBlendFactorCheckBox.selectItem(at: colorAttachment.destinationRGBBlendFactor.intValue)
        alphaDestBlendFactorCheckBox.selectItem(at: colorAttachment.destinationAlphaBlendFactor.intValue)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        pixelFormatPopUp.menu = pixelFormatMenu(true)
        setFieldsFromColorAttachment()
    }
    
    @IBAction func pixelFormatSelected(_ sender: NSPopUpButton) {
        guard sender.indexOfSelectedItem > 0 else {
            colorAttachment.pixelFormat = nil
            modelObserver.modelDidChange()
            return
        }
        let format = indexToPixelFormat(sender.indexOfSelectedItem - 1)!
        colorAttachment.pixelFormat = NSNumber(value: format.rawValue)
        modelObserver.modelDidChange()
    }

    @IBAction func writeMaskChecked(_ sender: NSButton) {
        colorAttachment.writeRed = NSNumber(value: redWriteMaskCheckBox.state == NSOnState)
        colorAttachment.writeGreen = NSNumber(value: greenWriteMaskCheckBox.state == NSOnState)
        colorAttachment.writeBlue = NSNumber(value: blueWriteMaskCheckBox.state == NSOnState)
        colorAttachment.writeAlpha = NSNumber(value:  alphaWriteMaskCheckBox.state == NSOnState)
        modelObserver.modelDidChange()
    }

    @IBAction func blendingChecked(_ sender: NSButton) {
        colorAttachment.blendingEnabled = NSNumber(value:  sender.state == NSOnState)
        setFieldsFromColorAttachment()
        modelObserver.modelDidChange()
    }

    @IBAction func rgbBlendOpSelected(_ sender: NSPopUpButton) {
        colorAttachment.rgbBlendOperation =  NSNumber(value: sender.indexOfSelectedItem)
        modelObserver.modelDidChange()
    }

    @IBAction func alphaBlendOpSelected(_ sender: NSPopUpButton) {
        colorAttachment.alphaBlendOperation =  NSNumber(value: sender.indexOfSelectedItem)
        modelObserver.modelDidChange()
    }

    @IBAction func rgbSourceBlendFactorSelected(_ sender: NSPopUpButton) {
        colorAttachment.sourceRGBBlendFactor =  NSNumber(value: sender.indexOfSelectedItem)
        modelObserver.modelDidChange()
    }

    @IBAction func alphaSourceBlendFactorSelected(_ sender: NSPopUpButton) {
        colorAttachment.sourceAlphaBlendFactor =  NSNumber(value: sender.indexOfSelectedItem)
        modelObserver.modelDidChange()
    }

    @IBAction func rgbDestBlendFactorSelected(_ sender: NSPopUpButton) {
        colorAttachment.destinationRGBBlendFactor =  NSNumber(value: sender.indexOfSelectedItem)
        modelObserver.modelDidChange()
    }

    @IBAction func alphaDestBlendFactorSelected(_ sender: NSPopUpButton) {
        colorAttachment.destinationAlphaBlendFactor =  NSNumber(value: sender.indexOfSelectedItem)
        modelObserver.modelDidChange()
    }

    @IBAction func removePushed(_ sender: NSButton) {
        removeObserver.remove(self)
    }
}
