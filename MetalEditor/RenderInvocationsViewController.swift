//
//  RenderInvocationsViewController.swift
//  MetalEditor
//
//  Created by Litherum on 8/30/15.
//  Copyright © 2015 Litherum. All rights reserved.
//

import Cocoa

class RenderInvocationsViewController: InvocationsViewController, InvocationRemoveObserver {
    var renderPass: RenderPass!
    @IBOutlet var renderToTextureButton: NSButton!

    init?(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?, managedObjectContext: NSManagedObjectContext, modelObserver: ModelObserver, removeObserver: PassRemoveObserver, pass: RenderPass) {
        self.renderPass = pass
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        self.managedObjectContext = managedObjectContext
        self.modelObserver = modelObserver
        self.removeObserver = removeObserver
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    @IBAction func renderToTextureChecked(sender: NSButton) {
    }

    @IBAction func detailsPushed(sender: NSButton) {
    }

    func addRenderInvocationView(invocation: RenderInvocation) {
        let subController = InvocationViewController(nibName: "Invocation", bundle: nil, managedObjectContext: managedObjectContext!, modelObserver: modelObserver, removeObserver: self, invocation: invocation)!
        addChildViewController(subController)
        stackView.addArrangedSubview(subController.view)
    }

    @IBAction func addInvocation(sender: NSButton) {
        let renderInvocation = NSEntityDescription.insertNewObjectForEntityForName("RenderInvocation", inManagedObjectContext: managedObjectContext) as! RenderInvocation
        renderInvocation.name = "New Render Invocation"
        renderInvocation.state = nil
        renderInvocation.primitive = MTLPrimitiveType.Triangle.rawValue
        renderInvocation.vertexStart = 0
        renderInvocation.vertexCount = 0
        renderInvocation.blendColorRed = 0
        renderInvocation.blendColorGreen = 0
        renderInvocation.blendColorBlue = 0
        renderInvocation.blendColorAlpha = 0
        renderInvocation.cullMode = MTLCullMode.None.rawValue
        renderInvocation.depthBias = 0
        renderInvocation.depthSlopeScale = 0
        renderInvocation.depthClamp = 0
        renderInvocation.depthClipMode = MTLDepthClipMode.Clip.rawValue
        renderInvocation.depthStencilState = nil
        renderInvocation.frontFacingWinding = MTLWinding.Clockwise.rawValue
        renderInvocation.scissorRect = nil
        renderInvocation.stencilFrontReferenceValue = 0
        renderInvocation.stencilBackReferenceValue = 0
        renderInvocation.triangleFillMode = MTLTriangleFillMode.Fill.rawValue
        renderInvocation.viewport = nil
        renderInvocation.visibilityResultMode = MTLVisibilityResultMode.Disabled.rawValue
        renderInvocation.visibilityResultOffset = 0

        renderPass.mutableOrderedSetValueForKey("invocations").addObject(renderInvocation)
        addRenderInvocationView(renderInvocation)
        modelObserver.modelDidChange()
    }

    func removeInvocation(controller: InvocationViewController) {
        renderPass.mutableOrderedSetValueForKey("invocations").removeObject(controller.invocation)
        super.removeInvocation(controller, pass: renderPass)
    }
}
