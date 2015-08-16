//
//  InvocationViewController.swift
//  MetalEditor
//
//  Created by Litherum on 8/8/15.
//  Copyright © 2015 Litherum. All rights reserved.
//

import Cocoa

class InvocationViewController: NSViewController {
    var managedObjectContext: NSManagedObjectContext!
    weak var modelObserver: ModelObserver!
    weak var removeObserver: InvocationRemoveObserver!
    var invocation: Invocation!
    @IBOutlet var box: NSBox!
    @IBOutlet var nameTextField: NSTextField!

    init?(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?, managedObjectContext: NSManagedObjectContext, modelObserver: ModelObserver, removeObserver: InvocationRemoveObserver, invocation: Invocation) {
        self.managedObjectContext = managedObjectContext
        self.modelObserver = modelObserver
        self.removeObserver = removeObserver
        self.invocation = invocation
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        nameTextField.stringValue = invocation.name

        if let _ = invocation as? ComputeInvocation {
            box.fillColor = NSColor.redColor()
        } else {
            assert(invocation as? RenderInvocation != nil)
            box.fillColor = NSColor.blueColor()
        }
    }

    @IBAction func nameChanged(sender: NSTextField) {
        invocation.name = sender.stringValue
        modelObserver.modelDidChange()
    }

    @IBAction func removeInvocation(sender: NSButton) {
        removeObserver.removeInvocation(self)
    }

    @IBAction func showDetails(sender: NSButton) {
        if let renderInvocation = invocation as? RenderInvocation {
            let controller = RenderInvocationViewController(nibName: "RenderInvocationView", bundle: nil, managedObjectContext: managedObjectContext, modelObserver: modelObserver, renderInvocation: renderInvocation)!
            presentViewController(controller, asPopoverRelativeToRect: self.view.bounds, ofView: self.view, preferredEdge: .MaxX, behavior: .Transient)
        } else {
            let computeInvocation = invocation as! ComputeInvocation
            let controller = ComputeInvocationViewController(nibName: "ComputeInvocationView", bundle: nil, managedObjectContext: managedObjectContext, modelObserver: modelObserver, computeInvocation: computeInvocation)!
            presentViewController(controller, asPopoverRelativeToRect: self.view.bounds, ofView: self.view, preferredEdge: .MaxX, behavior: .Transient)
        }
    }
}
