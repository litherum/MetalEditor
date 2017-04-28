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

    init?(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?, managedObjectContext: NSManagedObjectContext, modelObserver: ModelObserver, dismissObserver: DismissObserver, computeInvocation: ComputeInvocation) {
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
        bufferTableViewPlaceholder.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "|[tableView]|", options: NSLayoutFormatOptions(), metrics: nil, views: ["tableView" : bufferBindingsViewController.view]))
        bufferTableViewPlaceholder.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[tableView]|", options: NSLayoutFormatOptions(), metrics: nil, views: ["tableView" : bufferBindingsViewController.view]))

        textureBindingsViewController = TextureBindingsViewController(nibName: "BindingsView", bundle: nil, managedObjectContext: managedObjectContext, modelObserver: modelObserver, bindings: computeInvocation.textureBindings)
        addChildViewController(textureBindingsViewController)
        textureTableViewPlaceholder.addSubview(textureBindingsViewController.view)
        textureTableViewPlaceholder.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "|[tableView]|", options: NSLayoutFormatOptions(), metrics: nil, views: ["tableView" : textureBindingsViewController.view]))
        textureTableViewPlaceholder.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[tableView]|", options: NSLayoutFormatOptions(), metrics: nil, views: ["tableView" : textureBindingsViewController.view]))

        if let state = computeInvocation.state {
            pipelineStateNameTextField.stringValue = state.functionName
        }

        threadgroupsPerGridXTextField.integerValue = computeInvocation.threadgroupsPerGrid.width.intValue
        threadgroupsPerGridYTextField.integerValue = computeInvocation.threadgroupsPerGrid.height.intValue
        threadgroupsPerGridZTextField.integerValue = computeInvocation.threadgroupsPerGrid.depth.intValue
        threadsPerThreadgroupXTextField.integerValue = computeInvocation.threadsPerThreadgroup.width.intValue
        threadsPerThreadgroupYTextField.integerValue = computeInvocation.threadsPerThreadgroup.height.intValue
        threadsPerThreadgroupZTextField.integerValue = computeInvocation.threadsPerThreadgroup.depth.intValue
    }

    @IBAction func setPipelineStateFunctionName(_ sender: NSTextField) {
        let newState = NSEntityDescription.insertNewObject(forEntityName: "ComputePipelineState", into: managedObjectContext) as! ComputePipelineState
        newState.functionName = sender.stringValue
        let oldState = computeInvocation.state
        computeInvocation.state = newState
        if let oldStateObject = oldState {
            managedObjectContext.delete(oldStateObject)
        }
        modelObserver.modelDidChange()
    }

    @IBAction func setThreadgroupsPerGridX(_ sender: NSTextField) {
        computeInvocation.threadgroupsPerGrid.width = NSNumber(sender.integerValue)
        modelObserver.modelDidChange()
    }

    @IBAction func setThreadgroupsPerGridY(_ sender: NSTextField) {
        computeInvocation.threadgroupsPerGrid.height = NSNumber(sender.integerValue)
        modelObserver.modelDidChange()
    }

    @IBAction func setThreadgroupsPerGridZ(_ sender: NSTextField) {
        computeInvocation.threadgroupsPerGrid.depth = NSNumber(sender.integerValue)
        modelObserver.modelDidChange()
    }

    @IBAction func setThreadsPerThreadgroupX(_ sender: NSTextField) {
        computeInvocation.threadsPerThreadgroup.width = NSNumber(sender.integerValue)
        modelObserver.modelDidChange()
    }

    @IBAction func setThreadsPerThreadgroupY(_ sender: NSTextField) {
        computeInvocation.threadsPerThreadgroup.height = NSNumber(sender.integerValue)
        modelObserver.modelDidChange()
    }

    @IBAction func setThreadsPerThreadgroupZ(_ sender: NSTextField) {
        computeInvocation.threadsPerThreadgroup.depth = NSNumber(sender.integerValue)
        modelObserver.modelDidChange()
    }

    @IBAction func addRemoveBufferBinding(_ sender: NSSegmentedControl) {
        if sender.selectedSegment == 0 { // Add
            let bufferBinding = NSEntityDescription.insertNewObject(forEntityName: "BufferBinding", into: managedObjectContext) as! BufferBinding
            bufferBinding.buffer = nil
            computeInvocation.mutableOrderedSetValue(forKey: "bufferBindings").add(bufferBinding)
        } else { // Remove
            assert(sender.selectedSegment == 1)
            guard let row = bufferBindingsViewController.selectedRow() else {
                return
            }
            let binding = computeInvocation.bufferBindings[row] as! BufferBinding
            computeInvocation.mutableOrderedSetValue(forKey: "bufferBindings").remove(binding)
            managedObjectContext.delete(binding)
        }
        bufferBindingsViewController.reloadData()
        modelObserver.modelDidChange()
        sender.selectedSegment = -1
    }

    @IBAction func dismiss(_ sender: NSButton) {
        dismissObserver.dismiss(self)
    }
}
