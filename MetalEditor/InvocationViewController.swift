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
    weak var removeObserver: RenderPipelineStateRemoveObserver!
    var invocation: NSManagedObject!
    @IBOutlet var box: NSBox!

    init?(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?, managedObjectContext: NSManagedObjectContext, modelObserver: ModelObserver, invocation: NSManagedObject) {
        self.managedObjectContext = managedObjectContext
        self.modelObserver = modelObserver
        self.invocation = invocation
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        if let _ = invocation as? ComputeInvocation {
            box.fillColor = NSColor.redColor()
        } else if let _ = invocation as? RenderInvocation {
            box.fillColor = NSColor.blueColor()
        } else {
            fatalError()
        }
    }
}
