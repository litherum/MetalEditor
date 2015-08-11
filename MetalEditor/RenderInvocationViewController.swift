//
//  RenderInvocationViewController.swift
//  MetalEditor
//
//  Created by Litherum on 8/10/15.
//  Copyright © 2015 Litherum. All rights reserved.
//

import Cocoa

class RenderInvocationViewController: NSViewController, NSTextFieldDelegate, BufferBindingRemoveObserver {
    var managedObjectContext: NSManagedObjectContext!
    weak var modelObserver: ModelObserver!
    var renderInvocation: RenderInvocation!
    var vertexBufferBindingsViewController: BufferBindingsViewController!
    var fragmentBufferBindingsViewController: BufferBindingsViewController!
    @IBOutlet var vertexTableViewPlaceholder: NSView!
    @IBOutlet var fragmentTableViewPlaceholder: NSView!
    @IBOutlet var statePopUp: NSPopUpButton!
    @IBOutlet var primitivePopUp: NSPopUpButton!
    @IBOutlet var vertexStartTextField: NSTextField!
    @IBOutlet var vertexCountTextField: NSTextField!

    init?(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?, managedObjectContext: NSManagedObjectContext, modelObserver: ModelObserver, renderInvocation: RenderInvocation) {
        self.managedObjectContext = managedObjectContext
        self.modelObserver = modelObserver
        self.renderInvocation = renderInvocation
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    func removeBufferBinding(controller: BufferBindingsViewController, binding: BufferBinding) {
        if controller == vertexBufferBindingsViewController {
            renderInvocation.mutableOrderedSetValueForKey("vertexBufferBindings").removeObject(binding)
        } else if controller == fragmentBufferBindingsViewController {
            renderInvocation.mutableOrderedSetValueForKey("fragmentBufferBindings").removeObject(binding)
        } else {
            fatalError()
        }
    }

    func createStateMenu() -> (NSMenu, NSMenuItem?) {
        let fetchRequest = NSFetchRequest(entityName: "RenderPipelineState")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "id", ascending: true)]

        var selectedItem: NSMenuItem?
        do {
            let states = try managedObjectContext.executeFetchRequest(fetchRequest) as! [RenderPipelineState]
            let result = NSMenu()
            result.addItem(NSMenuItem(title: "None", action: nil, keyEquivalent: ""))
            for state in states {
                let item = NSMenuItem(title: state.name, action: nil, keyEquivalent: "")
                item.representedObject = state
                result.addItem(item)
                if let renderInvocationState = renderInvocation.state {
                    if renderInvocationState == state {
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
        vertexBufferBindingsViewController = BufferBindingsViewController(nibName: "BufferBindingsView", bundle: nil, managedObjectContext: managedObjectContext, modelObserver: modelObserver, removeObserver: self, bufferBindings: renderInvocation.vertexBufferBindings)
        addChildViewController(vertexBufferBindingsViewController)
        vertexTableViewPlaceholder.addSubview(vertexBufferBindingsViewController.view)
        vertexTableViewPlaceholder.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|[tableView]|", options: NSLayoutFormatOptions(), metrics: nil, views: ["tableView" : vertexBufferBindingsViewController.view]))
        vertexTableViewPlaceholder.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[tableView]|", options: NSLayoutFormatOptions(), metrics: nil, views: ["tableView" : vertexBufferBindingsViewController.view]))

        fragmentBufferBindingsViewController = BufferBindingsViewController(nibName: "BufferBindingsView", bundle: nil, managedObjectContext: managedObjectContext, modelObserver: modelObserver, removeObserver: self, bufferBindings: renderInvocation.fragmentBufferBindings)
        addChildViewController(fragmentBufferBindingsViewController)
        fragmentTableViewPlaceholder.addSubview(fragmentBufferBindingsViewController.view)
        fragmentTableViewPlaceholder.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|[tableView]|", options: NSLayoutFormatOptions(), metrics: nil, views: ["tableView" : fragmentBufferBindingsViewController.view]))
        fragmentTableViewPlaceholder.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[tableView]|", options: NSLayoutFormatOptions(), metrics: nil, views: ["tableView" : fragmentBufferBindingsViewController.view]))

        let (menu, selectedItem) = createStateMenu()
        statePopUp.menu = menu
        if let toSelect = selectedItem {
            statePopUp.selectItem(toSelect)
        } else {
            statePopUp.selectItemAtIndex(0)
        }

        guard renderInvocation.primitive.integerValue >= 0 && renderInvocation.primitive.integerValue <= 4 else {
            fatalError()
        }
        primitivePopUp.selectItemAtIndex(renderInvocation.primitive.integerValue)

        vertexStartTextField.integerValue = renderInvocation.vertexStart.integerValue
        vertexCountTextField.integerValue = renderInvocation.vertexCount.integerValue
    }

    func control(control: NSControl, isValidObject obj: AnyObject) -> Bool {
        if let s = obj as? String {
            if Int(s) != nil {
                return true
            }
        }
        return false
    }

    @IBAction func addVertexBufferBinding(sender: NSButton) {
        let bufferBinding = NSEntityDescription.insertNewObjectForEntityForName("BufferBinding", inManagedObjectContext: managedObjectContext) as! BufferBinding
        bufferBinding.buffer = nil
        renderInvocation.mutableOrderedSetValueForKey("vertexBufferBindings").addObject(bufferBinding)
        vertexBufferBindingsViewController.reloadData()
        modelObserver.modelDidChange()
    }

    @IBAction func addFragmentBufferBinding(sender: NSButton) {
        let bufferBinding = NSEntityDescription.insertNewObjectForEntityForName("BufferBinding", inManagedObjectContext: managedObjectContext) as! BufferBinding
        bufferBinding.buffer = nil
        renderInvocation.mutableOrderedSetValueForKey("fragmentBufferBindings").addObject(bufferBinding)
        fragmentBufferBindingsViewController.reloadData()
        modelObserver.modelDidChange()
    }

    @IBAction func stateSelected(sender: NSPopUpButton) {
        guard let selectedItem = sender.selectedItem else {
            return
        }

        guard let selectionObject = selectedItem.representedObject else {
            renderInvocation.state = nil
            return
        }

        guard let selection = selectionObject as? RenderPipelineState else {
            fatalError()
        }

        renderInvocation.state = selection
        modelObserver.modelDidChange()
    }

    @IBAction func primitiveSelected(sender: NSPopUpButton) {
        guard sender.indexOfSelectedItem >= 0 else {
            fatalError()
        }
        renderInvocation.primitive = sender.indexOfSelectedItem
        modelObserver.modelDidChange()
    }

    @IBAction func setVertexStart(sender: NSTextField) {
        renderInvocation.vertexStart = sender.integerValue
        modelObserver.modelDidChange()
    }

    @IBAction func setVertexCount(sender: NSTextField) {
        renderInvocation.vertexCount = sender.integerValue
        modelObserver.modelDidChange()
    }

}