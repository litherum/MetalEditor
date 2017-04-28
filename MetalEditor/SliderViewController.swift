//
//  SliderViewController.swift
//  MetalEditor
//
//  Created by Litherum on 9/6/15.
//  Copyright © 2015 Litherum. All rights reserved.
//

import Cocoa

class SliderViewController: NSViewController {
    var uniform: Uniform
    @IBOutlet var nameLabel: NSTextField!
    @IBOutlet var minTextField: NSTextField!
    @IBOutlet var slider: NSSlider!
    @IBOutlet var maxTextField: NSTextField!
    @IBOutlet var valueTextField: NSTextField!

    init?(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?, uniform: Uniform) {
        self.uniform = uniform
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    @IBAction func minSet(_ sender: NSTextField) {
        slider.minValue =  Double(sender.integerValue)
        if slider.allowsTickMarkValuesOnly {
            slider.numberOfTickMarks = Int(slider.maxValue - slider.minValue) // FIXME: This math is problematic for large numbers
        }
    }

    @IBAction func sliderSet(_ sender: NSSlider) {
        uniform.value =   NSNumber(value: sender.integerValue)
        valueTextField.doubleValue = slider.doubleValue
    }

    @IBAction func maxSet(_ sender: NSTextField) {
        slider.maxValue =  Double(sender.integerValue)
        if slider.allowsTickMarkValuesOnly {
            slider.numberOfTickMarks = Int(slider.maxValue - slider.minValue)
        }
    }

    @IBAction func valueSet(_ sender: NSTextField) {
        uniform.value =   NSNumber(value: sender.integerValue)
        slider.doubleValue = sender.doubleValue
    }

}
