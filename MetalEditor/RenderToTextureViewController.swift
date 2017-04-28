//
//  RenderToTextureViewController.swift
//  MetalEditor
//
//  Created by Litherum on 8/30/15.
//  Copyright © 2015 Litherum. All rights reserved.
//

import Cocoa

extension NSNumber {
//    convenience init( _ value : UInt) {
//        self.init(value: value)
//    }

    convenience init( _ value : Int) {
        self.init(value: value)
    }

}

class RenderToTextureViewController: NSViewController, ColorAttachmentRemoveObserver {
    var managedObjectContext: NSManagedObjectContext!
    weak var modelObserver: ModelObserver!
    weak var dismissObserver: DismissObserver!
    var renderPassDescriptor: RenderPassDescriptor
    var depthViewController: RenderPassAttachmentViewController!
    var stencilViewController: RenderPassAttachmentViewController!
    @IBOutlet var stackView: NSStackView!
    @IBOutlet var clearDepthTextField: NSTextField!
    @IBOutlet var clearStencilTextField: NSTextField!
    @IBOutlet var depthAttachmentPlaceholder: NSView!
    @IBOutlet var stencilAttachmentPlaceholder: NSView!

    init?(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle, managedObjectContext: NSManagedObjectContext, modelObserver: ModelObserver, dismissObserver: DismissObserver, renderPassDescriptor: RenderPassDescriptor) {
        self.managedObjectContext = managedObjectContext
        self.modelObserver = modelObserver
        self.dismissObserver = dismissObserver
        self.renderPassDescriptor = renderPassDescriptor
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        for colorAttachment in renderPassDescriptor.colorAttachments {
            addColorAttachmentView(colorAttachment as! ColorAttachment)
        }

        depthViewController = RenderPassAttachmentViewController(nibName: "RenderPassAttachmentView", bundle: nil, managedObjectContext: managedObjectContext, modelObserver: modelObserver, renderPassAttachment: renderPassDescriptor.depthAttachment)!
        depthAttachmentPlaceholder.addSubview(depthViewController.view)
        depthAttachmentPlaceholder.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "|[controller]|", options: NSLayoutFormatOptions(), metrics: nil, views: ["controller" : depthViewController.view]))
        depthAttachmentPlaceholder.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[controller]|", options: NSLayoutFormatOptions(), metrics: nil, views: ["controller" : depthViewController.view]))

        stencilViewController = RenderPassAttachmentViewController(nibName: "RenderPassAttachmentView", bundle: nil, managedObjectContext: managedObjectContext, modelObserver: modelObserver, renderPassAttachment: renderPassDescriptor.stencilAttachment)!
        stencilAttachmentPlaceholder.addSubview(stencilViewController.view)
        stencilAttachmentPlaceholder.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "|[controller]|", options: NSLayoutFormatOptions(), metrics: nil, views: ["controller" : stencilViewController.view]))
        stencilAttachmentPlaceholder.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[controller]|", options: NSLayoutFormatOptions(), metrics: nil, views: ["controller" : stencilViewController.view]))
    }

    func addColorAttachmentView(_ colorAttachment: ColorAttachment) {
        let colorAttachmentController = ColorAttachmentViewController(nibName: "ColorAttachmentView", bundle: nil, managedObjectContext: managedObjectContext, modelObserver: modelObserver, removeObserver: self, colorAttachment: colorAttachment)!
        addChildViewController(colorAttachmentController)
        stackView.addArrangedSubview(colorAttachmentController.view)
        stackView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "|[controller]|", options: NSLayoutFormatOptions(), metrics: nil, views: ["controller" : colorAttachmentController.view]))
    }

    @IBAction func addColorAttachment(sender: NSButton) {
        let colorAttachment = NSEntityDescription.insertNewObject(forEntityName: "ColorAttachment", into: managedObjectContext) as! ColorAttachment
        colorAttachment.clearRed = 0.0
        colorAttachment.clearGreen = 0.0
        colorAttachment.clearBlue = 0.0
        colorAttachment.clearAlpha = 0.0
        colorAttachment.texture = nil
        colorAttachment.level = 0
        colorAttachment.slice = 0
        colorAttachment.depthPlane = 0
        colorAttachment.loadAction = NSNumber(value: MTLLoadAction.dontCare.rawValue)
        colorAttachment.storeAction =  NSNumber(value: MTLStoreAction.dontCare.rawValue)
        colorAttachment.resolveTexture = nil
        colorAttachment.resolveLevel = 0
        colorAttachment.resolveSlice = 0
        colorAttachment.resolveDepthPlane = 0
//        renderPassDescriptor.mutableOrderedSetValue(for: "colorAttachments").add(colorAttachment)
        fatalError()
        addColorAttachmentView(colorAttachment)
    }

    @IBAction func setClearDepth(sender: NSTextField) {
        
        renderPassDescriptor.depthAttachment.clearValue = NSNumber(value: sender.doubleValue)
        modelObserver.modelDidChange()
    }

    @IBAction func setClearStencil(sender: NSTextField) {
        renderPassDescriptor.stencilAttachment.clearValue =  NSNumber(value: sender.integerValue)
        modelObserver.modelDidChange()
    }

    func remove(_ controller: ColorAttachmentViewController) {
        for i in 0 ..< childViewControllers.count {
            if childViewControllers[i] == controller {
                removeChildViewController(at: i)
                break
            }
        }
        controller.view.removeFromSuperview()
        managedObjectContext.delete(controller.colorAttachment)

        modelObserver.modelDidChange()
    }

    @IBAction func dismiss(sender: NSButton) {
        dismissObserver.dismiss(self)
    }
}
