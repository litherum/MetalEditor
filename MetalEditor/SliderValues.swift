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

    fileprivate class func printArrayType(_ type: MTLArrayType, space: Int) {
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
        case .struct:
            if let structType = type.elementStructType() {
                printStructType(structType, space: space + 1)
            }
        case .array:
            if let arrayType = type.element() {
                printArrayType(arrayType, space: space + 1)
            }
        default:
            printSpace()
            print("Type: \(dataType(type.elementType))")
        }
    }
    
    fileprivate class func printStructType(_ type: MTLStructType, space: Int) {
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
            case .struct:
                if let structType = member.structType() {
                    printStructType(structType, space: space + 1)
                }
            case .array:
                if let arrayType = member.arrayType() {
                    printArrayType(arrayType, space: space + 1)
                }
            default:
                printSpace()
                print("Type: \(dataType(member.dataType))")
            }
        }
    }

    fileprivate class func dataType(_ type: MTLDataType) -> String {
        switch type {
        case .none:
            return "None"
        case .struct:
            return "Struct"
        case .array:
            return "Array"
        case .float:
            return "Float"
        case .float2:
            return "Float2"
        case .float3:
            return "Float3"
        case .float4:
            return "Float4"
        case .float2x2:
            return "Float2x2"
        case .float2x3:
            return "Float2x3"
        case .float2x4:
            return "Float2x4"
        case .float3x2:
            return "Float3x2"
        case .float3x3:
            return "Float3x3"
        case .float3x4:
            return "Float3x4"
        case .float4x2:
            return "Float4x2"
        case .float4x3:
            return "Float4x3"
        case .float4x4:
            return "Float4x4"
        case .half:
            return "Half"
        case .half2:
            return "Half2"
        case .half3:
            return "Half3"
        case .half4:
            return "Half4"
        case .half2x2:
            return "Half2x2"
        case .half2x3:
            return "Half2x3"
        case .half2x4:
            return "Half2x4"
        case .half3x2:
            return "Half3x2"
        case .half3x3:
            return "Half3x3"
        case .half3x4:
            return "Half3x4"
        case .half4x2:
            return "Half4x2"
        case .half4x3:
            return "Half4x3"
        case .half4x4:
            return "Half4x4"
        case .int:
            return "Int"
        case .int2:
            return "Int2"
        case .int3:
            return "Int3"
        case .int4:
            return "Int4"
        case .uint:
            return "UInt"
        case .uint2:
            return "UInt2"
        case .uint3:
            return "UInt3"
        case .uint4:
            return "UInt4"
        case .short:
            return "Short"
        case .short2:
            return "Short2"
        case .short3:
            return "Short3"
        case .short4:
            return "Short4"
        case .ushort:
            return "UShort"
        case .ushort2:
            return "UShort2"
        case .ushort3:
            return "UShort3"
        case .ushort4:
            return "UShort4"
        case .char:
            return "Char"
        case .char2:
            return "Char2"
        case .char3:
            return "Char3"
        case .char4:
            return "Char4"
        case .uchar:
            return "UChar"
        case .uchar2:
            return "UChar2"
        case .uchar3:
            return "UChar3"
        case .uchar4:
            return "UChar4"
        case .bool:
            return "Bool"
        case .bool2:
            return "Bool2"
        case .bool3:
            return "Bool3"
        case .bool4:
            return "Bool4"
        }
    }

    fileprivate class func printArguments(_ arguments: [MTLArgument]) {
        for argument in arguments {
            print("Argument \(argument.index): \"\(argument.name)\"")
            switch argument.access {
            case .readOnly:
                print("  Access: Read Only")
            case .readWrite:
                print("  Access: Read / Write")
            case .writeOnly:
                print("  Access: Write Only")
            }
            if argument.isActive {
                print("  Active")
            } else {
                print("  Inactive")
            }
            switch argument.type {
            case .buffer:
                print("  Type: Buffer")
                print("  Alignment: \(argument.bufferAlignment)")
                print("  Data Size: \(argument.bufferDataSize)")
                switch argument.bufferDataType {
                case .struct:
                    SliderValues.printStructType(argument.bufferStructType, space: 2)
                default:
                    print("  Data Type: \(SliderValues.dataType(argument.bufferDataType))")
                }
            case .threadgroupMemory:
                print("  Type: ThreadgroupMemory")
                print("  Alignment: \(argument.threadgroupMemoryAlignment)")
                print("  Data Size: \(argument.threadgroupMemoryDataSize)")
            case .sampler:
                print("  Type: Sampler")
            case .texture:
                print("  Type: Texture")
                switch argument.textureType {
                case .type1D:
                    print("  1 Dimensional")
                case .type1DArray:
                    print("  1 Dimensional Array")
                case .type2D:
                    print("  2 Dimensional")
                case .type2DArray:
                    print("  2 Dimensional Array")
                case .type2DMultisample:
                    print("  2 Dimensional Multisampled")
                case .typeCube:
                    print("  Cube")
                case .typeCubeArray:
                    print("  Cube Array")
                case .type3D:
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

    fileprivate func recordUniform(_ uniform: Uniform, lengthInBytes: Int) {
        uniforms!.append(uniform)
        length = max(length, uniform.offset + lengthInBytes)
    }

    fileprivate func populateValue(_ type: MTLDataType, structType: MTLStructType?, arrayType: MTLArrayType?, name: String, offset: Int) {
        switch type {
        case .struct:
            populateWithStruct(structType!, prefix: name, offset: offset)
        case .array:
            populateWithArray(arrayType!, prefix: name, offset: offset)
        case .float:
            let uniform = Uniform(name: name, type: type, offset: offset, value: NSNumber(value: 0 as Float))
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
        case .int:
            let uniform = Uniform(name: name, type: type, offset: offset, value: NSNumber(value: 0 as Float))
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

    fileprivate func populateWithArray(_ arrayType: MTLArrayType, prefix: String, offset: Int) {
        for i in 0 ..< arrayType.arrayLength {
            let fullOffset = offset + i * arrayType.stride
            let fullName = "\(prefix)[\(i)]"
            populateValue(arrayType.elementType, structType: arrayType.elementStructType(), arrayType: arrayType.element(), name: fullName, offset: fullOffset)
        }
    }

    fileprivate func populateWithStruct(_ structType: MTLStructType, prefix: String, offset: Int) {
        for member in structType.members {
            let fullOffset = offset + member.offset
            let fullName = prefix == "" ? member.name : "\(prefix).\(member.name)"
            populateValue(member.dataType, structType: member.structType(), arrayType: member.arrayType(), name: fullName, offset: fullOffset)
        }
    }

    func reflection(_ reflection: [MTLArgument]) {
        guard uniforms == nil else {
            return
        }

        for argument in reflection {
            guard argument.name == "uniforms" && (argument.access == .readOnly || argument.access == .readWrite) && argument.type == .buffer && argument.bufferDataType == .struct else {
                continue
            }
            uniforms = []
            populateWithStruct(argument.bufferStructType, prefix: "", offset: 0)
            break
        }
    }
}
