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
    func compilationCompleted(_ success: Bool)
    func reflection(_ reflection: [MTLArgument])
}

class MetalState {
    weak var delegate: MetalStateDelegate?
    var buffers: [Buffer: MTLBuffer] = [:]
    var textures: [Texture: MTLTexture] = [:]
    var computePipelineStates: [ComputePipelineState: MTLComputePipelineState] = [:]
    var renderPipelineStates: [RenderPipelineState: MTLRenderPipelineState] = [:]
    var depthStencilStates: [DepthStencilState: MTLDepthStencilState] = [:]

    fileprivate class func fetchAll(_ managedObjectContext: NSManagedObjectContext, entityName: String) -> [NSManagedObject] {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        do {
            return try managedObjectContext.fetch(fetchRequest) as! [NSManagedObject]
        } catch {
            fatalError()
        }
    }

    fileprivate class func toMetalPixelFormat(_ i: NSNumber) -> MTLPixelFormat {
        return MTLPixelFormat(rawValue: UInt(i))!
    }

    fileprivate class func toMetalVertexFormat(_ i: NSNumber) -> MTLVertexFormat {
        return MTLVertexFormat(rawValue: UInt(i))!
    }

    fileprivate class func toMetalVertexStepFunction(_ i: NSNumber) -> MTLVertexStepFunction {
        return MTLVertexStepFunction(rawValue: UInt(i))!
    }

    func populate(_ managedObjectContext: NSManagedObjectContext, device: MTLDevice, view: MTKView) {
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
                library = try device.makeLibrary(source: libraries[0].source, options: MTLCompileOptions())
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
                    functions[functionName] = library.makeFunction(name: functionName)
                }
            }
        }

        for buffer in MetalState.fetchAll(managedObjectContext, entityName: "Buffer") as! [Buffer] {
            if let initialData = buffer.initialData {
                buffers[buffer] = device.makeBuffer(bytes: (initialData as NSData).bytes, length: initialData.count, options: .storageModeManaged)
            } else {
                buffers[buffer] = device.makeBuffer(length: buffer.initialLength!.intValue, options: .storageModePrivate)
            }
        }

        for texture in MetalState.fetchAll(managedObjectContext, entityName: "Texture") as! [Texture] {
            var newTexture: MTLTexture!
            if let initialData = texture.initialData {
                do {
                    let loader = MTKTextureLoader(device: device)
                    try newTexture = loader.newTexture(with: initialData as Data, options: nil)
                } catch {
                    fatalError()
                }
            } else {
                let descriptor = MTLTextureDescriptor()
                let pixelFormat = MTLPixelFormat(rawValue: texture.pixelFormat.uintValue)!
                if pixelFormat == .invalid {
                    continue
                }
                descriptor.pixelFormat = pixelFormat
                descriptor.textureType = MTLTextureType(rawValue: texture.textureType.uintValue)!
                descriptor.width = texture.width.intValue
                descriptor.height = texture.height.intValue
                descriptor.depth = texture.depth.intValue
                descriptor.mipmapLevelCount = texture.mipmapLevelCount.intValue
                descriptor.sampleCount = texture.sampleCount.intValue
                descriptor.arrayLength = texture.arrayLength.intValue
                descriptor.storageMode = .managed
                newTexture = device.makeTexture(descriptor: descriptor)
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
                try computePipelineStates[computePipelineState] = device.makeComputePipelineState(descriptor: descriptor, options: MTLPipelineOption(rawValue: MTLPipelineOption.argumentInfo.rawValue | MTLPipelineOption.bufferTypeInfo.rawValue), reflection: &reflection)
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
            descriptor.depthCompareFunction = MTLCompareFunction(rawValue: depthStencilState.depthCompareFunction.uintValue)!
            descriptor.isDepthWriteEnabled = depthStencilState.depthWriteEnabled.boolValue

            let backFaceStencil = MTLStencilDescriptor()
            backFaceStencil.stencilFailureOperation = MTLStencilOperation(rawValue: depthStencilState.backFaceStencil.stencilFailureOperation.uintValue)!
            backFaceStencil.depthFailureOperation = MTLStencilOperation(rawValue: depthStencilState.backFaceStencil.depthFailureOperation.uintValue)!
            backFaceStencil.depthStencilPassOperation = MTLStencilOperation(rawValue: depthStencilState.backFaceStencil.depthStencilPassOperation.uintValue)!
            backFaceStencil.stencilCompareFunction = MTLCompareFunction(rawValue: depthStencilState.backFaceStencil.stencilCompareFunction.uintValue)!
            backFaceStencil.readMask = depthStencilState.backFaceStencil.readMask.uint32Value
            backFaceStencil.writeMask = depthStencilState.backFaceStencil.writeMask.uint32Value
            descriptor.backFaceStencil = backFaceStencil

            let frontFaceStencil = MTLStencilDescriptor()
            frontFaceStencil.stencilFailureOperation = MTLStencilOperation(rawValue: depthStencilState.frontFaceStencil.stencilFailureOperation.uintValue)!
            frontFaceStencil.depthFailureOperation = MTLStencilOperation(rawValue: depthStencilState.frontFaceStencil.depthFailureOperation.uintValue)!
            frontFaceStencil.depthStencilPassOperation = MTLStencilOperation(rawValue: depthStencilState.frontFaceStencil.depthStencilPassOperation.uintValue)!
            frontFaceStencil.stencilCompareFunction = MTLCompareFunction(rawValue: depthStencilState.frontFaceStencil.stencilCompareFunction.uintValue)!
            frontFaceStencil.readMask = depthStencilState.frontFaceStencil.readMask.uint32Value
            frontFaceStencil.writeMask = depthStencilState.frontFaceStencil.writeMask.uint32Value
            descriptor.frontFaceStencil = frontFaceStencil

            depthStencilStates[depthStencilState] = device.makeDepthStencilState(descriptor: descriptor)
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
                descriptor.colorAttachments[i].isBlendingEnabled = colorAttachment.blendingEnabled.boolValue
                var colorWriteMask = MTLColorWriteMask().rawValue
                colorWriteMask |= colorAttachment.writeRed.boolValue ? MTLColorWriteMask.red.rawValue : 0
                colorWriteMask |= colorAttachment.writeGreen.boolValue ? MTLColorWriteMask.green.rawValue : 0
                colorWriteMask |= colorAttachment.writeBlue.boolValue ? MTLColorWriteMask.blue.rawValue : 0
                colorWriteMask |= colorAttachment.writeAlpha.boolValue ? MTLColorWriteMask.alpha.rawValue : 0
                descriptor.colorAttachments[i].writeMask = MTLColorWriteMask(rawValue: colorWriteMask)
                descriptor.colorAttachments[i].rgbBlendOperation = MTLBlendOperation(rawValue: colorAttachment.rgbBlendOperation.uintValue)!
                descriptor.colorAttachments[i].alphaBlendOperation = MTLBlendOperation(rawValue: colorAttachment.alphaBlendOperation.uintValue)!
                descriptor.colorAttachments[i].sourceRGBBlendFactor = MTLBlendFactor(rawValue: colorAttachment.sourceRGBBlendFactor.uintValue)!
                descriptor.colorAttachments[i].sourceAlphaBlendFactor = MTLBlendFactor(rawValue: colorAttachment.sourceAlphaBlendFactor.uintValue)!
                descriptor.colorAttachments[i].destinationRGBBlendFactor = MTLBlendFactor(rawValue: colorAttachment.destinationRGBBlendFactor.uintValue)!
                descriptor.colorAttachments[i].destinationAlphaBlendFactor = MTLBlendFactor(rawValue: colorAttachment.destinationAlphaBlendFactor.uintValue)!
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
                descriptor.sampleCount = sampleCount.intValue
            } else {
                descriptor.sampleCount = view.sampleCount
            }
            let vertexDescriptor = MTLVertexDescriptor()
            for vertexAttributeObject in renderPipelineState.vertexAttributes {
                let vertexAttribute = vertexAttributeObject as! VertexAttribute
                let index = vertexAttribute.index.intValue
                vertexDescriptor.attributes[index].format = MetalState.toMetalVertexFormat(vertexAttribute.format)
                vertexDescriptor.attributes[index].offset = Int(vertexAttribute.offset)
                vertexDescriptor.attributes[index].bufferIndex = Int(vertexAttribute.bufferIndex)
            }
            for vertexBufferLayoutObject in renderPipelineState.vertexBufferLayouts {
                let vertexBufferLayout = vertexBufferLayoutObject as! VertexBufferLayout
                let index = vertexBufferLayout.index.intValue
                vertexDescriptor.layouts[index].stepFunction = MetalState.toMetalVertexStepFunction(vertexBufferLayout.stepFunction)
                vertexDescriptor.layouts[index].stepRate = Int(vertexBufferLayout.stepRate)
                vertexDescriptor.layouts[index].stride = Int(vertexBufferLayout.stride)
            }
            descriptor.vertexDescriptor = vertexDescriptor
            descriptor.isAlphaToCoverageEnabled = renderPipelineState.alphaToCoverageEnabled.boolValue
            descriptor.isAlphaToOneEnabled = renderPipelineState.alphaToOneEnabled.boolValue
            descriptor.isRasterizationEnabled = renderPipelineState.rasterizationEnabled.boolValue
            if let inputPrimitiveTopology = MTLPrimitiveTopologyClass(rawValue: renderPipelineState.inputPrimitiveTopology.uintValue) {
                descriptor.inputPrimitiveTopology = inputPrimitiveTopology
            }
            var reflection: MTLRenderPipelineReflection?
            do {
                try renderPipelineStates[renderPipelineState] = device.makeRenderPipelineState(descriptor: descriptor, options: MTLPipelineOption(rawValue: MTLPipelineOption.argumentInfo.rawValue | MTLPipelineOption.bufferTypeInfo.rawValue), reflection: &reflection)
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
