//
//  DoubleTextFieldDelegate.swift
//  MetalEditor
//
//  Created by Litherum on 8/29/15.
//  Copyright © 2015 Litherum. All rights reserved.
//

import Cocoa

class IntTextFieldDelegate: NSObject, NSTextFieldDelegate {
    func control(control: NSControl, isValidObject obj: AnyObject) -> Bool {
        return Int(obj as! String) != nil
    }
}

class DoubleTextFieldDelegate: NSObject, NSTextFieldDelegate {
    func control(control: NSControl, isValidObject obj: AnyObject) -> Bool {
        return Double(obj as! String) != nil
    }
}
