//
//  InvocationsViewController.swift
//  MetalEditor
//
//  Created by Litherum on 8/8/15.
//  Copyright © 2015 Litherum. All rights reserved.
//

import Cocoa

protocol InvocationRemoveObserver: class {
    func removeInvocation(controller: InvocationViewController)
}

class InvocationsViewController: NSViewController {
    var managedObjectContext: NSManagedObjectContext!
    weak var modelObserver: ModelObserver!
    weak var removeObserver: PassRemoveObserver!
    @IBOutlet var stackView: NSStackView!

    func removeInvocation(controller: InvocationViewController, pass: Pass) {
        managedObjectContext.deleteObject(controller.invocation)

        for i in 0 ..< childViewControllers.count {
            if childViewControllers[i] == controller {
                removeChildViewControllerAtIndex(i)
                break
            }
        }
        controller.view.removeFromSuperview()

        if stackView.arrangedSubviews.count == 0 {
            removeObserver.removePass(self, pass: pass)
        } else {
            modelObserver.modelDidChange()
        }
    }
}
