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

    init?(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?, managedObjectContext: NSManagedObjectContext, modelObserver: ModelObserver, renderPassAttachment: RenderPassAttachment) {
        self.managedObjectContext = managedObjectContext
        self.modelObserver = modelObserver
        self.renderPassAttachment = renderPassAttachment
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    func createTextureMenu(currentTexture: Texture?) -> (NSMenu, NSMenuItem?) {
        let fetchRequest = NSFetchRequest(entityName: "Texture")

        var selectedItem: NSMenuItem?
        do {
            let textures = try managedObjectContext.executeFetchRequest(fetchRequest) as! [Texture]
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
            texturePopUp.selectItem(toSelect)
        } else {
            texturePopUp.selectItemAtIndex(0)
        }
        levelTextField.integerValue = renderPassAttachment.level.integerValue
        sliceTextField.integerValue = renderPassAttachment.slice.integerValue
        depthPlaneTextField.integerValue = renderPassAttachment.depthPlane.integerValue
        loadActionPopUp.selectItemAtIndex(renderPassAttachment.loadAction.integerValue)
        storeActionPopUp.selectItemAtIndex(renderPassAttachment.storeAction.integerValue)
        let (resolveTextureMenu, resolveTextureSelectedItem) = createTextureMenu(renderPassAttachment.resolveTexture)
        resolveTexturePopUp.menu = resolveTextureMenu
        if let toSelect = resolveTextureSelectedItem {
            resolveTexturePopUp.selectItem(toSelect)
        } else {
            resolveTexturePopUp.selectItemAtIndex(0)
        }
        resolveLevelTextField.integerValue = renderPassAttachment.resolveLevel.integerValue
        resolveSliceTextField.integerValue = renderPassAttachment.resolveSlice.integerValue
        resolveDepthPlaneTextField.integerValue = renderPassAttachment.resolveDepthPlane.integerValue
    }

    @IBAction func textureSelected(sender: NSPopUpButton) {
        let selectedItem = sender.selectedItem!

        guard let selectionObject = selectedItem.representedObject else {
            renderPassAttachment.texture = nil
            modelObserver.modelDidChange()
            return
        }

        renderPassAttachment.texture = (selectionObject as! Texture)
        modelObserver.modelDidChange()
    }

    @IBAction func levelSet(sender: NSTextField) {
        renderPassAttachment.level = sender.integerValue
        modelObserver.modelDidChange()
    }

    @IBAction func sliceSet(sender: NSTextField) {
        renderPassAttachment.slice = sender.integerValue
        modelObserver.modelDidChange()
    }

    @IBAction func depthPlaneSet(sender: NSTextField) {
        renderPassAttachment.depthPlane = sender.integerValue
        modelObserver.modelDidChange()
    }

    @IBAction func loadActionSelected(sender: NSPopUpButton) {
        renderPassAttachment.loadAction = sender.indexOfSelectedItem
        modelObserver.modelDidChange()
    }

    @IBAction func storeActionSelected(sender: NSPopUpButton) {
        renderPassAttachment.loadAction = sender.indexOfSelectedItem
        modelObserver.modelDidChange()
    }

    @IBAction func resolveTextureSelected(sender: NSPopUpButton) {
        let selectedItem = sender.selectedItem!

        guard let selectionObject = selectedItem.representedObject else {
            renderPassAttachment.resolveTexture = nil
            modelObserver.modelDidChange()
            return
        }

        renderPassAttachment.resolveTexture = (selectionObject as! Texture)
        modelObserver.modelDidChange()
    }

    @IBAction func resolveLevelSet(sender: NSTextField) {
        renderPassAttachment.resolveLevel = sender.integerValue
        modelObserver.modelDidChange()
    }

    @IBAction func resolveSliceSet(sender: NSTextField) {
        renderPassAttachment.resolveSlice = sender.integerValue
        modelObserver.modelDidChange()
    }

    @IBAction func resolveDepthPlaneSet(sender: NSTextField) {
        renderPassAttachment.resolveDepthPlane = sender.integerValue
        modelObserver.modelDidChange()
    }

}
