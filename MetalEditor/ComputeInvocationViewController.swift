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
    @IBOutlet var pipelineStateNameTextField: NSTextField!
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

    override func viewDidLoad() {
        bufferBindingsViewController = BufferBindingsViewController(nibName: "BufferBindingsView", bundle: nil, managedObjectContext: managedObjectContext, modelObserver: modelObserver, removeObserver: self, bufferBindings: computeInvocation.bufferBindings)
        addChildViewController(bufferBindingsViewController)
        tableViewPlaceholder.addSubview(bufferBindingsViewController.view)
        tableViewPlaceholder.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|[tableView]|", options: NSLayoutFormatOptions(), metrics: nil, views: ["tableView" : bufferBindingsViewController.view]))
        tableViewPlaceholder.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[tableView]|", options: NSLayoutFormatOptions(), metrics: nil, views: ["tableView" : bufferBindingsViewController.view]))

        if let state = computeInvocation.state {
            pipelineStateNameTextField.stringValue = state.functionName
        }

        threadgroupsPerGridXTextField.integerValue = computeInvocation.threadgroupsPerGrid.width.integerValue
        threadgroupsPerGridYTextField.integerValue = computeInvocation.threadgroupsPerGrid.height.integerValue
        threadgroupsPerGridZTextField.integerValue = computeInvocation.threadgroupsPerGrid.depth.integerValue
        threadsPerThreadgroupXTextField.integerValue = computeInvocation.threadsPerThreadgroup.width.integerValue
        threadsPerThreadgroupYTextField.integerValue = computeInvocation.threadsPerThreadgroup.height.integerValue
        threadsPerThreadgroupZTextField.integerValue = computeInvocation.threadsPerThreadgroup.depth.integerValue
    }

    func control(control: NSControl, isValidObject obj: AnyObject) -> Bool {
        return Int(obj as! String) != nil
    }

    @IBAction func setPipelineStateFunctionName(sender: NSTextField) {
        let newState = NSEntityDescription.insertNewObjectForEntityForName("ComputePipelineState", inManagedObjectContext: managedObjectContext) as! ComputePipelineState
        newState.functionName = sender.stringValue
        let oldState = computeInvocation.state
        computeInvocation.state = newState
        if let oldStateObject = oldState {
            managedObjectContext.deleteObject(oldStateObject)
        }
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
