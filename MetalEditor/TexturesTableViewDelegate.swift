//
//  TexturesTableViewDelegate.swift
//  MetalEditor
//
//  Created by Litherum on 8/16/15.
//  Copyright © 2015 Litherum. All rights reserved.
//

import Cocoa
import MetalKit

class TexturesTableViewDelegate: NSObject, NSTableViewDelegate, NSTableViewDataSource, NSTextFieldDelegate {
    var managedObjectContext: NSManagedObjectContext!
    weak var modelObserver: ModelObserver!
    var device: MTLDevice! // Only needed because MTKTextureLoader can't directly give us a MTLTextureDescriptor
    @IBOutlet var tableView: NSTableView!
    @IBOutlet var nameColumn: NSTableColumn!
    @IBOutlet var specifiedColumn: NSTableColumn!
    @IBOutlet var typeColumn: NSTableColumn!
    @IBOutlet var pixelFormatColumn: NSTableColumn!
    @IBOutlet var widthColumn: NSTableColumn!
    @IBOutlet var heightColumn: NSTableColumn!
    @IBOutlet var depthColumn: NSTableColumn!
    @IBOutlet var mipmapLevelCountColumn: NSTableColumn!
    @IBOutlet var sampleCountColumn: NSTableColumn!
    @IBOutlet var arrayLengthColumn: NSTableColumn!
    @IBOutlet var imageFileColumn: NSTableColumn!

    private func numberOfTextures() -> Int {
        let fetchRequest = NSFetchRequest(entityName: "Texture")
        var error: NSError?
        let result = managedObjectContext.countForFetchRequest(fetchRequest, error: &error)
        assert(error == nil)
        return result
    }

    func numberOfRowsInTableView(tableView: NSTableView) -> Int {
        return numberOfTextures()
    }

    private func getTexture(index: Int) -> Texture {
        let fetchRequest = NSFetchRequest(entityName: "Texture")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "id", ascending: true)]
        // <rdar://problem/22108925> managedObjectContext.executeFetchRequest() crashes if you add two objects.
        // FIXME: This is a hack.
        //fetchRequest.fetchLimit = 1
        //fetchRequest.fetchOffset = index
        
        do {
            let textures = try managedObjectContext.executeFetchRequest(fetchRequest) as! [Texture]
            return textures[index]
        } catch {
            fatalError()
        }
    }

    func control(control: NSControl, isValidObject obj: AnyObject) -> Bool {
        return Int(obj as! String) != nil
    }

    @IBAction func setName(sender: NSTextField) {
        let row = tableView.rowForView(sender)
        let texture = getTexture(row)
        texture.name = sender.stringValue
        modelObserver.modelDidChange()
    }

    @IBAction func typeSelected(sender: NSPopUpButton) {
        let row = tableView.rowForView(sender)
        let texture = getTexture(row)
        texture.textureType = sender.indexOfSelectedItem
        texture.initialData = nil
        tableView.reloadData()
        modelObserver.modelDidChange()
    }

    @IBAction func pixelFormatSelected(sender: NSPopUpButton) {
        let row = tableView.rowForView(sender)
        let texture = getTexture(row)
        let format = indexToPixelFormat(sender.indexOfSelectedItem)!
        texture.pixelFormat = format.rawValue
        texture.initialData = nil
        tableView.reloadData()
        modelObserver.modelDidChange()
    }

    @IBAction func setWidth(sender: NSTextField) {
        let row = tableView.rowForView(sender)
        let texture = getTexture(row)
        texture.width = sender.integerValue
        texture.initialData = nil
        tableView.reloadData()
        modelObserver.modelDidChange()
    }

    @IBAction func setHeight(sender: NSTextField) {
        let row = tableView.rowForView(sender)
        let texture = getTexture(row)
        texture.height = sender.integerValue
        texture.initialData = nil
        tableView.reloadData()
        modelObserver.modelDidChange()
    }

    @IBAction func setDepth(sender: NSTextField) {
        let row = tableView.rowForView(sender)
        let texture = getTexture(row)
        texture.depth = sender.integerValue
        texture.initialData = nil
        tableView.reloadData()
        modelObserver.modelDidChange()
    }

    @IBAction func setMipmapLevelCount(sender: NSTextField) {
        let row = tableView.rowForView(sender)
        let texture = getTexture(row)
        texture.mipmapLevelCount = sender.integerValue
        texture.initialData = nil
        tableView.reloadData()
        modelObserver.modelDidChange()
    }

    @IBAction func setSampleCount(sender: NSTextField) {
        let row = tableView.rowForView(sender)
        let texture = getTexture(row)
        texture.sampleCount = sender.integerValue
        texture.initialData = nil
        tableView.reloadData()
        modelObserver.modelDidChange()
    }

    @IBAction func setArrayLength(sender: NSTextField) {
        let row = tableView.rowForView(sender)
        let texture = getTexture(row)
        texture.arrayLength = sender.integerValue
        texture.initialData = nil
        tableView.reloadData()
        modelObserver.modelDidChange()
    }

    @IBAction func setData(sender: NSButton) {
        let row = tableView.rowForView(sender)
        let texture = getTexture(row)
        let window = tableView.window!
        let openPanel = NSOpenPanel()
        openPanel.allowsMultipleSelection = false
        openPanel.beginSheetModalForWindow(window) {(selected: Int) in
            guard selected == NSFileHandlingPanelOKButton else {
                return
            }
            guard let url = openPanel.URL else {
                return
            }
            guard let contents = NSData(contentsOfURL: url) else {
                return
            }
            do {
                let loader = MTKTextureLoader(device: self.device)
                let newTexture = try loader.newTextureWithContentsOfURL(url, options: nil)
                texture.initialData = contents
                texture.arrayLength = newTexture.arrayLength
                texture.depth = newTexture.depth
                texture.height = newTexture.height
                texture.width = newTexture.width
                texture.mipmapLevelCount = newTexture.mipmapLevelCount
                texture.pixelFormat = newTexture.pixelFormat.rawValue
                texture.sampleCount = newTexture.sampleCount
                texture.textureType = newTexture.textureType.rawValue
            } catch {
                return
            }
            self.tableView.reloadData()
            self.modelObserver.modelDidChange()
        }
    }

    func tableView(tableView: NSTableView, viewForTableColumn tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let texture = getTexture(row)
        switch tableColumn! {
        case nameColumn:
            let result = tableView.makeViewWithIdentifier("Name", owner: self) as! NSTableCellView
            let textField = result.textField!
            textField.editable = true
            textField.stringValue = texture.name
            return result
        case specifiedColumn:
            let result = tableView.makeViewWithIdentifier("Specified", owner: self) as! NSTableCellView
            if texture.initialData != nil {
                result.textField!.stringValue = "Initial data"
            } else {
                result.textField!.stringValue = "No initial data"
            }
            return result
        case typeColumn:
            let result = tableView.makeViewWithIdentifier("Type", owner: self) as! NSTableCellView
            assert(result.subviews.count == 1)
            let popUp = result.subviews[0] as! NSPopUpButton
            popUp.selectItemAtIndex(texture.textureType.integerValue)
            return result
        case pixelFormatColumn:
            let result = tableView.makeViewWithIdentifier("Pixel Format", owner: self) as! NSTableCellView
            assert(result.subviews.count == 1)
            let popUp = result.subviews[0] as! NSPopUpButton
            popUp.menu = pixelFormatMenu(false)
            let pixelFormat = MTLPixelFormat(rawValue: texture.pixelFormat.unsignedLongValue)!
            popUp.selectItemAtIndex(pixelFormatToIndex(pixelFormat))
            return result
        case widthColumn:
            let result = tableView.makeViewWithIdentifier("Width", owner: self) as! NSTableCellView
            let textField = result.textField!
            textField.editable = true
            textField.integerValue = texture.width.integerValue
            return result
        case heightColumn:
            let result = tableView.makeViewWithIdentifier("Height", owner: self) as! NSTableCellView
            let textField = result.textField!
            textField.editable = true
            textField.integerValue = texture.height.integerValue
            return result
        case depthColumn:
            let result = tableView.makeViewWithIdentifier("Depth", owner: self) as! NSTableCellView
            let textField = result.textField!
            textField.editable = true
            textField.integerValue = texture.depth.integerValue
            return result
        case mipmapLevelCountColumn:
            let result = tableView.makeViewWithIdentifier("Mipmap Level Count", owner: self) as! NSTableCellView
            let textField = result.textField!
            textField.editable = true
            textField.integerValue = texture.mipmapLevelCount.integerValue
            return result
        case sampleCountColumn:
            let result = tableView.makeViewWithIdentifier("Sample Count", owner: self) as! NSTableCellView
            let textField = result.textField!
            textField.editable = true
            textField.integerValue = texture.sampleCount.integerValue
            return result
        case arrayLengthColumn:
            let result = tableView.makeViewWithIdentifier("Array Length", owner: self) as! NSTableCellView
            let textField = result.textField!
            textField.editable = true
            textField.integerValue = texture.arrayLength.integerValue
            return result
        case imageFileColumn:
            return tableView.makeViewWithIdentifier("Image File", owner: self) as! NSTableCellView
        default:
            return nil
        }
    }

    @IBAction func addRemove(sender: NSSegmentedControl) {
        if sender.selectedSegment == 0 { // Add
            let textureCount = numberOfTextures()
            let texture = NSEntityDescription.insertNewObjectForEntityForName("Texture", inManagedObjectContext: managedObjectContext) as! Texture
            texture.name = "Texture"
            texture.id = textureCount
            texture.initialData = nil
            texture.arrayLength = 1
            texture.width = 1
            texture.height = 1
            texture.depth = 1
            texture.mipmapLevelCount = 1
            texture.sampleCount = 1
            texture.textureType = MTLTextureType.Type2D.rawValue
            texture.pixelFormat = MTLPixelFormat.Invalid.rawValue
        } else { // Remove
            assert(sender.selectedSegment == 1)
            guard tableView.selectedRow >= 0 else {
                return
            }
            managedObjectContext.deleteObject(getTexture(tableView.selectedRow))
        }
        tableView.reloadData()
        modelObserver.modelDidChange()
        sender.selectedSegment = -1
    }
}
