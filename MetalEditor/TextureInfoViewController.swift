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
    func remove(_ controller: TextureInfoViewController)
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

    init?(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?, modelObserver: ModelObserver, removeObserver: TextureRemoveObserver, texture: Texture, device: MTLDevice) {
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
        typePopUp.selectItem(at: texture.textureType.intValue)
        let pixelFormat = MTLPixelFormat(rawValue: texture.pixelFormat.uintValue)!
        pixelFormatPopUp.selectItem(at: pixelFormatToIndex(pixelFormat))
        widthTextField.integerValue = texture.width.intValue
        heightTextField.integerValue = texture.height.intValue
        depthTextField.integerValue = texture.depth.intValue
        mipmapLevelCountTextField.integerValue = texture.mipmapLevelCount.intValue
        sampleCountTextField.integerValue = texture.sampleCount.intValue
        arrayLengthTextField.integerValue = texture.arrayLength.intValue
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        pixelFormatPopUp.menu = pixelFormatMenu(false)
        setFieldsFromTexture()
    }

    @IBAction func nameSet(_ sender: NSTextField) {
        texture.name = sender.stringValue
        modelObserver.modelDidChange()
    }

    @IBAction func remove(_ sender: NSButton) {
        removeObserver.remove(self)
    }

    @IBAction func setContentsPushed(_ sender: NSButton) {
        let window = view.window!
        let openPanel = NSOpenPanel()
        openPanel.allowsMultipleSelection = false
        openPanel.beginSheetModal(for: window) {(selected: Int) in
            guard selected == NSFileHandlingPanelOKButton else {
                return
            }
            guard let url = openPanel.url else {
                return
            }
            guard let contents = try? Data(contentsOf: url) else {
                return
            }
            do {
                let loader = MTKTextureLoader(device: self.device)
                let newTexture = try loader.newTexture(withContentsOf: url, options: nil)
                self.texture.initialData = contents
                self.texture.arrayLength = NSNumber(newTexture.arrayLength)
                self.texture.depth =  NSNumber(value: newTexture.depth)
                self.texture.height =  NSNumber(value: newTexture.height)
                self.texture.width =  NSNumber(value: newTexture.width)
                self.texture.mipmapLevelCount =  NSNumber(value: newTexture.mipmapLevelCount)
                self.texture.pixelFormat =  NSNumber(value: newTexture.pixelFormat.rawValue)
                self.texture.sampleCount = NSNumber(newTexture.sampleCount)
                self.texture.textureType =  NSNumber(value: newTexture.textureType.rawValue)
                self.setFieldsFromTexture()
                self.modelObserver.modelDidChange()
            } catch let e {
                print("Could not load file \(url): \(e)")
                return
            }
        }
    }

    @IBAction func typeSelected(_ sender: NSPopUpButton) {
        texture.textureType =  NSNumber(value: sender.indexOfSelectedItem)
        texture.initialData = nil
        setFieldsFromTexture()
        modelObserver.modelDidChange()
    }

    @IBAction func pixelFormatSelected(_ sender: NSPopUpButton) {
        let format = indexToPixelFormat(sender.indexOfSelectedItem)!
        texture.pixelFormat = NSNumber(value: format.rawValue)
        texture.initialData = nil
        setFieldsFromTexture()
        modelObserver.modelDidChange()
    }

    @IBAction func widthSet(_ sender: NSTextField) {
        texture.width =  NSNumber(value: sender.integerValue)
        texture.initialData = nil
        setFieldsFromTexture()
        modelObserver.modelDidChange()
    }

    @IBAction func heightSet(_ sender: NSTextField) {
        texture.height =  NSNumber(value: sender.integerValue)
        texture.initialData = nil
        setFieldsFromTexture()
        modelObserver.modelDidChange()
    }

    @IBAction func depthSet(_ sender: NSTextField) {
        texture.depth =  NSNumber(value: sender.integerValue)
        texture.initialData = nil
        setFieldsFromTexture()
        modelObserver.modelDidChange()
    }

    @IBAction func mipmapLevelCountSet(_ sender: NSTextField) {
        texture.mipmapLevelCount =  NSNumber(value: sender.integerValue)
        texture.initialData = nil
        setFieldsFromTexture()
        modelObserver.modelDidChange()
    }

    @IBAction func sampleCountSet(_ sender: NSTextField) {
        texture.sampleCount =  NSNumber(value: sender.integerValue)
        texture.initialData = nil
        setFieldsFromTexture()
        modelObserver.modelDidChange()
    }

    @IBAction func arrayLengthSet(_ sender: NSTextField) {
        texture.arrayLength =  NSNumber(value: sender.integerValue)
        texture.initialData = nil
        setFieldsFromTexture()
        modelObserver.modelDidChange()
    }
}
