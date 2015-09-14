//
//  TextureInfoViewController.swift
//  MetalEditor
//
//  Created by Litherum on 9/12/15.
//  Copyright © 2015 Litherum. All rights reserved.
//

import Cocoa
import MetalKit

protocol TextureRemoveObserver: class {
    func remove(controller: TextureInfoViewController)
}

class TextureInfoViewController: NSViewController {
    weak var modelObserver: ModelObserver!
    weak var removeObserver: TextureRemoveObserver!
    var texture: Texture
    var device: MTLDevice! // Only needed because MTKTextureLoader can't directly give us a MTLTextureDescriptor
    @IBOutlet var nameTextField: NSTextField!
    @IBOutlet var initiallyPopulatedCheckBox: NSButton!
    @IBOutlet var typePopUp: NSPopUpButton!
    @IBOutlet var pixelFormatPopUp: NSPopUpButton!
    @IBOutlet var widthTextField: NSTextField!
    @IBOutlet var heightTextField: NSTextField!
    @IBOutlet var depthTextField: NSTextField!
    @IBOutlet var mipmapLevelCountTextField: NSTextField!
    @IBOutlet var sampleCountTextField: NSTextField!
    @IBOutlet var arrayLengthTextField: NSTextField!

    init?(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?, modelObserver: ModelObserver, removeObserver: TextureRemoveObserver, texture: Texture, device: MTLDevice) {
        self.modelObserver = modelObserver
        self.removeObserver = removeObserver
        self.texture = texture
        self.device = device
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    func setFieldsFromTexture() {
        nameTextField.stringValue = texture.name
        initiallyPopulatedCheckBox.state = texture.initialData == nil ? NSOffState : NSOnState
        typePopUp.selectItemAtIndex(texture.textureType.integerValue)
        let pixelFormat = MTLPixelFormat(rawValue: texture.pixelFormat.unsignedLongValue)!
        pixelFormatPopUp.selectItemAtIndex(pixelFormatToIndex(pixelFormat))
        widthTextField.integerValue = texture.width.integerValue
        heightTextField.integerValue = texture.height.integerValue
        depthTextField.integerValue = texture.depth.integerValue
        mipmapLevelCountTextField.integerValue = texture.mipmapLevelCount.integerValue
        sampleCountTextField.integerValue = texture.sampleCount.integerValue
        arrayLengthTextField.integerValue = texture.arrayLength.integerValue
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        pixelFormatPopUp.menu = pixelFormatMenu(false)
        setFieldsFromTexture()
    }

    @IBAction func nameSet(sender: NSTextField) {
        texture.name = sender.stringValue
        modelObserver.modelDidChange()
    }

    @IBAction func remove(sender: NSButton) {
        removeObserver.remove(self)
    }

    @IBAction func setContentsPushed(sender: NSButton) {
        let window = view.window!
        let openPanel = NSOpenPanel()
        openPanel.allowsMultipleSelection = false
        openPanel.beginSheetModalForWindow(window) {(selected: Int) in
            guard selected == NSFileHandlingPanelOKButton else {
                return
            }
            guard let url = openPanel.URL else {
                return
            }
            guard let contents = NSData(contentsOfURL: url) else {
                return
            }
            do {
                let loader = MTKTextureLoader(device: self.device)
                let newTexture = try loader.newTextureWithContentsOfURL(url, options: nil)
                self.texture.initialData = contents
                self.texture.arrayLength = newTexture.arrayLength
                self.texture.depth = newTexture.depth
                self.texture.height = newTexture.height
                self.texture.width = newTexture.width
                self.texture.mipmapLevelCount = newTexture.mipmapLevelCount
                self.texture.pixelFormat = newTexture.pixelFormat.rawValue
                self.texture.sampleCount = newTexture.sampleCount
                self.texture.textureType = newTexture.textureType.rawValue
                self.setFieldsFromTexture()
                self.modelObserver.modelDidChange()
            } catch let e {
                print("Could not load file \(url): \(e)")
                return
            }
        }
    }

    @IBAction func typeSelected(sender: NSPopUpButton) {
        texture.textureType = sender.indexOfSelectedItem
        texture.initialData = nil
        setFieldsFromTexture()
        modelObserver.modelDidChange()
    }

    @IBAction func pixelFormatSelected(sender: NSPopUpButton) {
        let format = indexToPixelFormat(sender.indexOfSelectedItem)!
        texture.pixelFormat = format.rawValue
        texture.initialData = nil
        setFieldsFromTexture()
        modelObserver.modelDidChange()
    }

    @IBAction func widthSet(sender: NSTextField) {
        texture.width = sender.integerValue
        texture.initialData = nil
        setFieldsFromTexture()
        modelObserver.modelDidChange()
    }

    @IBAction func heightSet(sender: NSTextField) {
        texture.height = sender.integerValue
        texture.initialData = nil
        setFieldsFromTexture()
        modelObserver.modelDidChange()
    }

    @IBAction func depthSet(sender: NSTextField) {
        texture.depth = sender.integerValue
        texture.initialData = nil
        setFieldsFromTexture()
        modelObserver.modelDidChange()
    }

    @IBAction func mipmapLevelCountSet(sender: NSTextField) {
        texture.mipmapLevelCount = sender.integerValue
        texture.initialData = nil
        setFieldsFromTexture()
        modelObserver.modelDidChange()
    }

    @IBAction func sampleCountSet(sender: NSTextField) {
        texture.sampleCount = sender.integerValue
        texture.initialData = nil
        setFieldsFromTexture()
        modelObserver.modelDidChange()
    }

    @IBAction func arrayLengthSet(sender: NSTextField) {
        texture.arrayLength = sender.integerValue
        texture.initialData = nil
        setFieldsFromTexture()
        modelObserver.modelDidChange()
    }
}
