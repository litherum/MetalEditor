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
    var metalView: MTKView!
    var device: MTLDevice!
    var commandQueue: MTLCommandQueue!
    var builtInBuffers: [MTLBuffer] = []
    var metalState: MetalState!
    var frame: Frame!
    var size: CGSize = CGSizeMake(0, 0)
    var startDate = NSDate()

    override func viewDidLoad() {
        super.viewDidLoad()
        metalView = view as! MTKView
        metalView.delegate = self
    }

    func initializeWithDevice(device: MTLDevice, commandQueue: MTLCommandQueue, frame: Frame, metalState: MetalState) {
        self.device = device
        self.commandQueue = commandQueue
        self.frame = frame
        self.metalState = metalState
        metalView.device = device
    }

    func view(view: MTKView, willLayoutWithSize size: CGSize) {
        self.size = size
    }

    func mtkView(mtkView: MTKView, drawableSizeWillChange size: CGSize) {
        self.size = size;
    }

    private class func toMetalPrimitiveType(i: NSNumber) -> MTLPrimitiveType {
        return MTLPrimitiveType(rawValue: UInt(i))!
    }

    private class func bufferIndex(i: Int) -> Int {
        // FIXME: Should be able to put uniforms in buffer 0
        return i == 0 ? 0 : i + 1
    }

    func drawInMTKView(view: MTKView) {
        drawInView(view);
    }

    func drawInView(view: MTKView) {
        guard frame != nil else {
            return
        }
        // FIXME: Support render-to-texture
        guard let renderPassDescriptor = metalView.currentRenderPassDescriptor else {
            return
        }
        let builtInBuffer: MTLBuffer!
        if builtInBuffers.count > 0 {
            builtInBuffer = builtInBuffers.removeLast()
        } else {
            // | time | width | height | padding |
            builtInBuffer = device.newBufferWithLength(16, options: .StorageModeManaged)
        }
        assert(builtInBuffer != nil)
        let builtInPointer = UnsafeMutablePointer<Float>(builtInBuffer.contents())
        builtInPointer[0] = Float(NSDate().timeIntervalSinceDate(startDate))
        builtInPointer[1] = Float(size.width)
        builtInPointer[2] = Float(size.height)
        builtInPointer[3] = 0
        if builtInBuffer.storageMode == .Managed {
            builtInBuffer.didModifyRange(NSMakeRange(0, 16))
        }
        for passObject in frame.passes {
            let pass = passObject as! Pass
            let commandBuffer = commandQueue.commandBuffer()
            if let computePass = pass as? ComputePass {
                let computeCommandEncoder = commandBuffer.computeCommandEncoder()
                computeCommandEncoder.setBuffer(builtInBuffer, offset: 0, atIndex: 1)
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
                            computeCommandEncoder.setBuffer(metalState.buffers[buffer], offset: 0, atIndex: PreviewController.bufferIndex(i))
                        } else {
                            computeCommandEncoder.setBuffer(nil, offset: 0, atIndex: PreviewController.bufferIndex(i))
                        }
                    }
                    for i in 0 ..< invocation.textureBindings.count {
                        let textureOptional = (invocation.textureBindings[i] as! TextureBinding).texture
                        if let texture = textureOptional {
                            computeCommandEncoder.setTexture(metalState.textures[texture], atIndex: i)
                        } else {
                            computeCommandEncoder.setTexture(nil, atIndex: i)
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
                let renderCommandEncoder = commandBuffer.renderCommandEncoderWithDescriptor(renderPassDescriptor)
                renderCommandEncoder.setVertexBuffer(builtInBuffer, offset: 0, atIndex: 1)
                renderCommandEncoder.setFragmentBuffer(builtInBuffer, offset: 0, atIndex: 1)
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
                            renderCommandEncoder.setVertexBuffer(metalState.buffers[buffer], offset: 0, atIndex: PreviewController.bufferIndex(i))
                        } else {
                            renderCommandEncoder.setVertexBuffer(nil, offset: 0, atIndex: PreviewController.bufferIndex(i))
                        }
                    }
                    for i in 0 ..< invocation.fragmentBufferBindings.count {
                        let bufferOptional = (invocation.fragmentBufferBindings[i] as! BufferBinding).buffer
                        if let buffer = bufferOptional {
                            renderCommandEncoder.setVertexBuffer(metalState.buffers[buffer], offset: 0, atIndex: PreviewController.bufferIndex(i))
                        } else {
                            renderCommandEncoder.setVertexBuffer(nil, offset: 0, atIndex: PreviewController.bufferIndex(i))
                        }
                    }
                    for i in 0 ..< invocation.vertexTextureBindings.count {
                        let textureOptional = (invocation.vertexTextureBindings[i] as! TextureBinding).texture
                        if let texture = textureOptional {
                            renderCommandEncoder.setVertexTexture(metalState.textures[texture], atIndex: i)
                        } else {
                            renderCommandEncoder.setVertexTexture(nil, atIndex: i)
                        }
                    }
                    for i in 0 ..< invocation.fragmentTextureBindings.count {
                        let textureOptional = (invocation.fragmentTextureBindings[i] as! TextureBinding).texture
                        if let texture = textureOptional {
                            renderCommandEncoder.setFragmentTexture(metalState.textures[texture], atIndex: i)
                        } else {
                            renderCommandEncoder.setFragmentTexture(nil, atIndex: i)
                        }
                    }
                    renderCommandEncoder.setBlendColorRed(invocation.blendColorRed.floatValue, green: invocation.blendColorGreen.floatValue, blue: invocation.blendColorBlue.floatValue, alpha: invocation.blendColorAlpha.floatValue)
                    renderCommandEncoder.setCullMode(MTLCullMode(rawValue: invocation.cullMode.unsignedLongValue)!)
                    renderCommandEncoder.setDepthBias(invocation.depthBias.floatValue, slopeScale: invocation.depthSlopeScale.floatValue, clamp: invocation.depthClamp.floatValue)
                    renderCommandEncoder.setDepthClipMode(MTLDepthClipMode(rawValue: invocation.depthClipMode.unsignedLongValue)!)

                    if let depthStencilState = invocation.depthStencilState {
                        guard let metalDepthStencilState = metalState.depthStencilStates[depthStencilState] else {
                            continue
                        }
                        renderCommandEncoder.setDepthStencilState(metalDepthStencilState)
                    } else {
                        renderCommandEncoder.setDepthStencilState(nil)
                    }
                    
                    renderCommandEncoder.setFrontFacingWinding(MTLWinding(rawValue: invocation.frontFacingWinding.unsignedLongValue)!)
                    if let scissorRect = invocation.scissorRect {
                        if scissorRect.width.integerValue > 0 && scissorRect.height.integerValue > 0 {
                            renderCommandEncoder.setScissorRect(MTLScissorRect(x: scissorRect.x.integerValue, y: scissorRect.y.integerValue, width: scissorRect.width.integerValue, height: scissorRect.height.integerValue))
                        }
                    }
                    renderCommandEncoder.setStencilFrontReferenceValue(invocation.stencilFrontReferenceValue.unsignedIntValue, backReferenceValue: invocation.stencilBackReferenceValue.unsignedIntValue)
                    renderCommandEncoder.setTriangleFillMode(MTLTriangleFillMode(rawValue: invocation.triangleFillMode.unsignedLongValue)!)
                    if let viewport = invocation.viewport {
                        renderCommandEncoder.setViewport(MTLViewport(originX: viewport.originX.doubleValue, originY: viewport.originY.doubleValue, width: viewport.width.doubleValue, height: viewport.height.doubleValue, znear: viewport.zNear.doubleValue, zfar: viewport.zFar.doubleValue))
                    }
                    renderCommandEncoder.setVisibilityResultMode(MTLVisibilityResultMode(rawValue: invocation.visibilityResultMode.unsignedLongValue)!, offset: invocation.visibilityResultOffset.integerValue)
                    renderCommandEncoder.drawPrimitives(PreviewController.toMetalPrimitiveType(invocation.primitive), vertexStart: Int(invocation.vertexStart), vertexCount: Int(invocation.vertexCount))
                }
                renderCommandEncoder.endEncoding()
            } else {
                fatalError()
            }
            if pass == frame.passes[frame.passes.count - 1] as! Pass {
                commandBuffer.addCompletedHandler() {(commandBuffer) in
                    dispatch_async(dispatch_get_main_queue()) {
                        self.builtInBuffers.append(builtInBuffer)
                    }
                }
                if metalView.currentDrawable != nil {
                    commandBuffer.presentDrawable(metalView.currentDrawable!)
                }
            }
            commandBuffer.commit()
        }
    }
}