//
//  ComputeInvocationDetailsViewController.swift
//  MetalEditor
//
//  Created by Litherum on 8/9/15.
//  Copyright © 2015 Litherum. All rights reserved.
//

import Cocoa

class ComputeInvocationDetailsViewController: NSViewController {
    var managedObjectContext: NSManagedObjectContext!
    weak var modelObserver: ModelObserver!
    weak var dismissObserver: DismissObserver!
    var computeInvocation: ComputeInvocation!
    var bufferBindingsViewController: BufferBindingsViewController!
    var textureBindingsViewController: TextureBindingsViewController!
    @IBOutlet var bufferTableViewPlaceholder: NSView!
    @IBOutlet var textureTableViewPlaceholder: NSView!
    @IBOutlet var pipelineStateNameTextField: NSTextField!
    @IBOutlet var threadgroupsPerGridXTextField: NSTextField!
    @IBOutlet var threadgroupsPerGridYTextField: NSTextField!
    @IBOutlet var threadgroupsPerGridZTextField: NSTextField!
    @IBOutlet var threadsPerThreadgroupXTextField: NSTextField!
    @IBOutlet var threadsPerThreadgroupYTextField: NSTextField!
    @IBOutlet var threadsPerThreadgroupZTextField: NSTextField!

    init?(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?, managedObjectContext: NSManagedObjectContext, modelObserver: ModelObserver, dismissObserver: DismissObserver, computeInvocation: ComputeInvocation) {
        self.managedObjectContext = managedObjectContext
        self.modelObserver = modelObserver
        self.dismissObserver = dismissObserver
        self.computeInvocation = computeInvocation
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    override func viewDidLoad() {
        bufferBindingsViewController = BufferBindingsViewController(nibName: "BindingsView", bundle: nil, managedObjectContext: managedObjectContext, modelObserver: modelObserver, bindings: computeInvocation.bufferBindings)
        addChildViewController(bufferBindingsViewController)
        bufferTableViewPlaceholder.addSubview(bufferBindingsViewController.view)
        bufferTableViewPlaceholder.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|[tableView]|", options: NSLayoutFormatOptions(), metrics: nil, views: ["tableView" : bufferBindingsViewController.view]))
        bufferTableViewPlaceholder.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[tableView]|", options: NSLayoutFormatOptions(), metrics: nil, views: ["tableView" : bufferBindingsViewController.view]))

        textureBindingsViewController = TextureBindingsViewController(nibName: "BindingsView", bundle: nil, managedObjectContext: managedObjectContext, modelObserver: modelObserver, bindings: computeInvocation.textureBindings)
        addChildViewController(textureBindingsViewController)
        textureTableViewPlaceholder.addSubview(textureBindingsViewController.view)
        textureTableViewPlaceholder.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|[tableView]|", options: NSLayoutFormatOptions(), metrics: nil, views: ["tableView" : textureBindingsViewController.view]))
        textureTableViewPlaceholder.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[tableView]|", options: NSLayoutFormatOptions(), metrics: nil, views: ["tableView" : textureBindingsViewController.view]))

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

    @IBAction func addRemoveBufferBinding(sender: NSSegmentedControl) {
        if sender.selectedSegment == 0 { // Add
            let bufferBinding = NSEntityDescription.insertNewObjectForEntityForName("BufferBinding", inManagedObjectContext: managedObjectContext) as! BufferBinding
            bufferBinding.buffer = nil
            computeInvocation.mutableOrderedSetValueForKey("bufferBindings").addObject(bufferBinding)
        } else { // Remove
            assert(sender.selectedSegment == 1)
            guard let row = bufferBindingsViewController.selectedRow() else {
                return
            }
            let binding = computeInvocation.bufferBindings[row] as! BufferBinding
            computeInvocation.mutableOrderedSetValueForKey("bufferBindings").removeObject(binding)
            managedObjectContext.deleteObject(binding)
        }
        bufferBindingsViewController.reloadData()
        modelObserver.modelDidChange()
        sender.selectedSegment = -1
    }

    @IBAction func dismiss(sender: NSButton) {
        dismissObserver.dismiss(self)
    }
}
