//
//  MetalState.swift
//  MetalEditor
//
//  Created by Litherum on 7/17/15.
//  Copyright © 2015 Litherum. All rights reserved.
//

import Cocoa
import MetalKit

class MetalState {
    var buffers: [Buffer: MTLBuffer] = [:]
    var computePipelineStates: [ComputePipelineState: MTLComputePipelineState] = [:]
    var renderPipelineStates: [RenderPipelineState: MTLRenderPipelineState] = [:]

    class func fetchAll(managedObjectContext: NSManagedObjectContext, entityName: String) -> [NSManagedObject] {
        let fetchRequest = NSFetchRequest(entityName: entityName)
        do {
            return try managedObjectContext.executeFetchRequest(fetchRequest) as! [NSManagedObject]
        } catch {
            return []
        }
    }

    class func toMetalPixelFormat(i: NSNumber) -> MTLPixelFormat {
        guard let result = MTLPixelFormat(rawValue: UInt(i)) else {
            assertionFailure()
            assert(false)
        }
        return result
    }

    class func toMetalVertexFormat(i: NSNumber) -> MTLVertexFormat {
        guard let result = MTLVertexFormat(rawValue: UInt(i)) else {
            assertionFailure()
            assert(false)
        }
        return result
    }

    class func toMetalVertexStepFunction(i: NSNumber) -> MTLVertexStepFunction {
        guard let result = MTLVertexStepFunction(rawValue: UInt(i)) else {
            assertionFailure()
            assert(false)
        }
        return result
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
            } catch {
                assertionFailure()
            }
            for functionName in library.functionNames {
                functions[functionName] = library.newFunctionWithName(functionName)
            }
        }

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
            do {
                try computePipelineStates[computePipelineState] = device.newComputePipelineStateWithFunction(function)
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
            do {
                try renderPipelineStates[renderPipelineState] = device.newRenderPipelineStateWithDescriptor(descriptor)
            } catch {
            }
        }
    }
}