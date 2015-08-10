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

class InvocationsViewController: NSViewController, InvocationRemoveObserver {
    var managedObjectContext: NSManagedObjectContext!
    weak var modelObserver: ModelObserver!
    weak var removeObserver: PassRemoveObserver!
    var pass: Pass!
    @IBOutlet var stackView: NSStackView!

    init?(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?, managedObjectContext: NSManagedObjectContext, modelObserver: ModelObserver, removeObserver: PassRemoveObserver, pass: Pass) {
        self.managedObjectContext = managedObjectContext
        self.modelObserver = modelObserver
        self.removeObserver = removeObserver
        self.pass = pass
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    func addRenderInvocationView(invocation: RenderInvocation) {
        guard let subController = InvocationViewController(nibName: "Invocation", bundle: nil, managedObjectContext: managedObjectContext!, modelObserver: modelObserver, removeObserver: self, invocation: invocation) else {
            fatalError()
        }
        addChildViewController(subController)
        stackView.addArrangedSubview(subController.view)
    }

    func addComputeInvocationView(invocation: ComputeInvocation) {
        guard let subController = InvocationViewController(nibName: "Invocation", bundle: nil, managedObjectContext: managedObjectContext!, modelObserver: modelObserver, removeObserver: self, invocation: invocation) else {
            fatalError()
        }
        addChildViewController(subController)
        stackView.addArrangedSubview(subController.view)
    }

    @IBAction func addInvocation(sender: NSButton) {
        if let renderPass = pass as? RenderPass {
            let renderInvocation = NSEntityDescription.insertNewObjectForEntityForName("RenderInvocation", inManagedObjectContext: managedObjectContext) as! RenderInvocation
            renderInvocation.name = "New Render Invocation"
            renderInvocation.state = nil
            renderInvocation.primitive = MTLPrimitiveType.Triangle.rawValue
            renderInvocation.vertexStart = 0
            renderInvocation.vertexCount = 0

            renderPass.mutableOrderedSetValueForKey("invocations").addObject(renderInvocation)
            addRenderInvocationView(renderInvocation)
            modelObserver.modelDidChange()
        } else if let computePass = pass as? ComputePass {
            let threadgroupsPerGrid = NSEntityDescription.insertNewObjectForEntityForName("Size", inManagedObjectContext: managedObjectContext) as! Size
            threadgroupsPerGrid.width = 0
            threadgroupsPerGrid.height = 0
            threadgroupsPerGrid.depth = 0

            let threadsPerThreadgroup = NSEntityDescription.insertNewObjectForEntityForName("Size", inManagedObjectContext: managedObjectContext) as! Size
            threadsPerThreadgroup.width = 0
            threadsPerThreadgroup.height = 0
            threadsPerThreadgroup.depth = 0

            let computeInvocation = NSEntityDescription.insertNewObjectForEntityForName("ComputeInvocation", inManagedObjectContext: managedObjectContext) as! ComputeInvocation
            computeInvocation.name = "New Compute Invocation"
            computeInvocation.state = nil
            computeInvocation.threadgroupsPerGrid = threadgroupsPerGrid
            computeInvocation.threadsPerThreadgroup = threadsPerThreadgroup

            computePass.mutableOrderedSetValueForKey("invocations").addObject(computeInvocation)
            addComputeInvocationView(computeInvocation)
            modelObserver.modelDidChange()
        } else {
            fatalError()
        }
    }

    func removeInvocation(controller: InvocationViewController) {
        if let renderPass = pass as? RenderPass {
            renderPass.mutableOrderedSetValueForKey("invocations").removeObject(controller.invocation)
        } else if let computePass = pass as? ComputePass {
            computePass.mutableOrderedSetValueForKey("invocations").removeObject(controller.invocation)
        } else {
            fatalError()
        }
        managedObjectContext.deleteObject(controller.invocation)

        for i in 0 ..< childViewControllers.count {
            if childViewControllers[i] == controller {
                removeChildViewControllerAtIndex(i)
                break
            }
        }
        controller.view.removeFromSuperview()

        if stackView.arrangedSubviews.count == 0 {
            removeObserver.removePass(self)
        } else {
            modelObserver.modelDidChange()
        }
    }
}
