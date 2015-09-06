//
//  ColorAttachmentViewController.swift
//  MetalEditor
//
//  Created by Litherum on 9/6/15.
//  Copyright © 2015 Litherum. All rights reserved.
//

import Cocoa

protocol ColorAttachmentRemoveObserver: class {
    func remove(controller: ColorAttachmentViewController)
}

class ColorAttachmentViewController: NSViewController {
    var managedObjectContext: NSManagedObjectContext!
    weak var modelObserver: ModelObserver!
    var colorAttachment: ColorAttachment
    var renderPassAttachmentViewController: RenderPassAttachmentViewController!
    @IBOutlet var redTextField: NSTextField!
    @IBOutlet var greenTextField: NSTextField!
    @IBOutlet var blueTextField: NSTextField!
    @IBOutlet var alphaTextField: NSTextField!
    @IBOutlet var renderPassAttachmentPlaceholderView: NSView!

    init?(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?, managedObjectContext: NSManagedObjectContext, modelObserver: ModelObserver, colorAttachment: ColorAttachment) {
        self.managedObjectContext = managedObjectContext
        self.modelObserver = modelObserver
        self.colorAttachment = colorAttachment
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        redTextField.integerValue = colorAttachment.clearRed.integerValue
        greenTextField.integerValue = colorAttachment.clearGreen.integerValue
        blueTextField.integerValue = colorAttachment.clearBlue.integerValue
        alphaTextField.integerValue = colorAttachment.clearAlpha.integerValue

        renderPassAttachmentViewController = RenderPassAttachmentViewController(nibName: "RenderPassAttachmentView", bundle: nil, managedObjectContext: managedObjectContext, modelObserver: modelObserver, renderPassAttachment: colorAttachment)!
        renderPassAttachmentPlaceholderView.addSubview(renderPassAttachmentViewController.view)
        renderPassAttachmentPlaceholderView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|[controller]|", options: NSLayoutFormatOptions(), metrics: nil, views: ["controller" : renderPassAttachmentViewController.view]))
        renderPassAttachmentPlaceholderView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[controller]|", options: NSLayoutFormatOptions(), metrics: nil, views: ["controller" : renderPassAttachmentViewController.view]))
    }

    @IBAction func redTextFieldSet(sender: NSTextField) {
        colorAttachment.clearRed = sender.integerValue
        modelObserver.modelDidChange()
    }

    @IBAction func greenTextFieldSet(sender: NSTextField) {
        colorAttachment.clearGreen = sender.integerValue
        modelObserver.modelDidChange()
    }

    @IBAction func blueTextFieldSet(sender: NSTextField) {
        colorAttachment.clearBlue = sender.integerValue
        modelObserver.modelDidChange()
    }

    @IBAction func alphaTextFieldSet(sender: NSTextField) {
        colorAttachment.clearAlpha = sender.integerValue
        modelObserver.modelDidChange()
    }

    @IBAction func remove(sender: NSButton) {
    }
}
