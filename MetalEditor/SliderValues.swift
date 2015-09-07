//
//  SliderValues.swift
//  MetalEditor
//
//  Created by Litherum on 9/6/15.
//  Copyright © 2015 Litherum. All rights reserved.
//

import Cocoa

class Uniform {
    var name: String
    var type: MTLDataType
    var offset: Int
    var value: NSNumber

    init(name: String, type: MTLDataType, offset: Int, value: NSNumber) {
        self.name = name
        self.type = type
        self.offset = offset
        self.value = value
    }
}

class SliderValues: NSViewController {

    private class func printArrayType(type: MTLArrayType, space: Int) {
        let printSpace: () -> () = {
            for _ in 0 ..< space {
                print("  ", terminator: "")
            }
        }
        for _ in 0 ..< space - 1 {
            print("  ", terminator: "")
        }
        print("Type: Array:")
        printSpace()
        print("Length: \(type.arrayLength)")
        printSpace()
        print("Stride: \(type.stride)")
        switch type.elementType {
        case .Struct:
            if let structType = type.elementStructType() {
                printStructType(structType, space: space + 1)
            }
        case .Array:
            if let arrayType = type.elementArrayType() {
                printArrayType(arrayType, space: space + 1)
            }
        default:
            printSpace()
            print("Type: \(dataType(type.elementType))")
        }
    }
    
    private class func printStructType(type: MTLStructType, space: Int) {
        let printSpace: () -> () = {
            for _ in 0 ..< space {
                print("  ", terminator: "")
            }
        }
        for _ in 0 ..< space - 1 {
            print("  ", terminator: "")
        }
        // FIXME: There always seems to be 0 members
        print("Type: Struct (\(type.members.count) members):")
        for member in type.members {
            printSpace()
            print("Member Name: \(member.name)")
            printSpace()
            print("Member Offset: \(member.offset)")
            switch member.dataType {
            case .Struct:
                if let structType = member.structType() {
                    printStructType(structType, space: space + 1)
                }
            case .Array:
                if let arrayType = member.arrayType() {
                    printArrayType(arrayType, space: space + 1)
                }
            default:
                printSpace()
                print("Type: \(dataType(member.dataType))")
            }
        }
    }

    private class func dataType(type: MTLDataType) -> String {
        switch type {
        case .None:
            return "None"
        case .Struct:
            return "Struct"
        case .Array:
            return "Array"
        case .Float:
            return "Float"
        case .Float2:
            return "Float2"
        case .Float3:
            return "Float3"
        case .Float4:
            return "Float4"
        case .Float2x2:
            return "Float2x2"
        case .Float2x3:
            return "Float2x3"
        case .Float2x4:
            return "Float2x4"
        case .Float3x2:
            return "Float3x2"
        case .Float3x3:
            return "Float3x3"
        case .Float3x4:
            return "Float3x4"
        case .Float4x2:
            return "Float4x2"
        case .Float4x3:
            return "Float4x3"
        case .Float4x4:
            return "Float4x4"
        case .Half:
            return "Half"
        case .Half2:
            return "Half2"
        case .Half3:
            return "Half3"
        case .Half4:
            return "Half4"
        case .Half2x2:
            return "Half2x2"
        case .Half2x3:
            return "Half2x3"
        case .Half2x4:
            return "Half2x4"
        case .Half3x2:
            return "Half3x2"
        case .Half3x3:
            return "Half3x3"
        case .Half3x4:
            return "Half3x4"
        case .Half4x2:
            return "Half4x2"
        case .Half4x3:
            return "Half4x3"
        case .Half4x4:
            return "Half4x4"
        case .Int:
            return "Int"
        case .Int2:
            return "Int2"
        case .Int3:
            return "Int3"
        case .Int4:
            return "Int4"
        case .UInt:
            return "UInt"
        case .UInt2:
            return "UInt2"
        case .UInt3:
            return "UInt3"
        case .UInt4:
            return "UInt4"
        case .Short:
            return "Short"
        case .Short2:
            return "Short2"
        case .Short3:
            return "Short3"
        case .Short4:
            return "Short4"
        case .UShort:
            return "UShort"
        case .UShort2:
            return "UShort2"
        case .UShort3:
            return "UShort3"
        case .UShort4:
            return "UShort4"
        case .Char:
            return "Char"
        case .Char2:
            return "Char2"
        case .Char3:
            return "Char3"
        case .Char4:
            return "Char4"
        case .UChar:
            return "UChar"
        case .UChar2:
            return "UChar2"
        case .UChar3:
            return "UChar3"
        case .UChar4:
            return "UChar4"
        case .Bool:
            return "Bool"
        case .Bool2:
            return "Bool2"
        case .Bool3:
            return "Bool3"
        case .Bool4:
            return "Bool4"
        }
    }

    private class func printArguments(arguments: [MTLArgument]) {
        for argument in arguments {
            print("Argument \(argument.index): \"\(argument.name)\"")
            switch argument.access {
            case .ReadOnly:
                print("  Access: Read Only")
            case .ReadWrite:
                print("  Access: Read / Write")
            case .WriteOnly:
                print("  Access: Write Only")
            }
            if argument.active {
                print("  Active")
            } else {
                print("  Inactive")
            }
            switch argument.type {
            case .Buffer:
                print("  Type: Buffer")
                print("  Alignment: \(argument.bufferAlignment)")
                print("  Data Size: \(argument.bufferDataSize)")
                switch argument.bufferDataType {
                case .Struct:
                    SliderValues.printStructType(argument.bufferStructType, space: 2)
                default:
                    print("  Data Type: \(SliderValues.dataType(argument.bufferDataType))")
                }
            case .ThreadgroupMemory:
                print("  Type: ThreadgroupMemory")
                print("  Alignment: \(argument.threadgroupMemoryAlignment)")
                print("  Data Size: \(argument.threadgroupMemoryDataSize)")
            case .Sampler:
                print("  Type: Sampler")
            case .Texture:
                print("  Type: Texture")
                switch argument.textureType {
                case .Type1D:
                    print("  1 Dimensional")
                case .Type1DArray:
                    print("  1 Dimensional Array")
                case .Type2D:
                    print("  2 Dimensional")
                case .Type2DArray:
                    print("  2 Dimensional Array")
                case .Type2DMultisample:
                    print("  2 Dimensional Multisampled")
                case .TypeCube:
                    print("  Cube")
                case .TypeCubeArray:
                    print("  Cube Array")
                case .Type3D:
                    print("  3 Dimensional")
                }
                print("  Data Type: \(SliderValues.dataType(argument.textureDataType))")
            }
        }
    }

    @IBOutlet var stackView: NSStackView!
    var uniforms: [Uniform]?
    var length = 0
    var intTextFieldDelegate = IntTextFieldDelegate()
    var doubleTextFieldDelegate = DoubleTextFieldDelegate()

    func clear() {
        while stackView.arrangedSubviews.count != 0 {
            stackView.arrangedSubviews[0].removeFromSuperview()
        }
        childViewControllers.removeAll()
        uniforms = nil
        length = 0
    }

    private func recordUniform(uniform: Uniform, lengthInBytes: Int) {
        uniforms!.append(uniform)
        length = max(length, uniform.offset + lengthInBytes)
    }

    private func populateValue(type: MTLDataType, structType: MTLStructType?, arrayType: MTLArrayType?, name: String, offset: Int) {
        switch type {
        case .Struct:
            populateWithStruct(structType!, prefix: name, offset: offset)
        case .Array:
            populateWithArray(arrayType!, prefix: name, offset: offset)
        case .Float:
            let uniform = Uniform(name: name, type: type, offset: offset, value: NSNumber(float: 0))
            if name != "time" && name != "width" && name != "height" {
                let controller = SliderViewController(nibName: "Slider", bundle: nil, uniform: uniform)!
                stackView.addArrangedSubview(controller.view)
                addChildViewController(controller)
                controller.nameLabel.stringValue = name
                controller.valueTextField.delegate = doubleTextFieldDelegate
                controller.minTextField.delegate = doubleTextFieldDelegate
                controller.maxTextField.delegate = doubleTextFieldDelegate
            }
            recordUniform(uniform, lengthInBytes: 4)
        case .Int:
            let uniform = Uniform(name: name, type: type, offset: offset, value: NSNumber(float: 0))
            let controller = SliderViewController(nibName: "Slider", bundle: nil, uniform: uniform)!
            stackView.addArrangedSubview(controller.view)
            addChildViewController(controller)
            controller.nameLabel.stringValue = name
            controller.valueTextField.delegate = intTextFieldDelegate
            controller.minTextField.delegate = intTextFieldDelegate
            controller.maxTextField.delegate = intTextFieldDelegate
            // FIXME: Set the min & max value text field's delegate to make sure that max > min
            controller.slider.allowsTickMarkValuesOnly = true
            controller.slider.numberOfTickMarks = Int(controller.slider.maxValue - controller.slider.minValue)
            recordUniform(uniform, lengthInBytes: 4)
        // FIXME: Add vector and matrix types
        default:
            return
        }
    }

    private func populateWithArray(arrayType: MTLArrayType, prefix: String, offset: Int) {
        for i in 0 ..< arrayType.arrayLength {
            let fullOffset = offset + i * arrayType.stride
            let fullName = "\(prefix)[\(i)]"
            populateValue(arrayType.elementType, structType: arrayType.elementStructType(), arrayType: arrayType.elementArrayType(), name: fullName, offset: fullOffset)
        }
    }

    private func populateWithStruct(structType: MTLStructType, prefix: String, offset: Int) {
        for member in structType.members {
            let fullOffset = offset + member.offset
            let fullName = prefix == "" ? member.name : "\(prefix).\(member.name)"
            populateValue(member.dataType, structType: member.structType(), arrayType: member.arrayType(), name: fullName, offset: fullOffset)
        }
    }

    func reflection(reflection: [MTLArgument]) {
        guard uniforms == nil else {
            return
        }

        for argument in reflection {
            guard argument.name == "uniforms" && (argument.access == .ReadOnly || argument.access == .ReadWrite) && argument.type == .Buffer && argument.bufferDataType == .Struct else {
                continue
            }
            uniforms = []
            populateWithStruct(argument.bufferStructType, prefix: "", offset: 0)
            break
        }
    }
}