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
    func reflection(reflection: [MTLArgument])
}

class MetalState {
    weak var delegate: MetalStateDelegate?
    var buffers: [Buffer: MTLBuffer] = [:]
    var textures: [Texture: MTLTexture] = [:]
    var computePipelineStates: [ComputePipelineState: MTLComputePipelineState] = [:]
    var renderPipelineStates: [RenderPipelineState: MTLRenderPipelineState] = [:]
    var depthStencilStates: [DepthStencilState: MTLDepthStencilState] = [:]

    private class func fetchAll(managedObjectContext: NSManagedObjectContext, entityName: String) -> [NSManagedObject] {
        let fetchRequest = NSFetchRequest(entityName: entityName)
        do {
            return try managedObjectContext.executeFetchRequest(fetchRequest) as! [NSManagedObject]
        } catch {
            fatalError()
        }
    }

    private class func toMetalPixelFormat(i: NSNumber) -> MTLPixelFormat {
        return MTLPixelFormat(rawValue: UInt(i))!
    }

    private class func toMetalVertexFormat(i: NSNumber) -> MTLVertexFormat {
        return MTLVertexFormat(rawValue: UInt(i))!
    }

    private class func toMetalVertexStepFunction(i: NSNumber) -> MTLVertexStepFunction {
        return MTLVertexStepFunction(rawValue: UInt(i))!
    }

    func populate(managedObjectContext: NSManagedObjectContext, device: MTLDevice, view: MTKView) {
        var library: MTLLibrary!
        var functions: [String: MTLFunction] = [:]
        buffers = [:]
        textures = [:]
        computePipelineStates = [:]
        renderPipelineStates = [:]
        depthStencilStates = [:]

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

        for buffer in MetalState.fetchAll(managedObjectContext, entityName: "Buffer") as! [Buffer] {
            if let initialData = buffer.initialData {
                buffers[buffer] = device.newBufferWithBytes(initialData.bytes, length: initialData.length, options: .StorageModeManaged)
            } else {
                buffers[buffer] = device.newBufferWithLength(buffer.initialLength!.integerValue, options: .StorageModePrivate)
            }
        }

        for texture in MetalState.fetchAll(managedObjectContext, entityName: "Texture") as! [Texture] {
            var newTexture: MTLTexture!
            if let initialData = texture.initialData {
                do {
                    let loader = MTKTextureLoader(device: device)
                    try newTexture = loader.newTextureWithData(initialData, options: nil)
                } catch {
                    fatalError()
                }
            } else {
                let descriptor = MTLTextureDescriptor()
                let pixelFormat = MTLPixelFormat(rawValue: texture.pixelFormat.unsignedLongValue)!
                if pixelFormat == .Invalid {
                    continue
                }
                descriptor.pixelFormat = pixelFormat
                descriptor.textureType = MTLTextureType(rawValue: texture.textureType.unsignedLongValue)!
                descriptor.width = texture.width.integerValue
                descriptor.height = texture.height.integerValue
                descriptor.depth = texture.depth.integerValue
                descriptor.mipmapLevelCount = texture.mipmapLevelCount.integerValue
                descriptor.sampleCount = texture.sampleCount.integerValue
                descriptor.arrayLength = texture.arrayLength.integerValue
                descriptor.storageMode = .Managed
                newTexture = device.newTextureWithDescriptor(descriptor)
            }
            assert(newTexture != nil)
            textures[texture] = newTexture
        }

        for computePipelineState in MetalState.fetchAll(managedObjectContext, entityName: "ComputePipelineState") as! [ComputePipelineState] {
            guard let function = functions[computePipelineState.functionName] else {
                continue
            }
            let descriptor = MTLComputePipelineDescriptor()
            descriptor.computeFunction = function
            var reflection: MTLComputePipelineReflection?
            do {
                try computePipelineStates[computePipelineState] = device.newComputePipelineStateWithDescriptor(descriptor, options: MTLPipelineOption(rawValue: MTLPipelineOption.ArgumentInfo.rawValue | MTLPipelineOption.BufferTypeInfo.rawValue), reflection: &reflection)
                if let reflection = reflection {
                    if let delegate = delegate {
                        delegate.reflection(reflection.arguments)
                    }
                }
            } catch {
                fatalError()
            }
        }

        for depthStencilState in MetalState.fetchAll(managedObjectContext, entityName: "DepthStencilState") as! [DepthStencilState] {
            let descriptor = MTLDepthStencilDescriptor()
            descriptor.depthCompareFunction = MTLCompareFunction(rawValue: depthStencilState.depthCompareFunction.unsignedLongValue)!
            descriptor.depthWriteEnabled = depthStencilState.depthWriteEnabled.boolValue

            let backFaceStencil = MTLStencilDescriptor()
            backFaceStencil.stencilFailureOperation = MTLStencilOperation(rawValue: depthStencilState.backFaceStencil.stencilFailureOperation.unsignedLongValue)!
            backFaceStencil.depthFailureOperation = MTLStencilOperation(rawValue: depthStencilState.backFaceStencil.depthFailureOperation.unsignedLongValue)!
            backFaceStencil.depthStencilPassOperation = MTLStencilOperation(rawValue: depthStencilState.backFaceStencil.depthStencilPassOperation.unsignedLongValue)!
            backFaceStencil.stencilCompareFunction = MTLCompareFunction(rawValue: depthStencilState.backFaceStencil.stencilCompareFunction.unsignedLongValue)!
            backFaceStencil.readMask = depthStencilState.backFaceStencil.readMask.unsignedIntValue
            backFaceStencil.writeMask = depthStencilState.backFaceStencil.writeMask.unsignedIntValue
            descriptor.backFaceStencil = backFaceStencil

            let frontFaceStencil = MTLStencilDescriptor()
            frontFaceStencil.stencilFailureOperation = MTLStencilOperation(rawValue: depthStencilState.frontFaceStencil.stencilFailureOperation.unsignedLongValue)!
            frontFaceStencil.depthFailureOperation = MTLStencilOperation(rawValue: depthStencilState.frontFaceStencil.depthFailureOperation.unsignedLongValue)!
            frontFaceStencil.depthStencilPassOperation = MTLStencilOperation(rawValue: depthStencilState.frontFaceStencil.depthStencilPassOperation.unsignedLongValue)!
            frontFaceStencil.stencilCompareFunction = MTLCompareFunction(rawValue: depthStencilState.frontFaceStencil.stencilCompareFunction.unsignedLongValue)!
            frontFaceStencil.readMask = depthStencilState.frontFaceStencil.readMask.unsignedIntValue
            frontFaceStencil.writeMask = depthStencilState.frontFaceStencil.writeMask.unsignedIntValue
            descriptor.frontFaceStencil = frontFaceStencil

            depthStencilStates[depthStencilState] = device.newDepthStencilStateWithDescriptor(descriptor)
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
                descriptor.colorAttachments[i].blendingEnabled = colorAttachment.blendingEnabled.boolValue
                var colorWriteMask = MTLColorWriteMask.None.rawValue
                colorWriteMask |= colorAttachment.writeRed.boolValue ? MTLColorWriteMask.Red.rawValue : 0
                colorWriteMask |= colorAttachment.writeGreen.boolValue ? MTLColorWriteMask.Green.rawValue : 0
                colorWriteMask |= colorAttachment.writeBlue.boolValue ? MTLColorWriteMask.Blue.rawValue : 0
                colorWriteMask |= colorAttachment.writeAlpha.boolValue ? MTLColorWriteMask.Alpha.rawValue : 0
                descriptor.colorAttachments[i].writeMask = MTLColorWriteMask(rawValue: colorWriteMask)
                descriptor.colorAttachments[i].rgbBlendOperation = MTLBlendOperation(rawValue: colorAttachment.rgbBlendOperation.unsignedLongValue)!
                descriptor.colorAttachments[i].alphaBlendOperation = MTLBlendOperation(rawValue: colorAttachment.alphaBlendOperation.unsignedLongValue)!
                descriptor.colorAttachments[i].sourceRGBBlendFactor = MTLBlendFactor(rawValue: colorAttachment.sourceRGBBlendFactor.unsignedLongValue)!
                descriptor.colorAttachments[i].sourceAlphaBlendFactor = MTLBlendFactor(rawValue: colorAttachment.sourceAlphaBlendFactor.unsignedLongValue)!
                descriptor.colorAttachments[i].destinationRGBBlendFactor = MTLBlendFactor(rawValue: colorAttachment.destinationRGBBlendFactor.unsignedLongValue)!
                descriptor.colorAttachments[i].destinationAlphaBlendFactor = MTLBlendFactor(rawValue: colorAttachment.destinationAlphaBlendFactor.unsignedLongValue)!
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
            descriptor.alphaToCoverageEnabled = renderPipelineState.alphaToCoverageEnabled.boolValue
            descriptor.alphaToOneEnabled = renderPipelineState.alphaToOneEnabled.boolValue
            descriptor.rasterizationEnabled = renderPipelineState.rasterizationEnabled.boolValue
            if let inputPrimitiveTopology = MTLPrimitiveTopologyClass(rawValue: renderPipelineState.inputPrimitiveTopology.unsignedLongValue) {
                descriptor.inputPrimitiveTopology = inputPrimitiveTopology
            }
            var reflection: MTLRenderPipelineReflection?
            do {
                try renderPipelineStates[renderPipelineState] = device.newRenderPipelineStateWithDescriptor(descriptor, options: MTLPipelineOption(rawValue: MTLPipelineOption.ArgumentInfo.rawValue | MTLPipelineOption.BufferTypeInfo.rawValue), reflection: &reflection)
                if let reflection = reflection {
                    if let vertexArguments = reflection.vertexArguments {
                        if let delegate = delegate {
                            delegate.reflection(vertexArguments)
                        }
                    }
                    if let fragmentArguments = reflection.fragmentArguments {
                        if let delegate = delegate {
                            delegate.reflection(fragmentArguments)
                        }
                    }
                }
            } catch let error {
                print("Could not compile render pipeline state \"\(renderPipelineState.name)\": \(error)")
            }
        }
    }
}