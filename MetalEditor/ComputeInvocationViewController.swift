//
//  ComputeInvocationViewController.swift
//  MetalEditor
//
//  Created by Litherum on 8/9/15.
//  Copyright © 2015 Litherum. All rights reserved.
//

import Cocoa

class ComputeInvocationViewController: NSViewController, NSTableViewDelegate, NSTableViewDataSource {
    var managedObjectContext: NSManagedObjectContext!
    weak var modelObserver: ModelObserver!
    var computeInvocation: ComputeInvocation!
    @IBOutlet var tableView: NSTableView!
    @IBOutlet var numberTableColumn: NSTableColumn!
    @IBOutlet var popUpTableColumn: NSTableColumn!
    @IBOutlet var removeTableColumn: NSTableColumn!
    @IBOutlet var statePopUp: NSPopUpButton!
    @IBOutlet var threadgroupsPerGridXTextField: NSTextField!
    @IBOutlet var threadgroupsPerGridYTextField: NSTextField!
    @IBOutlet var threadgroupsPerGridZTextField: NSTextField!
    @IBOutlet var threadsPerThreadgroupXTextField: NSTextField!
    @IBOutlet var threadsPerThreadgroupYTextField: NSTextField!
    @IBOutlet var threadsPerThreadgroupZTextField: NSTextField!

    init?(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?, managedObjectContext: NSManagedObjectContext, modelObserver: ModelObserver, computeInvocation: ComputeInvocation) {
        self.managedObjectContext = managedObjectContext
        self.modelObserver = modelObserver
        self.computeInvocation = computeInvocation
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    func createStateMenu() -> (NSMenu, NSMenuItem?) {
        let fetchRequest = NSFetchRequest(entityName: "ComputePipelineState")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "id", ascending: true)]

        var selectedItem: NSMenuItem?
        do {
            let states = try managedObjectContext.executeFetchRequest(fetchRequest) as! [ComputePipelineState]
            let result = NSMenu()
            result.addItem(NSMenuItem(title: "None", action: nil, keyEquivalent: ""))
            for state in states {
                let item = NSMenuItem(title: state.name, action: nil, keyEquivalent: "")
                item.representedObject = state.id
                result.addItem(item)
                if let computeInvocationState = computeInvocation.state {
                    if computeInvocationState == state {
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
        let (menu, selectedItem) = createStateMenu()
        statePopUp.menu = menu
        if let toSelect = selectedItem {
            statePopUp.selectItem(toSelect)
        } else {
            statePopUp.selectItemAtIndex(0)
        }

        threadgroupsPerGridXTextField.integerValue = computeInvocation.threadgroupsPerGrid.width.integerValue
        threadgroupsPerGridYTextField.integerValue = computeInvocation.threadgroupsPerGrid.height.integerValue
        threadgroupsPerGridZTextField.integerValue = computeInvocation.threadgroupsPerGrid.depth.integerValue
        threadsPerThreadgroupXTextField.integerValue = computeInvocation.threadsPerThreadgroup.width.integerValue
        threadsPerThreadgroupYTextField.integerValue = computeInvocation.threadsPerThreadgroup.height.integerValue
        threadsPerThreadgroupZTextField.integerValue = computeInvocation.threadsPerThreadgroup.depth.integerValue
    }

    func control(control: NSControl, isValidObject obj: AnyObject) -> Bool {
        if let s = obj as? String {
            if Int(s) != nil {
                return true
            }
        }
        return false
    }
    
    func numberOfRowsInTableView(tableView: NSTableView) -> Int {
        return computeInvocation.bufferBindings.count
    }

    @IBAction func bufferSelected(sender: NSPopUpButton) {
        let row = tableView.rowForView(sender)
        guard row >= 0 else {
            fatalError()
        }
        guard let binding = computeInvocation.bufferBindings[row] as? BufferBinding else {
            fatalError()
        }

        guard let selectedItem = sender.selectedItem else {
            return
        }

        if selectedItem.representedObject == nil {
            binding.buffer = nil
            return
        }

        guard let selection = selectedItem.representedObject else {
            return
        }

        let fetchRequest = NSFetchRequest(entityName: "Buffer")
        fetchRequest.predicate = NSPredicate(format: "%K = %@", argumentArray: ["id", selection])
        
        do {
            let buffers = try managedObjectContext.executeFetchRequest(fetchRequest) as! [Buffer]
            assert(buffers.count == 1)
            binding.buffer = buffers[0]
            modelObserver.modelDidChange()
        } catch {
            fatalError()
        }
    }

    func generateBufferPopUp(index: Int) -> (NSMenu, NSMenuItem?) {
        guard let currentBinding = computeInvocation.bufferBindings[index] as? BufferBinding else {
            fatalError()
        }

        let fetchRequest = NSFetchRequest(entityName: "Buffer")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "id", ascending: true)]

        var selectedItem: NSMenuItem?
        do {
            let buffers = try managedObjectContext.executeFetchRequest(fetchRequest) as! [Buffer]
            let result = NSMenu()
            result.addItem(NSMenuItem(title: "None", action: nil, keyEquivalent: ""))
            for buffer in buffers {
                let item = NSMenuItem(title: buffer.name, action: nil, keyEquivalent: "")
                item.representedObject = buffer.id
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
        guard row >= 0 else {
            fatalError()
        }
        guard let binding = computeInvocation.bufferBindings[row] as? BufferBinding else {
            fatalError()
        }
        computeInvocation.mutableOrderedSetValueForKey("bufferBindings").removeObject(binding)
        managedObjectContext.deleteObject(binding)
        tableView.reloadData()
        modelObserver.modelDidChange()
    }

    func tableView(tableView: NSTableView, viewForTableColumn tableColumn: NSTableColumn?, row: Int) -> NSView? {
        guard let column = tableColumn else {
            return nil
        }
        switch column {
        case numberTableColumn:
            if let result = tableView.makeViewWithIdentifier("Number", owner: self) as? NSTableCellView {
                if let textField = result.textField {
                    textField.integerValue = row
                    return result
                }
            }
            fatalError()
        case popUpTableColumn:
            if let result = tableView.makeViewWithIdentifier("Pop Up", owner: self) as? NSTableCellView {
                assert(result.subviews.count == 1)
                guard let popUp = result.subviews[0] as? NSPopUpButton else {
                    fatalError()
                }
                let (menu, selectedItem) = generateBufferPopUp(row)
                popUp.menu = menu
                if let toSelect = selectedItem {
                    popUp.selectItem(toSelect)
                } else {
                    popUp.selectItemAtIndex(0)
                }
                return result
            }
            fatalError()
        case removeTableColumn:
            if let result = tableView.makeViewWithIdentifier("Remove", owner: self) as? NSTableCellView {
                return result
            }
            fatalError()
        default:
            fatalError()
        }
    }

    @IBAction func stateSelected(sender: NSPopUpButton) {
        guard let selectedItem = sender.selectedItem else {
            return
        }

        if selectedItem.representedObject == nil {
            computeInvocation.state = nil
            return
        }

        guard let selection = selectedItem.representedObject else {
            return
        }

        let fetchRequest = NSFetchRequest(entityName: "ComputePipelineState")
        fetchRequest.predicate = NSPredicate(format: "%K = %@", argumentArray: ["id", selection])
        
        do {
            let states = try managedObjectContext.executeFetchRequest(fetchRequest) as! [ComputePipelineState]
            assert(states.count == 1)
            computeInvocation.state = states[0]
        } catch {
            fatalError()
        }
    }

    @IBAction func setThreadgroupsPerGridX(sender: NSTextField) {
        computeInvocation.threadgroupsPerGrid.width = sender.integerValue
        modelObserver.modelDidChange()
    }

    @IBAction func setThreadgroupsPerGridY(sender: NSTextField) {
        computeInvocation.threadgroupsPerGrid.height = sender.integerValue
        modelObserver.modelDidChange()
    }

    @IBAction func setThreadgroupsPerGridZ(sender: NSTextField) {
        computeInvocation.threadgroupsPerGrid.depth = sender.integerValue
        modelObserver.modelDidChange()
    }

    @IBAction func setThreadsPerThreadgroupX(sender: NSTextField) {
        computeInvocation.threadsPerThreadgroup.width = sender.integerValue
        modelObserver.modelDidChange()
    }

    @IBAction func setThreadsPerThreadgroupY(sender: NSTextField) {
        computeInvocation.threadsPerThreadgroup.height = sender.integerValue
        modelObserver.modelDidChange()
    }

    @IBAction func setThreadsPerThreadgroupZ(sender: NSTextField) {
        computeInvocation.threadsPerThreadgroup.depth = sender.integerValue
        modelObserver.modelDidChange()
    }

    @IBAction func addBufferBinding(sender: NSButton) {
        let bufferBinding = NSEntityDescription.insertNewObjectForEntityForName("BufferBinding", inManagedObjectContext: managedObjectContext) as! BufferBinding
        bufferBinding.buffer = nil
        computeInvocation.mutableOrderedSetValueForKey("bufferBindings").addObject(bufferBinding)
        tableView.reloadData()
        modelObserver.modelDidChange()
    }
}
