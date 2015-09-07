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

    init?(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?, uniform: Uniform) {
        self.uniform = uniform
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    @IBAction func minSet(sender: NSTextField) {
        slider.minValue = sender.doubleValue
        if slider.allowsTickMarkValuesOnly {
            slider.numberOfTickMarks = Int(slider.maxValue - slider.minValue) // FIXME: This math is problematic for large numbers
        }
    }

    @IBAction func sliderSet(sender: NSSlider) {
        uniform.value = sender.doubleValue
        valueTextField.doubleValue = slider.doubleValue
    }

    @IBAction func maxSet(sender: NSTextField) {
        slider.maxValue = sender.doubleValue
        if slider.allowsTickMarkValuesOnly {
            slider.numberOfTickMarks = Int(slider.maxValue - slider.minValue)
        }
    }

    @IBAction func valueSet(sender: NSTextField) {
        uniform.value = sender.doubleValue
        slider.doubleValue = sender.doubleValue
    }

}
