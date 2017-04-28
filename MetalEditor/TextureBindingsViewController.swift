//
//  TextureBindingsViewController.swift
//  MetalEditor
//
//  Created by Litherum on 8/16/15.
//  Copyright © 2015 Litherum. All rights reserved.
//

import Cocoa

class TextureBindingsViewController: BindingsViewController {
    override func itemSelected(sender: NSPopUpButton) {
        let row = tableView.row(for: sender)
        let binding = bindings[row] as! TextureBinding
        let selectedItem = sender.selectedItem!

        guard let selectionObject = selectedItem.representedObject else {
            binding.texture = nil
            return
        }

        binding.texture = (selectionObject as! Texture)
        modelObserver.modelDidChange()
    }

    override func generatePopUp( index: Int) -> (NSMenu, NSMenuItem?) {
        let currentBinding = bindings[index] as! TextureBinding

        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Texture")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "id", ascending: true)]

        var selectedItem: NSMenuItem?
        do {
            let textures = try managedObjectContext.fetch(fetchRequest) as! [Texture]
            let result = NSMenu()
            result.addItem(NSMenuItem(title: "None", action: nil, keyEquivalent: ""))
            for texture in textures {
                let item = NSMenuItem(title: texture.name, action: nil, keyEquivalent: "")
                item.representedObject = texture
                result.addItem(item)
                if let bindingTexture = currentBinding.texture {
                    if bindingTexture == texture {
                        selectedItem = item
                    }
                }
            }
            return (result, selectedItem)
        } catch {
            fatalError()
        }
    }
}
