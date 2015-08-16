//
//  BufferBindingTableViewDelegate.swift
//  MetalEditor
//
//  Created by Litherum on 8/10/15.
//  Copyright © 2015 Litherum. All rights reserved.
//

import Cocoa

protocol BufferBindingRemoveObserver: class {
    func removeBufferBinding(controller: BufferBindingsViewController, binding: BufferBinding)
}

class BufferBindingsViewController: NSViewController, NSTableViewDelegate, NSTableViewDataSource {
    var managedObjectContext: NSManagedObjectContext!
    weak var modelObserver: ModelObserver!
    weak var removeObserver: BufferBindingRemoveObserver!
    var bufferBindings: NSOrderedSet!
    @IBOutlet var tableView: NSTableView!
    @IBOutlet var numberTableColumn: NSTableColumn!
    @IBOutlet var popUpTableColumn: NSTableColumn!
    @IBOutlet var removeTableColumn: NSTableColumn!

    init?(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?, managedObjectContext: NSManagedObjectContext, modelObserver: ModelObserver, removeObserver: BufferBindingRemoveObserver, bufferBindings: NSOrderedSet) {
        self.managedObjectContext = managedObjectContext
        self.modelObserver = modelObserver
        self.removeObserver = removeObserver
        self.bufferBindings = bufferBindings
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    func reloadData() {
        tableView.reloadData()
    }

    func numberOfRowsInTableView(tableView: NSTableView) -> Int {
        return bufferBindings.count
    }

    @IBAction func bufferSelected(sender: NSPopUpButton) {
        let row = tableView.rowForView(sender)
        let binding = bufferBindings[row] as! BufferBinding
        let selectedItem = sender.selectedItem!

        guard let selectionObject = selectedItem.representedObject else {
            binding.buffer = nil
            return
        }

        binding.buffer = (selectionObject as! Buffer)
        modelObserver.modelDidChange()
    }

    func generateBufferPopUp(index: Int) -> (NSMenu, NSMenuItem?) {
        let currentBinding = bufferBindings[index] as! BufferBinding

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
    
    @IBAction func removeBuffer(sender: NSButton) {
        let row = tableView.rowForView(sender)
        let binding = bufferBindings[row] as! BufferBinding
        removeObserver.removeBufferBinding(self, binding: binding)
        managedObjectContext.deleteObject(binding)
        tableView.reloadData()
        modelObserver.modelDidChange()
    }

    func tableView(tableView: NSTableView, viewForTableColumn tableColumn: NSTableColumn?, row: Int) -> NSView? {
        switch tableColumn! {
        case numberTableColumn:
            let result = tableView.makeViewWithIdentifier("Number", owner: self) as! NSTableCellView
            let textField = result.textField!
            textField.integerValue = row
            return result
        case popUpTableColumn:
            let result = tableView.makeViewWithIdentifier("Pop Up", owner: self) as! NSTableCellView
            assert(result.subviews.count == 1)
            let popUp = result.subviews[0] as! NSPopUpButton
            let (menu, selectedItem) = generateBufferPopUp(row)
            popUp.menu = menu
            if let toSelect = selectedItem {
                popUp.selectItem(toSelect)
            } else {
                popUp.selectItemAtIndex(0)
            }
            return result
        case removeTableColumn:
            return tableView.makeViewWithIdentifier("Remove", owner: self) as! NSTableCellView
        default:
            fatalError()
        }
    }


}
