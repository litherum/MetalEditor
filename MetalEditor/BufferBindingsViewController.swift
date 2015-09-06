//
//  BufferBindingsViewController.swift
//  MetalEditor
//
//  Created by Litherum on 8/16/15.
//  Copyright © 2015 Litherum. All rights reserved.
//

import Cocoa

class BufferBindingsViewController: BindingsViewController {
    override func itemSelected(sender: NSPopUpButton) {
        let row = tableView.rowForView(sender)
        let binding = bindings[row] as! BufferBinding
        let selectedItem = sender.selectedItem!

        guard let selectionObject = selectedItem.representedObject else {
            binding.buffer = nil
            modelObserver.modelDidChange()
            return
        }

        binding.buffer = (selectionObject as! Buffer)
        modelObserver.modelDidChange()
    }

    override func generatePopUp(index: Int) -> (NSMenu, NSMenuItem?) {
        let currentBinding = bindings[index] as! BufferBinding

        let fetchRequest = NSFetchRequest(entityName: "Buffer")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "id", ascending: true)]

        var selectedItem: NSMenuItem?
        do {
            let buffers = try managedObjectContext.executeFetchRequest(fetchRequest) as! [Buffer]
            let result = NSMenu()
            result.addItem(NSMenuItem(title: "None", action: nil, keyEquivalent: ""))
            for buffer in buffers {
                let item = NSMenuItem(title: buffer.name, action: nil, keyEquivalent: "")
                item.representedObject = buffer
                result.addItem(item)
                if let bindingBuffer = currentBinding.buffer {
                    if bindingBuffer == buffer {
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
