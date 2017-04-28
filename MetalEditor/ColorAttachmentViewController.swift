//
//  ColorAttachmentViewController.swift
//  MetalEditor
//
//  Created by Litherum on 9/6/15.
//  Copyright © 2015 Litherum. All rights reserved.
//

import Cocoa

protocol ColorAttachmentRemoveObserver: class {
    func remove(_ controller: ColorAttachmentViewController)
}

class ColorAttachmentViewController: NSViewController {
    var managedObjectContext: NSManagedObjectContext!
    weak var modelObserver: ModelObserver!
    weak var removeObserver: ColorAttachmentRemoveObserver!
    var colorAttachment: ColorAttachment
    var renderPassAttachmentViewController: RenderPassAttachmentViewController!
    @IBOutlet var redTextField: NSTextField!
    @IBOutlet var greenTextField: NSTextField!
    @IBOutlet var blueTextField: NSTextField!
    @IBOutlet var alphaTextField: NSTextField!
    @IBOutlet var renderPassAttachmentPlaceholderView: NSView!

    init?(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?, managedObjectContext: NSManagedObjectContext, modelObserver: ModelObserver, removeObserver: ColorAttachmentRemoveObserver, colorAttachment: ColorAttachment) {
        self.managedObjectContext = managedObjectContext
        self.modelObserver = modelObserver
        self.removeObserver = removeObserver
        self.colorAttachment = colorAttachment
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        redTextField.integerValue = colorAttachment.clearRed.intValue
        greenTextField.integerValue = colorAttachment.clearGreen.intValue
        blueTextField.integerValue = colorAttachment.clearBlue.intValue
        alphaTextField.integerValue = colorAttachment.clearAlpha.intValue

        renderPassAttachmentViewController = RenderPassAttachmentViewController(nibName: "RenderPassAttachmentView", bundle: nil, managedObjectContext: managedObjectContext, modelObserver: modelObserver, renderPassAttachment: colorAttachment)!
        renderPassAttachmentPlaceholderView.addSubview(renderPassAttachmentViewController.view)
        renderPassAttachmentPlaceholderView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "|[controller]|", options: NSLayoutFormatOptions(), metrics: nil, views: ["controller" : renderPassAttachmentViewController.view]))
        renderPassAttachmentPlaceholderView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[controller]|", options: NSLayoutFormatOptions(), metrics: nil, views: ["controller" : renderPassAttachmentViewController.view]))
    }

    @IBAction func redTextFieldSet(_ sender: NSTextField) {
        colorAttachment.clearRed = NSNumber(sender.integerValue)
        modelObserver.modelDidChange()
    }

    @IBAction func greenTextFieldSet(_ sender: NSTextField) {
        colorAttachment.clearGreen = NSNumber(sender.integerValue)
        modelObserver.modelDidChange()
    }

    @IBAction func blueTextFieldSet(_ sender: NSTextField) {
        colorAttachment.clearBlue = NSNumber(sender.integerValue)
        modelObserver.modelDidChange()
    }

    @IBAction func alphaTextFieldSet(_ sender: NSTextField) {
        colorAttachment.clearAlpha = NSNumber(sender.integerValue)
        modelObserver.modelDidChange()
    }

    @IBAction func remove(_ sender: NSButton) {
        removeObserver.remove(self)
    }
}
