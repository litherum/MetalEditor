//
//  InvocationViewController.swift
//  MetalEditor
//
//  Created by Litherum on 8/8/15.
//  Copyright © 2015 Litherum. All rights reserved.
//

import Cocoa

protocol DismissObserver: class {
    func dismiss(_ controller: NSViewController)
}

class InvocationViewController: NSViewController, DismissObserver {
    var managedObjectContext: NSManagedObjectContext!
    weak var modelObserver: ModelObserver!
    weak var removeObserver: InvocationRemoveObserver!
    var invocation: Invocation!
    @IBOutlet var box: NSBox!
    @IBOutlet var nameTextField: NSTextField!

    init?(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?, managedObjectContext: NSManagedObjectContext, modelObserver: ModelObserver, removeObserver: InvocationRemoveObserver, invocation: Invocation) {
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
            box.fillColor = NSColor.red
        } else {
            assert(invocation as? RenderInvocation != nil)
            box.fillColor = NSColor.blue
        }
    }

    @IBAction func nameChanged(_ sender: NSTextField) {
        invocation.name = sender.stringValue
        modelObserver.modelDidChange()
    }

    @IBAction func removeInvocation(_ sender: NSButton) {
        removeObserver.removeInvocation(self)
    }

    @IBAction func showDetails(_ sender: NSButton) {
        if let renderInvocation = invocation as? RenderInvocation {
            let controller = RenderInvocationDetailsViewController(nibName: "RenderInvocationView", bundle: nil, managedObjectContext: managedObjectContext, modelObserver: modelObserver, dismissObserver: self, renderInvocation: renderInvocation)!
            presentViewControllerAsSheet(controller)
        } else {
            let computeInvocation = invocation as! ComputeInvocation
            let controller = ComputeInvocationDetailsViewController(nibName: "ComputeInvocationView", bundle: nil, managedObjectContext: managedObjectContext, modelObserver: modelObserver, dismissObserver: self, computeInvocation: computeInvocation)!
            presentViewControllerAsSheet(controller)
        }
    }

    func dismiss(_ controller: NSViewController) {
        dismissViewController(controller)
    }
}
