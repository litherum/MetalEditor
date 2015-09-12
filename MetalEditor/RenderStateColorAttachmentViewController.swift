//
//  RenderStateColorAttachmentViewController.swift
//  MetalEditor
//
//  Created by Litherum on 9/12/15.
//  Copyright © 2015 Litherum. All rights reserved.
//

import Cocoa

protocol RenderStateColorAttachmentRemoveObserver: class {
    func remove(viewController: RenderStateColorAttachmentViewController)
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

    init?(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?, modelObserver: ModelObserver, removeObserver: RenderStateColorAttachmentRemoveObserver, colorAttachment: RenderPipelineColorAttachment) {
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
            let pixelFormat = MTLPixelFormat(rawValue: attachmentPixelFormat.unsignedLongValue)!
            pixelFormatPopUp.selectItemAtIndex(pixelFormatToIndex(pixelFormat) + 1)
        } else {
            pixelFormatPopUp.selectItemAtIndex(0)
        }
        redWriteMaskCheckBox.state = colorAttachment.writeRed.boolValue ? NSOnState : NSOffState
        greenWriteMaskCheckBox.state = colorAttachment.writeGreen.boolValue ? NSOnState : NSOffState
        blueWriteMaskCheckBox.state = colorAttachment.writeBlue.boolValue ? NSOnState : NSOffState
        alphaWriteMaskCheckBox.state = colorAttachment.writeAlpha.boolValue ? NSOnState : NSOffState
        blendingCheckBox.state = colorAttachment.blendingEnabled.boolValue ? NSOnState : NSOffState
        rgbBlendOpCheckBox.enabled = colorAttachment.blendingEnabled.boolValue
        alphaBlendOpCheckBox.enabled = colorAttachment.blendingEnabled.boolValue
        rgbSourceBlendFactorCheckBox.enabled = colorAttachment.blendingEnabled.boolValue
        alphaSourceBlendFactorCheckBox.enabled = colorAttachment.blendingEnabled.boolValue
        rgbDestBlendFactorCheckBox.enabled = colorAttachment.blendingEnabled.boolValue
        alphaDestBlendFactorCheckBox.enabled = colorAttachment.blendingEnabled.boolValue
        rgbBlendOpCheckBox.selectItemAtIndex(colorAttachment.rgbBlendOperation.integerValue)
        alphaBlendOpCheckBox.selectItemAtIndex(colorAttachment.alphaBlendOperation.integerValue)
        rgbSourceBlendFactorCheckBox.selectItemAtIndex(colorAttachment.sourceRGBBlendFactor.integerValue)
        alphaSourceBlendFactorCheckBox.selectItemAtIndex(colorAttachment.sourceAlphaBlendFactor.integerValue)
        rgbDestBlendFactorCheckBox.selectItemAtIndex(colorAttachment.destinationRGBBlendFactor.integerValue)
        alphaDestBlendFactorCheckBox.selectItemAtIndex(colorAttachment.destinationAlphaBlendFactor.integerValue)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        pixelFormatPopUp.menu = pixelFormatMenu(true)
        setFieldsFromColorAttachment()
    }
    
    @IBAction func pixelFormatSelected(sender: NSPopUpButton) {
        guard sender.indexOfSelectedItem > 0 else {
            colorAttachment.pixelFormat = nil
            modelObserver.modelDidChange()
            return
        }
        let format = indexToPixelFormat(sender.indexOfSelectedItem - 1)!
        colorAttachment.pixelFormat = format.rawValue
        modelObserver.modelDidChange()
    }

    @IBAction func writeMaskChecked(sender: NSButton) {
        colorAttachment.writeRed = redWriteMaskCheckBox.state == NSOnState
        colorAttachment.writeGreen = greenWriteMaskCheckBox.state == NSOnState
        colorAttachment.writeBlue = blueWriteMaskCheckBox.state == NSOnState
        colorAttachment.writeAlpha = alphaWriteMaskCheckBox.state == NSOnState
        modelObserver.modelDidChange()
    }

    @IBAction func blendingChecked(sender: NSButton) {
        colorAttachment.blendingEnabled = sender.state == NSOnState
        setFieldsFromColorAttachment()
        modelObserver.modelDidChange()
    }

    @IBAction func rgbBlendOpSelected(sender: NSPopUpButton) {
        colorAttachment.rgbBlendOperation = sender.indexOfSelectedItem
        modelObserver.modelDidChange()
    }

    @IBAction func alphaBlendOpSelected(sender: NSPopUpButton) {
        colorAttachment.alphaBlendOperation = sender.indexOfSelectedItem
        modelObserver.modelDidChange()
    }

    @IBAction func rgbSourceBlendFactorSelected(sender: NSPopUpButton) {
        colorAttachment.sourceRGBBlendFactor = sender.indexOfSelectedItem
        modelObserver.modelDidChange()
    }

    @IBAction func alphaSourceBlendFactorSelected(sender: NSPopUpButton) {
        colorAttachment.sourceAlphaBlendFactor = sender.indexOfSelectedItem
        modelObserver.modelDidChange()
    }

    @IBAction func rgbDestBlendFactorSelected(sender: NSPopUpButton) {
        colorAttachment.destinationRGBBlendFactor = sender.indexOfSelectedItem
        modelObserver.modelDidChange()
    }

    @IBAction func alphaDestBlendFactorSelected(sender: NSPopUpButton) {
        colorAttachment.destinationAlphaBlendFactor = sender.indexOfSelectedItem
        modelObserver.modelDidChange()
    }

    @IBAction func removePushed(sender: NSButton) {
        removeObserver.remove(self)
    }
}
