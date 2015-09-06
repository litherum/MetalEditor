//
//  RenderInvocationsViewController.swift
//  MetalEditor
//
//  Created by Litherum on 8/30/15.
//  Copyright © 2015 Litherum. All rights reserved.
//

import Cocoa

class RenderInvocationsViewController: InvocationsViewController, InvocationRemoveObserver, DismissObserver {
    var renderPass: RenderPass!
    @IBOutlet var renderToTextureCheckbox: NSButton!
    @IBOutlet var detailsButton: NSButton!

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

    override func viewDidLoad() {
        super.viewDidLoad()

        renderToTextureCheckbox.state = renderPass.descriptor != nil ? NSOnState : NSOffState
        detailsButton.enabled = renderPass.descriptor != nil
    }

    @IBAction func renderToTextureChecked(sender: NSButton) {
        if sender.state == NSOnState {
            let depthAttachment = NSEntityDescription.insertNewObjectForEntityForName("DepthAttachment", inManagedObjectContext: managedObjectContext) as! DepthAttachment
            depthAttachment.clearValue = 1.0
            depthAttachment.texture = nil
            depthAttachment.level = 0
            depthAttachment.slice = 0
            depthAttachment.depthPlane = 0
            depthAttachment.loadAction = MTLLoadAction.DontCare.rawValue
            depthAttachment.storeAction = MTLStoreAction.DontCare.rawValue
            depthAttachment.resolveTexture = nil
            depthAttachment.resolveLevel = 0
            depthAttachment.resolveSlice = 0
            depthAttachment.resolveDepthPlane = 0

            let stencilAttachment = NSEntityDescription.insertNewObjectForEntityForName("StencilAttachment", inManagedObjectContext: managedObjectContext) as! StencilAttachment
            stencilAttachment.clearValue = 0
            stencilAttachment.texture = nil
            stencilAttachment.level = 0
            stencilAttachment.slice = 0
            stencilAttachment.depthPlane = 0
            stencilAttachment.loadAction = MTLLoadAction.DontCare.rawValue
            stencilAttachment.storeAction = MTLStoreAction.DontCare.rawValue
            stencilAttachment.resolveTexture = nil
            stencilAttachment.resolveLevel = 0
            stencilAttachment.resolveSlice = 0
            stencilAttachment.resolveDepthPlane = 0

            let renderPassDescriptor = NSEntityDescription.insertNewObjectForEntityForName("RenderPassDescriptor", inManagedObjectContext: managedObjectContext) as! RenderPassDescriptor
            renderPassDescriptor.depthAttachment = depthAttachment
            renderPassDescriptor.stencilAttachment = stencilAttachment
            renderPassDescriptor.visibilityResultBuffer = nil
            renderPassDescriptor.renderTargetArrayLength = 0

            renderPass.descriptor = renderPassDescriptor
        } else {
            let descriptor = renderPass.descriptor!
            renderPass.descriptor = nil
            for colorAttachment in descriptor.colorAttachments {
                descriptor.mutableOrderedSetValueForKey("colorAttachments").removeObject(colorAttachment)
                managedObjectContext.deleteObject(colorAttachment as! ColorAttachment)
            }
            managedObjectContext.deleteObject(descriptor.depthAttachment)
            managedObjectContext.deleteObject(descriptor.stencilAttachment)
            managedObjectContext.deleteObject(descriptor)
        }
        detailsButton.enabled = renderPass.descriptor != nil
        modelObserver.modelDidChange()
    }

    @IBAction func detailsPushed(sender: NSButton) {
        let viewController = RenderToTextureViewController(nibName: "RenderToTextureView", bundle: nil, managedObjectContext: managedObjectContext, modelObserver: modelObserver, dismissObserver: self, renderPassDescriptor: renderPass.descriptor!)!
        presentViewControllerAsSheet(viewController)
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

    func dismiss(controller: NSViewController) {
        dismissViewController(controller)
    }
}
