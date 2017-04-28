//
//  RenderPassAttachmentViewController.swift
//  MetalEditor
//
//  Created by Litherum on 8/30/15.
//  Copyright © 2015 Litherum. All rights reserved.
//

import Cocoa

class RenderPassAttachmentViewController: NSViewController {
    var managedObjectContext: NSManagedObjectContext!
    weak var modelObserver: ModelObserver!
    var renderPassAttachment: RenderPassAttachment
    @IBOutlet var texturePopUp: NSPopUpButton!
    @IBOutlet var levelTextField: NSTextField!
    @IBOutlet var sliceTextField: NSTextField!
    @IBOutlet var depthPlaneTextField: NSTextField!
    @IBOutlet var loadActionPopUp: NSPopUpButton!
    @IBOutlet var storeActionPopUp: NSPopUpButton!
    @IBOutlet var resolveTexturePopUp: NSPopUpButton!
    @IBOutlet var resolveLevelTextField: NSTextField!
    @IBOutlet var resolveSliceTextField: NSTextField!
    @IBOutlet var resolveDepthPlaneTextField: NSTextField!

    init?(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?, managedObjectContext: NSManagedObjectContext, modelObserver: ModelObserver, renderPassAttachment: RenderPassAttachment) {
        self.managedObjectContext = managedObjectContext
        self.modelObserver = modelObserver
        self.renderPassAttachment = renderPassAttachment
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    func createTextureMenu(_ currentTexture: Texture?) -> (NSMenu, NSMenuItem?) {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Texture")

        var selectedItem: NSMenuItem?
        do {
            let textures = try managedObjectContext.fetch(fetchRequest) as! [Texture]
            let result = NSMenu()
            result.addItem(NSMenuItem(title: "None", action: nil, keyEquivalent: ""))
            for texture in textures {
                let item = NSMenuItem(title: texture.name, action: nil, keyEquivalent: "")
                item.representedObject = texture
                result.addItem(item)
                if let lookFor = currentTexture {
                    if lookFor == texture {
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
        super.viewDidLoad()

        let (textureMenu, textureSelectedItem) = createTextureMenu(renderPassAttachment.texture)
        texturePopUp.menu = textureMenu
        if let toSelect = textureSelectedItem {
            texturePopUp.select(toSelect)
        } else {
            texturePopUp.selectItem(at: 0)
        }
        levelTextField.integerValue = renderPassAttachment.level.intValue
        sliceTextField.integerValue = renderPassAttachment.slice.intValue
        depthPlaneTextField.integerValue = renderPassAttachment.depthPlane.intValue
        loadActionPopUp.selectItem(at: renderPassAttachment.loadAction.intValue)
        storeActionPopUp.selectItem(at: renderPassAttachment.storeAction.intValue)
        let (resolveTextureMenu, resolveTextureSelectedItem) = createTextureMenu(renderPassAttachment.resolveTexture)
        resolveTexturePopUp.menu = resolveTextureMenu
        if let toSelect = resolveTextureSelectedItem {
            resolveTexturePopUp.select(toSelect)
        } else {
            resolveTexturePopUp.selectItem(at: 0)
        }
        resolveLevelTextField.integerValue = renderPassAttachment.resolveLevel.intValue
        resolveSliceTextField.integerValue = renderPassAttachment.resolveSlice.intValue
        resolveDepthPlaneTextField.integerValue = renderPassAttachment.resolveDepthPlane.intValue
    }

    @IBAction func textureSelected(_ sender: NSPopUpButton) {
        let selectedItem = sender.selectedItem!

        guard let selectionObject = selectedItem.representedObject else {
            renderPassAttachment.texture = nil
            modelObserver.modelDidChange()
            return
        }

        renderPassAttachment.texture = (selectionObject as! Texture)
        modelObserver.modelDidChange()
    }

    @IBAction func levelSet(_ sender: NSTextField) {
        renderPassAttachment.level = NSNumber(sender.integerValue)
        modelObserver.modelDidChange()
    }

    @IBAction func sliceSet(_ sender: NSTextField) {
        renderPassAttachment.slice = NSNumber(sender.integerValue)
        modelObserver.modelDidChange()
    }

    @IBAction func depthPlaneSet(_ sender: NSTextField) {
        renderPassAttachment.depthPlane = NSNumber(sender.integerValue)
        modelObserver.modelDidChange()
    }

    @IBAction func loadActionSelected(_ sender: NSPopUpButton) {
        renderPassAttachment.loadAction = NSNumber(sender.indexOfSelectedItem)
        modelObserver.modelDidChange()
    }

    @IBAction func storeActionSelected(_ sender: NSPopUpButton) {
        renderPassAttachment.loadAction = NSNumber(sender.indexOfSelectedItem)
        modelObserver.modelDidChange()
    }

    @IBAction func resolveTextureSelected(_ sender: NSPopUpButton) {
        let selectedItem = sender.selectedItem!

        guard let selectionObject = selectedItem.representedObject else {
            renderPassAttachment.resolveTexture = nil
            modelObserver.modelDidChange()
            return
        }

        renderPassAttachment.resolveTexture = (selectionObject as! Texture)
        modelObserver.modelDidChange()
    }

    @IBAction func resolveLevelSet(_ sender: NSTextField) {
        renderPassAttachment.resolveLevel = NSNumber(sender.integerValue)
        modelObserver.modelDidChange()
    }

    @IBAction func resolveSliceSet(_ sender: NSTextField) {
        renderPassAttachment.resolveSlice = NSNumber(sender.integerValue)
        modelObserver.modelDidChange()
    }

    @IBAction func resolveDepthPlaneSet(_ sender: NSTextField) {
        renderPassAttachment.resolveDepthPlane = NSNumber(sender.integerValue)
        modelObserver.modelDidChange()
    }

}
