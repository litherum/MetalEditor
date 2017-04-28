//
//  DoubleTextFieldDelegate.swift
//  MetalEditor
//
//  Created by Litherum on 8/29/15.
//  Copyright © 2015 Litherum. All rights reserved.
//

import Cocoa

class IntTextFieldDelegate: NSObject, NSTextFieldDelegate {
    func control(_ control: NSControl, isValidObject obj: Any?) -> Bool {
        return Int(obj as! String) != nil
    }
}

class DoubleTextFieldDelegate: NSObject, NSTextFieldDelegate {
    func control(_ control: NSControl, isValidObject obj: Any?) -> Bool {
        return Double(obj as! String) != nil
    }
}
