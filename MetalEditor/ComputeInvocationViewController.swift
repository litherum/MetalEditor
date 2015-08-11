//
//  ComputeInvocationViewController.swift
//  MetalEditor
//
//  Created by Litherum on 8/9/15.
//  Copyright © 2015 Litherum. All rights reserved.
//

import Cocoa

class ComputeInvocationViewController: NSViewController, NSTextFieldDelegate, BufferBindingRemoveObserver {
    var managedObjectContext: NSManagedObjectContext!
    weak var modelObserver: ModelObserver!
    var computeInvocation: ComputeInvocation!
    var bufferBindingsViewController: BufferBindingsViewController!
    @IBOutlet var tableViewPlaceholder: NSView!
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

    func removeBufferBinding(controller: BufferBindingsViewController, binding: BufferBinding) {
        computeInvocation.mutableOrderedSetValueForKey("bufferBindings").removeObject(binding)
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
                item.representedObject = state
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
        bufferBindingsViewController = BufferBindingsViewController(nibName: "BufferBindingsView", bundle: nil, managedObjectContext: managedObjectContext, modelObserver: modelObserver, removeObserver: self, bufferBindings: computeInvocation.bufferBindings)
        addChildViewController(bufferBindingsViewController)
        tableViewPlaceholder.addSubview(bufferBindingsViewController.view)
        tableViewPlaceholder.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|[tableView]|", options: NSLayoutFormatOptions(), metrics: nil, views: ["tableView" : bufferBindingsViewController.view]))
        tableViewPlaceholder.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[tableView]|", options: NSLayoutFormatOptions(), metrics: nil, views: ["tableView" : bufferBindingsViewController.view]))

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

    @IBAction func stateSelected(sender: NSPopUpButton) {
        guard let selectedItem = sender.selectedItem else {
            return
        }

        guard let selectionObject = selectedItem.representedObject else {
            computeInvocation.state = nil
            return
        }

        guard let selection = selectionObject as? ComputePipelineState else {
            fatalError()
        }

        computeInvocation.state = selection
        modelObserver.modelDidChange()
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
        bufferBindingsViewController.reloadData()
        modelObserver.modelDidChange()
    }
}
