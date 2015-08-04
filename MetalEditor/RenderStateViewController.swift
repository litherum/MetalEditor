//
//  RenderStateViewController.swift
//  MetalEditor
//
//  Created by Litherum on 8/3/15.
//  Copyright © 2015 Litherum. All rights reserved.
//

import Cocoa

class RenderStateViewController: NSViewController {
    var managedObjectContext: NSManagedObjectContext!
    weak var modelObserver: ModelObserver!
    var state: RenderPipelineState!
    @IBOutlet var nameTextField: NSTextField!
    @IBOutlet var vertexFunctionTextField: NSTextField!
    @IBOutlet var fragmentFunctionTextField: NSTextField!

    init?(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?, managedObjectContext: NSManagedObjectContext, modelObserver: ModelObserver, state: RenderPipelineState) {
        self.managedObjectContext = managedObjectContext
        self.modelObserver = modelObserver
        self.state = state
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        nameTextField.stringValue = state.name
        vertexFunctionTextField.stringValue = state.vertexFunction
        fragmentFunctionTextField.stringValue = state.fragmentFunction
    }
}
