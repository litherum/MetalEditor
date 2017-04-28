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

    init?(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?, managedObjectContext: NSManagedObjectContext, modelObserver: ModelObserver, removeObserver: PassRemoveObserver, pass: RenderPass) {
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
        detailsButton.isEnabled = renderPass.descriptor != nil
    }

    @IBAction func renderToTextureChecked(_ sender: NSButton) {
        if sender.state == NSOnState {
            let depthAttachment = NSEntityDescription.insertNewObject(forEntityName: "DepthAttachment", into: managedObjectContext) as! DepthAttachment
            depthAttachment.clearValue = 1.0
            depthAttachment.texture = nil
            depthAttachment.level = 0
            depthAttachment.slice = 0
            depthAttachment.depthPlane = 0
            depthAttachment.loadAction = NSNumber(value:  MTLLoadAction.dontCare.rawValue)
            depthAttachment.storeAction = NSNumber(value: MTLStoreAction.dontCare.rawValue)
            depthAttachment.resolveTexture = nil
            depthAttachment.resolveLevel = 0
            depthAttachment.resolveSlice = 0
            depthAttachment.resolveDepthPlane = 0

            let stencilAttachment = NSEntityDescription.insertNewObject(forEntityName: "StencilAttachment", into: managedObjectContext) as! StencilAttachment
            stencilAttachment.clearValue = 0
            stencilAttachment.texture = nil
            stencilAttachment.level = 0
            stencilAttachment.slice = 0
            stencilAttachment.depthPlane = 0
            stencilAttachment.loadAction = NSNumber(value: MTLLoadAction.dontCare.rawValue)
            stencilAttachment.storeAction = NSNumber(value: MTLStoreAction.dontCare.rawValue)
            stencilAttachment.resolveTexture = nil
            stencilAttachment.resolveLevel = 0
            stencilAttachment.resolveSlice = 0
            stencilAttachment.resolveDepthPlane = 0

            let renderPassDescriptor = NSEntityDescription.insertNewObject(forEntityName: "RenderPassDescriptor", into: managedObjectContext) as! RenderPassDescriptor
            renderPassDescriptor.depthAttachment = depthAttachment
            renderPassDescriptor.stencilAttachment = stencilAttachment
            renderPassDescriptor.visibilityResultBuffer = nil
            renderPassDescriptor.renderTargetArrayLength = 0

            renderPass.descriptor = renderPassDescriptor
        } else {
            let descriptor = renderPass.descriptor!
            renderPass.descriptor = nil
            for colorAttachment in descriptor.colorAttachments {
                descriptor.mutableOrderedSetValue(forKey: "colorAttachments").remove(colorAttachment)
                managedObjectContext.delete(colorAttachment as! ColorAttachment)
            }
            managedObjectContext.delete(descriptor.depthAttachment)
            managedObjectContext.delete(descriptor.stencilAttachment)
            managedObjectContext.delete(descriptor)
        }
        detailsButton.isEnabled = renderPass.descriptor != nil
        modelObserver.modelDidChange()
    }

    @IBAction func detailsPushed(_ sender: NSButton) {
        let viewController = RenderToTextureViewController(nibName: "RenderToTextureView", bundle: Bundle.main, managedObjectContext: managedObjectContext, modelObserver: modelObserver, dismissObserver: self, renderPassDescriptor: renderPass.descriptor!)!
        presentViewControllerAsSheet(viewController)
    }

    func addRenderInvocationView(_ invocation: RenderInvocation) {
        let subController = InvocationViewController(nibName: "Invocation", bundle: nil, managedObjectContext: managedObjectContext!, modelObserver: modelObserver, removeObserver: self, invocation: invocation)!
        addChildViewController(subController)
        stackView.addArrangedSubview(subController.view)
    }

    @IBAction func addInvocation(_ sender: NSButton) {
        let renderInvocation = NSEntityDescription.insertNewObject(forEntityName: "RenderInvocation", into: managedObjectContext) as! RenderInvocation
        renderInvocation.name = "New Render Invocation"
        renderInvocation.state = nil
        renderInvocation.primitive = NSNumber(value: MTLPrimitiveType.triangle.rawValue)
        renderInvocation.vertexStart = 0
        renderInvocation.vertexCount = 0
        renderInvocation.blendColorRed = 0
        renderInvocation.blendColorGreen = 0
        renderInvocation.blendColorBlue = 0
        renderInvocation.blendColorAlpha = 0
        renderInvocation.cullMode = NSNumber(value: MTLCullMode.none.rawValue)
        renderInvocation.depthBias = 0
        renderInvocation.depthSlopeScale = 0
        renderInvocation.depthClamp = 0
        renderInvocation.depthClipMode = NSNumber(value: MTLDepthClipMode.clip.rawValue)
        renderInvocation.depthStencilState = nil
        renderInvocation.frontFacingWinding = NSNumber(value: MTLWinding.clockwise.rawValue)
        renderInvocation.scissorRect = nil
        renderInvocation.stencilFrontReferenceValue = 0
        renderInvocation.stencilBackReferenceValue = 0
        renderInvocation.triangleFillMode = NSNumber(value: MTLTriangleFillMode.fill.rawValue)
        renderInvocation.viewport = nil
        renderInvocation.visibilityResultMode = NSNumber(value: MTLVisibilityResultMode.disabled.rawValue)
        renderInvocation.visibilityResultOffset = 0

        renderPass.mutableOrderedSetValue(forKey: "invocations").add(renderInvocation)
        addRenderInvocationView(renderInvocation)
        modelObserver.modelDidChange()
    }

    func removeInvocation(_ controller: InvocationViewController) {
        renderPass.mutableOrderedSetValue(forKey: "invocations").remove(controller.invocation)
        super.removeInvocation(controller, pass: renderPass)
    }

    func dismiss(_ controller: NSViewController) {
        dismissViewController(controller)
    }
}
