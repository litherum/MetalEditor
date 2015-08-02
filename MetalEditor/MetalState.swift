//
//  MetalState.swift
//  MetalEditor
//
//  Created by Litherum on 7/17/15.
//  Copyright © 2015 Litherum. All rights reserved.
//

import Cocoa
import MetalKit

protocol MetalStateDelegate: class {
    func compilationCompleted(success: Bool)
}

class MetalState {
    weak var delegate: MetalStateDelegate?
    var builtInBuffer: MTLBuffer!
    var buffers: [Buffer: MTLBuffer] = [:]
    var computePipelineStates: [ComputePipelineState: MTLComputePipelineState] = [:]
    var renderPipelineStates: [RenderPipelineState: MTLRenderPipelineState] = [:]

    private class func fetchAll(managedObjectContext: NSManagedObjectContext, entityName: String) -> [NSManagedObject] {
        let fetchRequest = NSFetchRequest(entityName: entityName)
        do {
            return try managedObjectContext.executeFetchRequest(fetchRequest) as! [NSManagedObject]
        } catch {
            return []
        }
    }

    private class func toMetalPixelFormat(i: NSNumber) -> MTLPixelFormat {
        guard let result = MTLPixelFormat(rawValue: UInt(i)) else {
            assertionFailure()
            assert(false)
        }
        return result
    }

    private class func toMetalVertexFormat(i: NSNumber) -> MTLVertexFormat {
        guard let result = MTLVertexFormat(rawValue: UInt(i)) else {
            assertionFailure()
            assert(false)
        }
        return result
    }

    private class func toMetalVertexStepFunction(i: NSNumber) -> MTLVertexStepFunction {
        guard let result = MTLVertexStepFunction(rawValue: UInt(i)) else {
            assertionFailure()
            assert(false)
        }
        return result
    }
    
    private class func printArrayType(type: MTLArrayType, space: Int) {
        let printSpace: () -> () = {
            for _ in 0 ..< space {
                print("  ", appendNewline: false)
            }
        }
        for _ in 0 ..< space - 1 {
            print("  ", appendNewline: false)
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
                print("  ", appendNewline: false)
            }
        }
        for _ in 0 ..< space - 1 {
            print("  ", appendNewline: false)
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
                    MetalState.printStructType(argument.bufferStructType, space: 2)
                default:
                    print("  Data Type: \(MetalState.dataType(argument.bufferDataType))")
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
                print("  Data Type: \(MetalState.dataType(argument.textureDataType))")
            }
        }
    }

    func populate(managedObjectContext: NSManagedObjectContext, device: MTLDevice, view: MTKView) {
        var library: MTLLibrary!
        var functions: [String: MTLFunction] = [:]
        buffers = [:]
        computePipelineStates = [:]
        renderPipelineStates = [:]

        let libraries = MetalState.fetchAll(managedObjectContext, entityName: "Library") as! [Library]
        if libraries.count != 0 {
            do {
                library = try device.newLibraryWithSource(libraries[0].source, options: MTLCompileOptions())
                if let delegate = delegate {
                    delegate.compilationCompleted(true)
                }
            } catch {
                if let delegate = delegate {
                    delegate.compilationCompleted(false)
                }
            }
            if library != nil {
                for functionName in library.functionNames {
                    functions[functionName] = library.newFunctionWithName(functionName)
                }
            }
        }

        // | time | width | height | padding |
        builtInBuffer = device.newBufferWithLength(16, options: .StorageModeManaged)

        for buffer in MetalState.fetchAll(managedObjectContext, entityName: "Buffer") as! [Buffer] {
            if let initialData = buffer.initialData {
                buffers[buffer] = device.newBufferWithBytes(initialData.bytes, length: initialData.length, options: .StorageModeManaged)
            } else if let initialLength = buffer.initialLength {
                buffers[buffer] = device.newBufferWithLength(initialLength.integerValue, options: .StorageModePrivate)
            } else {
                assertionFailure()
            }
        }
        
        for computePipelineState in MetalState.fetchAll(managedObjectContext, entityName: "ComputePipelineState") as! [ComputePipelineState] {
            guard let function = functions[computePipelineState.functionName] else {
                continue
            }
            let descriptor = MTLComputePipelineDescriptor()
            descriptor.computeFunction = function
            var reflection: MTLComputePipelineReflection?
            do {
                try computePipelineStates[computePipelineState] = device.newComputePipelineStateWithDescriptor(descriptor, options: MTLPipelineOption(), reflection: &reflection)
                if let reflection = reflection {
                    print("Compute arguments:")
                    MetalState.printArguments(reflection.arguments)
                }
            } catch {
            }
        }
        
        for renderPipelineState in MetalState.fetchAll(managedObjectContext, entityName: "RenderPipelineState") as! [RenderPipelineState] {
            guard let vertexFunction = functions[renderPipelineState.vertexFunction] else {
                continue
            }
            guard let fragmentFunction = functions[renderPipelineState.fragmentFunction] else {
                continue
            }
            let descriptor = MTLRenderPipelineDescriptor()
            descriptor.vertexFunction = vertexFunction
            descriptor.fragmentFunction = fragmentFunction
            for i in 0 ..< renderPipelineState.colorAttachments.count {
                let colorAttachment = renderPipelineState.colorAttachments[i] as! RenderPipelineColorAttachment
                if let pixelFormat = colorAttachment.pixelFormat {
                    descriptor.colorAttachments[i].pixelFormat = MetalState.toMetalPixelFormat(pixelFormat)
                } else {
                    descriptor.colorAttachments[i].pixelFormat = view.colorPixelFormat
                }
            }
            if let depthAttachmentPixelFormat = renderPipelineState.depthAttachmentPixelFormat {
                descriptor.depthAttachmentPixelFormat = MetalState.toMetalPixelFormat(depthAttachmentPixelFormat)
            } else {
                descriptor.depthAttachmentPixelFormat = view.depthStencilPixelFormat
            }
            if let stencilAttachmentPixelFormat = renderPipelineState.stencilAttachmentPixelFormat {
                descriptor.stencilAttachmentPixelFormat = MetalState.toMetalPixelFormat(stencilAttachmentPixelFormat)
            } else {
                descriptor.stencilAttachmentPixelFormat = view.depthStencilPixelFormat
            }
            if let sampleCount = renderPipelineState.sampleCount {
                descriptor.sampleCount = sampleCount.integerValue
            } else {
                descriptor.sampleCount = view.sampleCount
            }
            let vertexDescriptor = MTLVertexDescriptor()
            for i in 0 ..< renderPipelineState.vertexAttributes.count {
                let vertexAttribute = renderPipelineState.vertexAttributes[i] as! VertexAttribute
                vertexDescriptor.attributes[i].format = MetalState.toMetalVertexFormat(vertexAttribute.format)
                vertexDescriptor.attributes[i].offset = Int(vertexAttribute.offset)
                vertexDescriptor.attributes[i].bufferIndex = Int(vertexAttribute.bufferIndex)
            }
            for i in 0 ..< renderPipelineState.vertexBufferLayouts.count {
                let vertexBufferLayout = renderPipelineState.vertexBufferLayouts[i] as! VertexBufferLayout
                vertexDescriptor.layouts[i].stepFunction = MetalState.toMetalVertexStepFunction(vertexBufferLayout.stepFunction)
                vertexDescriptor.layouts[i].stepRate = Int(vertexBufferLayout.stepRate)
                vertexDescriptor.layouts[i].stride = Int(vertexBufferLayout.stride)
            }
            descriptor.vertexDescriptor = vertexDescriptor
            var reflection: MTLRenderPipelineReflection?
            do {
                try renderPipelineStates[renderPipelineState] = device.newRenderPipelineStateWithDescriptor(descriptor, options: MTLPipelineOption(), reflection: &reflection)
                if let reflection = reflection {
                    if let vertexArguments = reflection.vertexArguments {
                        print("Vertex arguments:")
                        MetalState.printArguments(vertexArguments)
                    }
                    if let fragmentArguments = reflection.fragmentArguments {
                        print("Fragment arguments:")
                        MetalState.printArguments(fragmentArguments)
                    }
                }
            } catch {
                assertionFailure()
            }
        }
    }
}