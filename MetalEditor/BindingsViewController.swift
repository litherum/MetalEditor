//
//  BufferBindingTableViewDelegate.swift
//  MetalEditor
//
//  Created by Litherum on 8/10/15.
//  Copyright © 2015 Litherum. All rights reserved.
//

import Cocoa

class BindingsViewController: NSViewController, NSTableViewDelegate, NSTableViewDataSource {
    var managedObjectContext: NSManagedObjectContext!
    weak var modelObserver: ModelObserver!
    var bindings: NSOrderedSet!
    @IBOutlet var tableView: NSTableView!
    @IBOutlet var numberTableColumn: NSTableColumn!
    @IBOutlet var popUpTableColumn: NSTableColumn!

    init?(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?, managedObjectContext: NSManagedObjectContext, modelObserver: ModelObserver, bindings: NSOrderedSet) {
        self.managedObjectContext = managedObjectContext
        self.modelObserver = modelObserver
        self.bindings = bindings
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    func reloadData() {
        tableView.reloadData()
    }

    func selectedRow() -> Int? {
        let selected = tableView.selectedRow
        return selected == -1 ? nil : selected
    }

    func numberOfRowsInTableView(tableView: NSTableView) -> Int {
        return bindings.count
    }

    @IBAction func itemSelected(sender: NSPopUpButton) {
        fatalError("Subclasses should override me")
    }

    func generatePopUp(index: Int) -> (NSMenu, NSMenuItem?) {
        fatalError("Subclasses should override me")
    }

    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        switch tableColumn! {
        case numberTableColumn:
            let result = tableView.make(withIdentifier:"Number", owner: self) as! NSTableCellView
            let textField = result.textField!
            textField.integerValue = row
            return result
        case popUpTableColumn:
            let result = tableView.make(withIdentifier: "Pop Up", owner: self) as! NSTableCellView
            assert(result.subviews.count == 1)
            let popUp = result.subviews[0] as! NSPopUpButton
            let (menu, selectedItem) = generatePopUp(index: row)
            popUp.menu = menu
            if let toSelect = selectedItem {
                popUp.select(toSelect)
            } else {
                popUp.selectItem(at: 0)
            }
            return result
        default:
            fatalError()
        }
    }
}
