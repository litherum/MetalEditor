//
//  ColorAttachmentsTableDelegate.swift
//  MetalEditor
//
//  Created by Litherum on 8/8/15.
//  Copyright © 2015 Litherum. All rights reserved.
//

import Cocoa

class ColorAttachmentsTableDelegate: NSObject, NSTableViewDelegate, NSTableViewDataSource {
    var managedObjectContext: NSManagedObjectContext!
    weak var modelObserver: ModelObserver!
    var state: RenderPipelineState!
    @IBOutlet var tableView: NSTableView!
    @IBOutlet var pixelFormatColumn: NSTableColumn!
    @IBOutlet var blendingColumn: NSTableColumn!
    @IBOutlet var rgbaColumn: NSTableColumn!
    @IBOutlet var rgbBlendOpColumn: NSTableColumn!
    @IBOutlet var alphaBlendOpColumn: NSTableColumn!
    @IBOutlet var sourceRGBFactorColumn: NSTableColumn!
    @IBOutlet var sourceAlphaFactorColumn: NSTableColumn!
    @IBOutlet var destinationRGBFactorColumn: NSTableColumn!
    @IBOutlet var destinationAlphaFactorColumn: NSTableColumn!

    @IBAction func addColorAttachment(sender: NSButton) {
        let attachmentCount = numberOfColorAttachments()
        let attachment = NSEntityDescription.insertNewObjectForEntityForName("RenderPipelineColorAttachment", inManagedObjectContext: managedObjectContext) as! RenderPipelineColorAttachment
        attachment.pixelFormat = nil
        attachment.writeAlpha = true
        attachment.writeRed = true
        attachment.writeGreen = true
        attachment.writeBlue = true
        attachment.blendingEnabled = true
        attachment.alphaBlendOperation = MTLBlendOperation.Add.rawValue
        attachment.rgbBlendOperation = MTLBlendOperation.Add.rawValue
        attachment.destinationAlphaBlendFactor = MTLBlendFactor.Zero.rawValue
        attachment.destinationRGBBlendFactor = MTLBlendFactor.Zero.rawValue
        attachment.sourceAlphaBlendFactor = MTLBlendFactor.One.rawValue
        attachment.sourceRGBBlendFactor = MTLBlendFactor.One.rawValue
        attachment.id = attachmentCount
        state.mutableOrderedSetValueForKey("colorAttachments").addObject(attachment)
        tableView.reloadData()
        modelObserver.modelDidChange()
    }

    @IBAction func removeSelectedColorAttachment(sender: NSButton) {
        guard tableView.selectedRow >= 0 else {
            return
        }
        managedObjectContext.deleteObject(state.colorAttachments[tableView.selectedRow] as! NSManagedObject)
        tableView.reloadData()
        modelObserver.modelDidChange()
    }

    func numberOfColorAttachments() -> Int {
        return state.colorAttachments.count
    }

    func numberOfRowsInTableView(tableView: NSTableView) -> Int {
        return numberOfColorAttachments()
    }

    func tableView(tableView: NSTableView, viewForTableColumn tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let column = tableColumn!
        let colorAttachment = state.colorAttachments[row] as! RenderPipelineColorAttachment
        switch column {
        case pixelFormatColumn:
            let result = tableView.makeViewWithIdentifier("PixelFormatPopUp", owner: self) as! NSTableCellView
            assert(result.subviews.count == 1)
            let popUp = result.subviews[0] as! NSPopUpButton
            popUp.menu = pixelFormatMenu(true)
            if let attachmentPixelFormat = colorAttachment.pixelFormat {
                let pixelFormat = MTLPixelFormat(rawValue: attachmentPixelFormat.unsignedLongValue)!
                popUp.selectItemAtIndex(pixelFormatToIndex(pixelFormat) + 1)
            } else {
                popUp.selectItemAtIndex(0)
            }
            return result
        case blendingColumn:
            let result = tableView.makeViewWithIdentifier("BlendingEnabled", owner: self) as! NSTableCellView
            assert(result.subviews.count == 1)
            let popUp = result.subviews[0] as! NSButton
            popUp.state = colorAttachment.blendingEnabled.boolValue ? NSOnState : NSOffState
            return result
        case rgbaColumn:
            let result = tableView.makeViewWithIdentifier("RGBA", owner: self) as! NSTableCellView
            assert(result.subviews.count == 4)
            let red = result.subviews[0] as! NSButton
            let green = result.subviews[1] as! NSButton
            let blue = result.subviews[2] as! NSButton
            let alpha = result.subviews[3] as! NSButton
            red.state = colorAttachment.writeRed.boolValue ? NSOnState : NSOffState
            green.state = colorAttachment.writeGreen.boolValue ? NSOnState : NSOffState
            blue.state = colorAttachment.writeBlue.boolValue ? NSOnState : NSOffState
            alpha.state = colorAttachment.writeAlpha.boolValue ? NSOnState : NSOffState
            return result
        case rgbBlendOpColumn:
            let result = tableView.makeViewWithIdentifier("RGB Blend Op", owner: self) as! NSTableCellView
            assert(result.subviews.count == 1)
            let popUp = result.subviews[0] as! NSPopUpButton
            popUp.selectItemAtIndex(colorAttachment.rgbBlendOperation.integerValue)
            return result
        case alphaBlendOpColumn:
            let result = tableView.makeViewWithIdentifier("Alpha Blend Op", owner: self) as! NSTableCellView
            assert(result.subviews.count == 1)
            let popUp = result.subviews[0] as! NSPopUpButton
            popUp.selectItemAtIndex(colorAttachment.alphaBlendOperation.integerValue)
            return result
        case sourceRGBFactorColumn:
            let result = tableView.makeViewWithIdentifier("Source RGB Factor", owner: self) as! NSTableCellView
            assert(result.subviews.count == 1)
            let popUp = result.subviews[0] as! NSPopUpButton
            popUp.selectItemAtIndex(colorAttachment.sourceRGBBlendFactor.integerValue)
            return result
        case sourceAlphaFactorColumn:
            let result = tableView.makeViewWithIdentifier("Source Alpha Factor", owner: self) as! NSTableCellView
            assert(result.subviews.count == 1)
            let popUp = result.subviews[0] as! NSPopUpButton
            popUp.selectItemAtIndex(colorAttachment.sourceAlphaBlendFactor.integerValue)
            return result
        case destinationRGBFactorColumn:
            let result = tableView.makeViewWithIdentifier("Destination RGB Factor", owner: self) as! NSTableCellView
            assert(result.subviews.count == 1)
            let popUp = result.subviews[0] as! NSPopUpButton
            popUp.selectItemAtIndex(colorAttachment.destinationRGBBlendFactor.integerValue)
            return result
        case destinationAlphaFactorColumn:
            let result = tableView.makeViewWithIdentifier("Destination Alpha Factor", owner: self) as! NSTableCellView
            assert(result.subviews.count == 1)
            let popUp = result.subviews[0] as! NSPopUpButton
            popUp.selectItemAtIndex(colorAttachment.destinationAlphaBlendFactor.integerValue)
            return result
        default:
            fatalError()
        }
    }

    @IBAction func pixelFormatSelected(sender: NSPopUpButton) {
        let row = tableView.rowForView(sender)
        let colorAttachment = state.colorAttachments[row] as! RenderPipelineColorAttachment
        guard sender.indexOfSelectedItem > 0 else {
            colorAttachment.pixelFormat = nil
            return
        }
        let format = indexToPixelFormat(sender.indexOfSelectedItem - 1)!
        colorAttachment.pixelFormat = format.rawValue
        modelObserver.modelDidChange()
    }

    @IBAction func blendingToggled(sender: NSButton) {
        let row = tableView.rowForView(sender)
        let colorAttachment = state.colorAttachments[row] as! RenderPipelineColorAttachment
        colorAttachment.blendingEnabled = sender.state == NSOnState
        modelObserver.modelDidChange()
    }

    @IBAction func redToggled(sender: NSButton) {
        let row = tableView.rowForView(sender)
        let colorAttachment = state.colorAttachments[row] as! RenderPipelineColorAttachment
        colorAttachment.writeRed = sender.state == NSOnState
        modelObserver.modelDidChange()
    }

    @IBAction func greenToggled(sender: NSButton) {
        let row = tableView.rowForView(sender)
        let colorAttachment = state.colorAttachments[row] as! RenderPipelineColorAttachment
        colorAttachment.writeGreen = sender.state == NSOnState
        modelObserver.modelDidChange()
    }

    @IBAction func blueToggled(sender: NSButton) {
        let row = tableView.rowForView(sender)
        let colorAttachment = state.colorAttachments[row] as! RenderPipelineColorAttachment
        colorAttachment.writeBlue = sender.state == NSOnState
        modelObserver.modelDidChange()
    }

    @IBAction func alphaToggled(sender: NSButton) {
        let row = tableView.rowForView(sender)
        let colorAttachment = state.colorAttachments[row] as! RenderPipelineColorAttachment
        colorAttachment.writeAlpha = sender.state == NSOnState
        modelObserver.modelDidChange()
    }

    @IBAction func rgbBlendOpSelected(sender: NSPopUpButton) {
        let row = tableView.rowForView(sender)
        let colorAttachment = state.colorAttachments[row] as! RenderPipelineColorAttachment
        assert(sender.indexOfSelectedItem >= 0)
        colorAttachment.rgbBlendOperation = sender.indexOfSelectedItem
        modelObserver.modelDidChange()
    }

    @IBAction func alphaBlendOpSelected(sender: NSPopUpButton) {
        let row = tableView.rowForView(sender)
        let colorAttachment = state.colorAttachments[row] as! RenderPipelineColorAttachment
        assert(sender.indexOfSelectedItem >= 0)
        colorAttachment.alphaBlendOperation = sender.indexOfSelectedItem
        modelObserver.modelDidChange()
    }

    @IBAction func sourceRGBFactorSelected(sender: NSPopUpButton) {
        let row = tableView.rowForView(sender)
        let colorAttachment = state.colorAttachments[row] as! RenderPipelineColorAttachment
        assert(sender.indexOfSelectedItem >= 0)
        colorAttachment.sourceRGBBlendFactor = sender.indexOfSelectedItem
        modelObserver.modelDidChange()
    }

    @IBAction func sourceAlphaFactorSelected(sender: NSPopUpButton) {
        let row = tableView.rowForView(sender)
        let colorAttachment = state.colorAttachments[row] as! RenderPipelineColorAttachment
        assert(sender.indexOfSelectedItem >= 0)
        colorAttachment.sourceAlphaBlendFactor = sender.indexOfSelectedItem
        modelObserver.modelDidChange()
    }

    @IBAction func destinationRGBFactorSelected(sender: NSPopUpButton) {
        let row = tableView.rowForView(sender)
        let colorAttachment = state.colorAttachments[row] as! RenderPipelineColorAttachment
        assert(sender.indexOfSelectedItem >= 0)
        colorAttachment.destinationRGBBlendFactor = sender.indexOfSelectedItem
        modelObserver.modelDidChange()
    }

    @IBAction func destinationAlphaFactorSelected(sender: NSPopUpButton) {
        let row = tableView.rowForView(sender)
        let colorAttachment = state.colorAttachments[row] as! RenderPipelineColorAttachment
        assert(sender.indexOfSelectedItem >= 0)
        colorAttachment.destinationAlphaBlendFactor = sender.indexOfSelectedItem
        modelObserver.modelDidChange()
    }
}

