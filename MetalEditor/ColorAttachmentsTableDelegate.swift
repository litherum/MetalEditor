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

    @IBAction func addColorAttachment(sender: NSButton) {
        let attachmentCount = numberOfColorAttachments()
        let attachment = NSEntityDescription.insertNewObjectForEntityForName("RenderPipelineColorAttachment", inManagedObjectContext: managedObjectContext) as! RenderPipelineColorAttachment
        attachment.pixelFormat = nil
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
        assert(column == pixelFormatColumn)
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
    }

    @IBAction func pixelFormatSelected(sender: NSPopUpButton) {
        let row = tableView.rowForView(sender)
        assert(sender.indexOfSelectedItem >= 0)
        let colorAttachment = state.colorAttachments[row] as! RenderPipelineColorAttachment
        guard sender.indexOfSelectedItem > 0 else {
            colorAttachment.pixelFormat = nil
            return
        }
        let format = indexToPixelFormat(sender.indexOfSelectedItem - 1)!
        colorAttachment.pixelFormat = format.rawValue
        modelObserver.modelDidChange()
    }
}

