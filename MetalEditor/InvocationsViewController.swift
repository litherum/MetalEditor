//
//  InvocationsViewController.swift
//  MetalEditor
//
//  Created by Litherum on 8/8/15.
//  Copyright © 2015 Litherum. All rights reserved.
//

import Cocoa

class InvocationsViewController: NSViewController {
    var managedObjectContext: NSManagedObjectContext!
    weak var modelObserver: ModelObserver!
    weak var removeObserver: RenderPipelineStateRemoveObserver!
    var pass: Pass!
    @IBOutlet var stackView: NSStackView!

    init?(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?, managedObjectContext: NSManagedObjectContext, modelObserver: ModelObserver, pass: Pass) {
        self.managedObjectContext = managedObjectContext
        self.modelObserver = modelObserver
        self.pass = pass
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    func addSubController(subController: InvocationViewController) {
        addChildViewController(subController)
        stackView.addArrangedSubview(subController.view)
    }
}
