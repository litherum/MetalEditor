//
//  ComputeInvocationsViewController.swift
//  MetalEditor
//
//  Created by Litherum on 8/30/15.
//  Copyright © 2015 Litherum. All rights reserved.
//

import Cocoa

class ComputeInvocationsViewController: InvocationsViewController, InvocationRemoveObserver {
    var computePass: ComputePass!

    init?(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?, managedObjectContext: NSManagedObjectContext, modelObserver: ModelObserver, removeObserver: PassRemoveObserver, pass: ComputePass) {
        self.computePass = pass
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        self.managedObjectContext = managedObjectContext
        self.modelObserver = modelObserver
        self.removeObserver = removeObserver
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    func addComputeInvocationView(_ invocation: ComputeInvocation) {
        let subController = InvocationViewController(nibName: "Invocation", bundle: nil, managedObjectContext: managedObjectContext!, modelObserver: modelObserver, removeObserver: self, invocation: invocation)!
        addChildViewController(subController)
        stackView.addArrangedSubview(subController.view)
    }

    @IBAction func addInvocation(_ sender: NSButton) {
        let threadgroupsPerGrid = NSEntityDescription.insertNewObject(forEntityName: "Size", into: managedObjectContext) as! Size
        threadgroupsPerGrid.width = 0
        threadgroupsPerGrid.height = 0
        threadgroupsPerGrid.depth = 0

        let threadsPerThreadgroup = NSEntityDescription.insertNewObject(forEntityName: "Size", into: managedObjectContext) as! Size
        threadsPerThreadgroup.width = 0
        threadsPerThreadgroup.height = 0
        threadsPerThreadgroup.depth = 0

        let computeInvocation = NSEntityDescription.insertNewObject(forEntityName: "ComputeInvocation", into: managedObjectContext) as! ComputeInvocation
        computeInvocation.name = "New Compute Invocation"
        computeInvocation.state = nil
        computeInvocation.threadgroupsPerGrid = threadgroupsPerGrid
        computeInvocation.threadsPerThreadgroup = threadsPerThreadgroup

        computePass.mutableOrderedSetValue(forKey: "invocations").add(computeInvocation)
        addComputeInvocationView(computeInvocation)
        modelObserver.modelDidChange()
    }

    func removeInvocation(_ controller: InvocationViewController) {
        computePass.mutableOrderedSetValue(forKey: "invocations").remove(controller.invocation)
        super.removeInvocation(controller, pass: computePass)
    }
}
