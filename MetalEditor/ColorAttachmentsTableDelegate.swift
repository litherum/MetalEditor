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

    func addColorAttachment() {
        let attachmentCount = numberOfColorAttachments()
        let attachment = NSEntityDescription.insertNewObjectForEntityForName("RenderPipelineColorAttachment", inManagedObjectContext: managedObjectContext) as! RenderPipelineColorAttachment
        attachment.pixelFormat = nil
        attachment.id = attachmentCount
        state.mutableOrderedSetValueForKey("colorAttachments").addObject(attachment)
    }

    func removeSelectedColorAttachment() {
        guard tableView.selectedRow >= 0 && tableView.selectedRow < state.colorAttachments.count else {
            return
        }
        managedObjectContext.deleteObject(state.colorAttachments[tableView.selectedRow] as! NSManagedObject)
    }

    func numberOfColorAttachments() -> Int {
        return state.colorAttachments.count
    }

    func numberOfRowsInTableView(tableView: NSTableView) -> Int {
        return numberOfColorAttachments()
    }

    // FIXME: Every reference to RenderStateViewController in here is a layering violation.

    func tableView(tableView: NSTableView, viewForTableColumn tableColumn: NSTableColumn?, row: Int) -> NSView? {
        guard let column = tableColumn else {
            return nil
        }
        guard let colorAttachment = state.colorAttachments[row] as? RenderPipelineColorAttachment else {
            return nil
        }
        switch column {
        case pixelFormatColumn:
            guard let result = tableView.makeViewWithIdentifier("PixelFormatPopUp", owner: self) as? NSTableCellView else {
                return nil
            }
            guard result.subviews.count == 1 else {
                return nil
            }
            guard let popUp = result.subviews[0] as? NSPopUpButton else {
                return nil
            }
            popUp.menu = RenderStateViewController.pixelFormatMenu(true)
            if let attachmentPixelFormat = colorAttachment.pixelFormat {
                guard let pixelFormat = MTLPixelFormat(rawValue: attachmentPixelFormat.unsignedLongValue) else {
                    fatalError()
                }
                popUp.selectItemAtIndex(RenderStateViewController.pixelFormatToIndex(pixelFormat) + 1)
            } else {
                popUp.selectItemAtIndex(0)
            }
            return result
        default:
            fatalError()
        }
    }

    @IBAction func pixelFormatSelected(sender: NSPopUpButton) {
        let row = tableView.rowForView(sender)
        guard row >= 0 else {
            return
        }
        guard sender.indexOfSelectedItem >= 0 else {
            return
        }
        guard let colorAttachment = state.colorAttachments[row] as? RenderPipelineColorAttachment else {
            return
        }
        guard sender.indexOfSelectedItem > 0 else {
            colorAttachment.pixelFormat = nil
            return
        }
        guard let format = RenderStateViewController.indexToPixelFormat(sender.indexOfSelectedItem - 1) else {
            fatalError()
        }
        colorAttachment.pixelFormat = format.rawValue
        modelObserver.modelDidChange()
    }
}

