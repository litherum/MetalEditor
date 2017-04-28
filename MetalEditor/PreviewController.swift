//
//  PreviewController.swift
//  MetalEditor
//
//  Created by Litherum on 7/16/15.
//  Copyright © 2015 Litherum. All rights reserved.
//

import Cocoa
import MetalKit

class PreviewController: NSViewController, MTKViewDelegate {
    @IBOutlet var sliderValues: SliderValues!
    var metalView: MTKView!
    var device: MTLDevice!
    var commandQueue: MTLCommandQueue!
    var builtInBufferLength = 0
    var builtInBuffers: [MTLBuffer] = []
    var metalState: MetalState!
    var frame: Frame!
    var size: CGSize = CGSize(width: 0, height: 0)
    var startDate = Date()

    override func viewDidLoad() {
        super.viewDidLoad()
        metalView = view as! MTKView
        metalView.delegate = self
    }

    func initializeWithDevice(_ device: MTLDevice, commandQueue: MTLCommandQueue, frame: Frame, metalState: MetalState) {
        self.device = device
        self.commandQueue = commandQueue
        self.frame = frame
        self.metalState = metalState
        metalView.device = device
    }

    func view(_ view: MTKView, willLayoutWithSize size: CGSize) {
        self.size = size
    }

    func mtkView(_ mtkView: MTKView, drawableSizeWillChange size: CGSize) {
        self.size = size;
    }

    fileprivate class func toMetalPrimitiveType(_ i: NSNumber) -> MTLPrimitiveType {
        return MTLPrimitiveType(rawValue: UInt(i))!
    }

    fileprivate class func bufferIndex(_ i: Int) -> Int {
        // FIXME: Should be able to put uniforms in buffer 0
        return i == 0 ? 0 : i + 1
    }

    func draw(in view: MTKView) {
        drawInView(view);
    }

    fileprivate class func emptyRenderPassDescriptor(_ descriptor: RenderPassDescriptor) -> Bool {
        for colorAttachment in descriptor.colorAttachments {
            let c = colorAttachment as! ColorAttachment
            if c.texture != nil || c.resolveTexture != nil {
                return false
            }
        }
        return descriptor.depthAttachment.texture == nil && descriptor.depthAttachment.resolveTexture == nil && descriptor.stencilAttachment.texture == nil && descriptor.stencilAttachment.resolveTexture == nil
    }

    fileprivate func generateMetalRenderPassDescriptor(_ descriptor: RenderPassDescriptor) -> MTLRenderPassDescriptor? {
        if PreviewController.emptyRenderPassDescriptor(descriptor) {
            return nil
        }

        let metalRenderPassDescriptor = MTLRenderPassDescriptor()
        let metalColorAttachments = metalRenderPassDescriptor.colorAttachments
        for i in 0 ..< descriptor.colorAttachments.count {
            let colorAttachment = descriptor.colorAttachments[i] as! ColorAttachment
            let metalColorAttachment = MTLRenderPassColorAttachmentDescriptor()
            metalColorAttachment.clearColor = MTLClearColorMake(colorAttachment.clearRed.doubleValue, colorAttachment.clearGreen.doubleValue, colorAttachment.clearBlue.doubleValue, colorAttachment.clearAlpha.doubleValue)
            if let texture = colorAttachment.texture {
                metalColorAttachment.texture = metalState.textures[texture]
            } else {
                metalColorAttachment.texture = nil
            }
            metalColorAttachment.level = colorAttachment.level.intValue
            metalColorAttachment.slice = colorAttachment.slice.intValue
            metalColorAttachment.depthPlane = colorAttachment.depthPlane.intValue
            metalColorAttachment.loadAction = MTLLoadAction(rawValue: colorAttachment.loadAction.uintValue)!
            metalColorAttachment.storeAction = MTLStoreAction(rawValue: colorAttachment.storeAction.uintValue)!
            if let resolveTexture = colorAttachment.resolveTexture {
                metalColorAttachment.resolveTexture = metalState.textures[resolveTexture]
            } else {
                metalColorAttachment.resolveTexture = nil
            }
            metalColorAttachment.resolveLevel = colorAttachment.resolveLevel.intValue
            metalColorAttachment.resolveSlice = colorAttachment.resolveSlice.intValue
            metalColorAttachment.resolveDepthPlane = colorAttachment.resolveDepthPlane.intValue
            metalColorAttachments[i] = metalColorAttachment
        }

        let metalDepthAttachment = metalRenderPassDescriptor.depthAttachment
        if let texture = descriptor.depthAttachment.texture {
            metalDepthAttachment?.texture = metalState.textures[texture]
        } else {
            metalDepthAttachment?.texture = nil
        }
        metalDepthAttachment?.level = descriptor.depthAttachment.level.intValue
        metalDepthAttachment?.slice = descriptor.depthAttachment.slice.intValue
        metalDepthAttachment?.depthPlane = descriptor.depthAttachment.depthPlane.intValue
        metalDepthAttachment?.loadAction = MTLLoadAction(rawValue: descriptor.depthAttachment.loadAction.uintValue)!
        metalDepthAttachment?.storeAction = MTLStoreAction(rawValue: descriptor.depthAttachment.storeAction.uintValue)!
        if let resolveTexture = descriptor.depthAttachment.resolveTexture {
            metalDepthAttachment?.resolveTexture = metalState.textures[resolveTexture]
        } else {
            metalDepthAttachment?.resolveTexture = nil
        }
        metalDepthAttachment?.resolveLevel = descriptor.depthAttachment.resolveLevel.intValue
        metalDepthAttachment?.resolveSlice = descriptor.depthAttachment.resolveSlice.intValue
        metalDepthAttachment?.resolveDepthPlane = descriptor.depthAttachment.resolveDepthPlane.intValue

        let metalStencilAttachment = metalRenderPassDescriptor.stencilAttachment
        if let texture = descriptor.stencilAttachment.texture {
            metalStencilAttachment?.texture = metalState.textures[texture]
        } else {
            metalStencilAttachment?.texture = nil
        }
        metalStencilAttachment?.level = descriptor.stencilAttachment.level.intValue
        metalStencilAttachment?.slice = descriptor.stencilAttachment.slice.intValue
        metalStencilAttachment?.depthPlane = descriptor.stencilAttachment.depthPlane.intValue
        metalStencilAttachment?.loadAction = MTLLoadAction(rawValue: descriptor.stencilAttachment.loadAction.uintValue)!
        metalStencilAttachment?.storeAction = MTLStoreAction(rawValue: descriptor.stencilAttachment.storeAction.uintValue)!
        if let resolveTexture = descriptor.stencilAttachment.resolveTexture {
            metalStencilAttachment?.resolveTexture = metalState.textures[resolveTexture]
        } else {
            metalStencilAttachment?.resolveTexture = nil
        }
        metalStencilAttachment?.resolveLevel = descriptor.stencilAttachment.resolveLevel.intValue
        metalStencilAttachment?.resolveSlice = descriptor.stencilAttachment.resolveSlice.intValue
        metalStencilAttachment?.resolveDepthPlane = descriptor.stencilAttachment.resolveDepthPlane.intValue

        return metalRenderPassDescriptor
    }

    fileprivate func populateBuiltInBuffer(_ ptr: UnsafeMutableRawPointer) {
        guard let uniforms = sliderValues.uniforms else {
            return
        }
        fatalError()
//        for uniform in uniforms {
//            switch uniform.type {
//            case .float:
//                assert(uniform.offset % 4 == 0)
//                let floatPtr: UnsafeMutablePointer<Float> = ptr
//                var toWrite: Float = 0
//                switch uniform.name {
//                case "time":
//                    toWrite = Float(Date().timeIntervalSince(startDate))
//                case "width":
//                    toWrite = Float(size.width)
//                case "height":
//                    toWrite = Float(size.height)
//                default:
//                    toWrite = uniform.value.floatValue
//                }
//                floatPtr[uniform.offset / 4] = toWrite
//            case .int:
//                assert(uniform.offset % 4 == 0)
//                let intPtr = UnsafeMutablePointer<Int32>(ptr)
//                intPtr[uniform.offset / 4] = uniform.value.int32Value
//            default:
//                continue
//            }
//        }
    }

    func drawInView(_ view: MTKView) {
        guard frame != nil else {
            return
        }
        if builtInBufferLength != sliderValues.length {
            builtInBuffers = []
        }
        builtInBufferLength = max(sliderValues.length, 1)
        let builtInBuffer: MTLBuffer!
        if builtInBuffers.count > 0 {
            builtInBuffer = builtInBuffers.removeLast()
        } else {
            builtInBuffer = device.makeBuffer(length: builtInBufferLength, options: .storageModeManaged)
        }
        assert(builtInBuffer != nil)
        populateBuiltInBuffer(builtInBuffer.contents())
        if builtInBuffer.storageMode == .managed {
            builtInBuffer.didModifyRange(NSMakeRange(0, builtInBufferLength))
        }
        for passObject in frame.passes {
            let pass = passObject as! Pass
            let commandBuffer = commandQueue.makeCommandBuffer()
            if let computePass = pass as? ComputePass {
                let computeCommandEncoder = commandBuffer.makeComputeCommandEncoder()
                computeCommandEncoder.setBuffer(builtInBuffer, offset: 0, at: 1)
                for invocationObject in computePass.invocations {
                    let invocation = invocationObject as! ComputeInvocation
                    let invocationState = invocation.state!
                    guard let metalComputePipelineState = metalState.computePipelineStates[invocationState] else {
                        continue
                    }
                    computeCommandEncoder.setComputePipelineState(metalComputePipelineState)
                    for i in 0 ..< invocation.bufferBindings.count {
                        let bufferOptional = (invocation.bufferBindings[i] as! BufferBinding).buffer
                        if let buffer = bufferOptional {
                            computeCommandEncoder.setBuffer(metalState.buffers[buffer], offset: 0, at: PreviewController.bufferIndex(i))
                        } else {
                            computeCommandEncoder.setBuffer(nil, offset: 0, at: PreviewController.bufferIndex(i))
                        }
                    }
                    for i in 0 ..< invocation.textureBindings.count {
                        let textureOptional = (invocation.textureBindings[i] as! TextureBinding).texture
                        if let texture = textureOptional {
                            computeCommandEncoder.setTexture(metalState.textures[texture], at: i)
                        } else {
                            computeCommandEncoder.setTexture(nil, at: i)
                        }
                    }
                    let threadgroupsPerGrid = invocation.threadgroupsPerGrid
                    let threadsPerThreadgroup = invocation.threadsPerThreadgroup
                    let metalThreadgroupsPerGrid = MTLSizeMake(Int(threadgroupsPerGrid.width), Int(threadgroupsPerGrid.height), Int(threadgroupsPerGrid.depth))
                    let metalThreadsPerThreadgroup = MTLSizeMake(Int(threadsPerThreadgroup.width), Int(threadsPerThreadgroup.height), Int(threadsPerThreadgroup.depth))
                    computeCommandEncoder.dispatchThreadgroups(metalThreadgroupsPerGrid, threadsPerThreadgroup: metalThreadsPerThreadgroup)
                }
                computeCommandEncoder.endEncoding()
            } else if let renderPass = pass as? RenderPass {
                var renderPassDescriptor: MTLRenderPassDescriptor!
                if let descriptor = renderPass.descriptor {
                    guard let descriptor = generateMetalRenderPassDescriptor(descriptor) else {
                        continue
                    }
                    renderPassDescriptor = descriptor
                } else {
                    guard let descriptor = metalView.currentRenderPassDescriptor else {
                        continue
                    }
                    renderPassDescriptor = descriptor
                }
                let renderCommandEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor)
                renderCommandEncoder.setVertexBuffer(builtInBuffer, offset: 0, at: 1)
                renderCommandEncoder.setFragmentBuffer(builtInBuffer, offset: 0, at: 1)
                for invocationObject in renderPass.invocations {
                    let invocation = invocationObject as! RenderInvocation
                    let invocationState = invocation.state!
                    guard let metalRenderPipelineState = metalState.renderPipelineStates[invocationState] else {
                        continue
                    }
                    // FIXME: See which state is already active and don't touch if it matches the requested state.
                    renderCommandEncoder.setRenderPipelineState(metalRenderPipelineState)
                    for i in 0 ..< invocation.vertexBufferBindings.count {
                        let bufferOptional = (invocation.vertexBufferBindings[i] as! BufferBinding).buffer
                        if let buffer = bufferOptional {
                            renderCommandEncoder.setVertexBuffer(metalState.buffers[buffer], offset: 0, at: PreviewController.bufferIndex(i))
                        } else {
                            renderCommandEncoder.setVertexBuffer(nil, offset: 0, at: PreviewController.bufferIndex(i))
                        }
                    }
                    for i in 0 ..< invocation.fragmentBufferBindings.count {
                        let bufferOptional = (invocation.fragmentBufferBindings[i] as! BufferBinding).buffer
                        if let buffer = bufferOptional {
                            renderCommandEncoder.setVertexBuffer(metalState.buffers[buffer], offset: 0, at: PreviewController.bufferIndex(i))
                        } else {
                            renderCommandEncoder.setVertexBuffer(nil, offset: 0, at: PreviewController.bufferIndex(i))
                        }
                    }
                    for i in 0 ..< invocation.vertexTextureBindings.count {
                        let textureOptional = (invocation.vertexTextureBindings[i] as! TextureBinding).texture
                        if let texture = textureOptional {
                            renderCommandEncoder.setVertexTexture(metalState.textures[texture], at: i)
                        } else {
                            renderCommandEncoder.setVertexTexture(nil, at: i)
                        }
                    }
                    for i in 0 ..< invocation.fragmentTextureBindings.count {
                        let textureOptional = (invocation.fragmentTextureBindings[i] as! TextureBinding).texture
                        if let texture = textureOptional {
                            renderCommandEncoder.setFragmentTexture(metalState.textures[texture], at: i)
                        } else {
                            renderCommandEncoder.setFragmentTexture(nil, at: i)
                        }
                    }
                    renderCommandEncoder.setBlendColor(red: invocation.blendColorRed.floatValue, green: invocation.blendColorGreen.floatValue, blue: invocation.blendColorBlue.floatValue, alpha: invocation.blendColorAlpha.floatValue)
                    renderCommandEncoder.setCullMode(MTLCullMode(rawValue: invocation.cullMode.uintValue)!)
                    renderCommandEncoder.setDepthBias(invocation.depthBias.floatValue, slopeScale: invocation.depthSlopeScale.floatValue, clamp: invocation.depthClamp.floatValue)
                    renderCommandEncoder.setDepthClipMode(MTLDepthClipMode(rawValue: invocation.depthClipMode.uintValue)!)

                    if let depthStencilState = invocation.depthStencilState {
                        guard let metalDepthStencilState = metalState.depthStencilStates[depthStencilState] else {
                            continue
                        }
                        renderCommandEncoder.setDepthStencilState(metalDepthStencilState)
                    } else {
                        renderCommandEncoder.setDepthStencilState(device.makeDepthStencilState(descriptor: MTLDepthStencilDescriptor()))
                    }
                    
                    renderCommandEncoder.setFrontFacing(MTLWinding(rawValue: invocation.frontFacingWinding.uintValue)!)
                    if let scissorRect = invocation.scissorRect {
                        if scissorRect.width.intValue > 0 && scissorRect.height.intValue > 0 {
                            renderCommandEncoder.setScissorRect(MTLScissorRect(x: scissorRect.x.intValue, y: scissorRect.y.intValue, width: scissorRect.width.intValue, height: scissorRect.height.intValue))
                        }
                    }
                    renderCommandEncoder.setStencilReferenceValues(front: invocation.stencilFrontReferenceValue.uint32Value, back: invocation.stencilBackReferenceValue.uint32Value)
                    renderCommandEncoder.setTriangleFillMode(MTLTriangleFillMode(rawValue: invocation.triangleFillMode.uintValue)!)
                    if let viewport = invocation.viewport {
                        renderCommandEncoder.setViewport(MTLViewport(originX: viewport.originX.doubleValue, originY: viewport.originY.doubleValue, width: viewport.width.doubleValue, height: viewport.height.doubleValue, znear: viewport.zNear.doubleValue, zfar: viewport.zFar.doubleValue))
                    }
                    renderCommandEncoder.setVisibilityResultMode(MTLVisibilityResultMode(rawValue: invocation.visibilityResultMode.uintValue)!, offset: invocation.visibilityResultOffset.intValue)
                    renderCommandEncoder.drawPrimitives(type: PreviewController.toMetalPrimitiveType(invocation.primitive), vertexStart: Int(invocation.vertexStart), vertexCount: Int(invocation.vertexCount))
                }
                renderCommandEncoder.endEncoding()
            } else {
                fatalError()
            }
            if pass == frame.passes[frame.passes.count - 1] as! Pass {
                commandBuffer.addCompletedHandler() {(commandBuffer) in
                    DispatchQueue.main.async {
                        if self.builtInBufferLength == builtInBuffer.length {
                            self.builtInBuffers.append(builtInBuffer)
                        }
                    }
                }
                if metalView.currentDrawable != nil {
                    commandBuffer.present(metalView.currentDrawable!)
                }
            }
            commandBuffer.commit()
        }
    }
}
