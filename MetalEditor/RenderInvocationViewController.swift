//
//  RenderInvocationViewController.swift
//  MetalEditor
//
//  Created by Litherum on 8/10/15.
//  Copyright © 2015 Litherum. All rights reserved.
//

import Cocoa

class RenderInvocationViewController: NSViewController, NSTextFieldDelegate {
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
        vertexBufferBindingsViewController = BufferBindingsViewController(nibName: "BufferBindingsView", bundle: nil, managedObjectContext: managedObjectContext, modelObserver: modelObserver, bufferBindings: renderInvocation.vertexBufferBindings)
        addChildViewController(vertexBufferBindingsViewController)
        vertexTableViewPlaceholder.addSubview(vertexBufferBindingsViewController.view)
        vertexTableViewPlaceholder.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|[tableView]|", options: NSLayoutFormatOptions(), metrics: nil, views: ["tableView" : vertexBufferBindingsViewController.view]))
        vertexTableViewPlaceholder.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[tableView]|", options: NSLayoutFormatOptions(), metrics: nil, views: ["tableView" : vertexBufferBindingsViewController.view]))

        fragmentBufferBindingsViewController = BufferBindingsViewController(nibName: "BufferBindingsView", bundle: nil, managedObjectContext: managedObjectContext, modelObserver: modelObserver, bufferBindings: renderInvocation.fragmentBufferBindings)
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

        assert(renderInvocation.primitive.integerValue >= 0 && renderInvocation.primitive.integerValue <= 4)
        primitivePopUp.selectItemAtIndex(renderInvocation.primitive.integerValue)

        vertexStartTextField.integerValue = renderInvocation.vertexStart.integerValue
        vertexCountTextField.integerValue = renderInvocation.vertexCount.integerValue
    }

    func control(control: NSControl, isValidObject obj: AnyObject) -> Bool {
        return Int(obj as! String) != nil
    }

    @IBAction func addRemoveVertexBufferBinding(sender: NSSegmentedControl) {
        if sender.selectedSegment == 0 { // Add
            let bufferBinding = NSEntityDescription.insertNewObjectForEntityForName("BufferBinding", inManagedObjectContext: managedObjectContext) as! BufferBinding
            bufferBinding.buffer = nil
            renderInvocation.mutableOrderedSetValueForKey("vertexBufferBindings").addObject(bufferBinding)
        } else { // Remove
            assert(sender.selectedSegment == 1)
            guard let row = vertexBufferBindingsViewController.selectedRow() else {
                return
            }
            let binding = renderInvocation.vertexBufferBindings[row] as! BufferBinding
            renderInvocation.mutableOrderedSetValueForKey("vertexBufferBindings").removeObject(binding)
            managedObjectContext.deleteObject(binding)
        }
        vertexBufferBindingsViewController.reloadData()
        modelObserver.modelDidChange()
        sender.selectedSegment = -1
    }

    @IBAction func addRemoveFragmentBufferBinding(sender: NSSegmentedControl) {
        if sender.selectedSegment == 0 { // Add
            let bufferBinding = NSEntityDescription.insertNewObjectForEntityForName("BufferBinding", inManagedObjectContext: managedObjectContext) as! BufferBinding
            bufferBinding.buffer = nil
            renderInvocation.mutableOrderedSetValueForKey("fragmentBufferBindings").addObject(bufferBinding)
        } else { // Remove
            assert(sender.selectedSegment == 1)
            guard let row = fragmentBufferBindingsViewController.selectedRow() else {
                return
            }
            let binding = renderInvocation.fragmentBufferBindings[row] as! BufferBinding
            renderInvocation.mutableOrderedSetValueForKey("fragmentBufferBindings").removeObject(binding)
            managedObjectContext.deleteObject(binding)
        }
        fragmentBufferBindingsViewController.reloadData()
        modelObserver.modelDidChange()
        sender.selectedSegment = -1
    }

    @IBAction func stateSelected(sender: NSPopUpButton) {
        let selectedItem = sender.selectedItem!

        guard let selectionObject = selectedItem.representedObject else {
            renderInvocation.state = nil
            return
        }

        renderInvocation.state = (selectionObject as! RenderPipelineState)
        modelObserver.modelDidChange()
    }

    @IBAction func primitiveSelected(sender: NSPopUpButton) {
        assert(sender.indexOfSelectedItem >= 0)
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