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
    var metalState: MetalState!
    var frame: Frame!
    var size: CGSize = CGSizeMake(0, 0)
    var startDate = NSDate()
    var lock = NSLock()

    override func viewDidLoad() {
        super.viewDidLoad()
        metalView = view as! MTKView
        metalView.delegate = self
        metalView.enableSetNeedsDisplay = true
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

    private class func toMetalPrimitiveType(i: NSNumber) -> MTLPrimitiveType {
        guard let result = MTLPrimitiveType(rawValue: UInt(i)) else {
            assertionFailure()
            assert(false)
        }
        return result
    }

    private class func bufferIndex(i: Int) -> Int {
        // FIXME: Should be able to put uniforms in buffer 0
        if i == 0 {
            return 0
        }
        return i + 1
    }

    func drawInView(view: MTKView) {
        guard frame != nil else {
            return
        }
        guard lock.tryLock() else {
            return
        }
        // FIXME: Support render-to-texture
        guard let renderPassDescriptor = metalView.currentRenderPassDescriptor else {
            assertionFailure()
            assert(false)
        }
        // | time | width | height | padding |
        let builtInPointer = UnsafeMutablePointer<Float>(metalState.builtInBuffer.contents())
        builtInPointer[0] = Float(NSDate().timeIntervalSinceDate(startDate))
        builtInPointer[1] = Float(size.width)
        builtInPointer[2] = Float(size.height)
        builtInPointer[3] = 0
        if metalState.builtInBuffer.storageMode == .Managed {
            metalState.builtInBuffer.didModifyRange(NSMakeRange(0, 16))
        }
        for passObject in frame.passes {
            let pass = passObject as! Pass
            let commandBuffer = commandQueue.commandBuffer()
            if let computePass = pass as? ComputePass {
                let computeCommandEncoder = commandBuffer.computeCommandEncoder()
                computeCommandEncoder.setBuffer(metalState.builtInBuffer, offset: 0, atIndex: 1)
                for invocationObject in computePass.invocations {
                    let invocation = invocationObject as! ComputeInvocation
                    guard let metalComputePipelineState = metalState.computePipelineStates[invocation.state] else {
                        continue
                    }
                    computeCommandEncoder.setComputePipelineState(metalComputePipelineState)
                    for i in 0 ..< invocation.bufferBindings.count {
                        let bufferOptional = (invocation.bufferBindings.objectAtIndex(i) as! BufferBinding).buffer
                        if let buffer = bufferOptional {
                            computeCommandEncoder.setBuffer(metalState.buffers[buffer], offset: 0, atIndex: PreviewController.bufferIndex(i))
                        } else {
                            computeCommandEncoder.setBuffer(nil, offset: 0, atIndex: PreviewController.bufferIndex(i))
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
                renderCommandEncoder.setVertexBuffer(metalState.builtInBuffer, offset: 0, atIndex: 1)
                renderCommandEncoder.setFragmentBuffer(metalState.builtInBuffer, offset: 0, atIndex: 1)
                for invocationObject in renderPass.invocations {
                    let invocation = invocationObject as! RenderInvocation
                    guard let metalRenderPipelineState = metalState.renderPipelineStates[invocation.state] else {
                        continue
                    }
                    renderCommandEncoder.setRenderPipelineState(metalRenderPipelineState)
                    for i in 0 ..< invocation.vertexBufferBindings.count {
                        let bufferOptional = (invocation.vertexBufferBindings.objectAtIndex(i) as! BufferBinding).buffer
                        if let buffer = bufferOptional {
                            renderCommandEncoder.setVertexBuffer(metalState.buffers[buffer], offset: 0, atIndex: PreviewController.bufferIndex(i))
                        } else {
                            renderCommandEncoder.setVertexBuffer(nil, offset: 0, atIndex: PreviewController.bufferIndex(i))
                        }
                    }
                    for i in 0 ..< invocation.fragmentBufferBindings.count {
                        let bufferOptional = (invocation.fragmentBufferBindings.objectAtIndex(i) as! BufferBinding).buffer
                        if let buffer = bufferOptional {
                            renderCommandEncoder.setVertexBuffer(metalState.buffers[buffer], offset: 0, atIndex: PreviewController.bufferIndex(i))
                        } else {
                            renderCommandEncoder.setVertexBuffer(nil, offset: 0, atIndex: PreviewController.bufferIndex(i))
                        }
                    }
                    renderCommandEncoder.drawPrimitives(PreviewController.toMetalPrimitiveType(invocation.primitive), vertexStart: Int(invocation.vertexStart), vertexCount: Int(invocation.vertexCount))
                }
                renderCommandEncoder.endEncoding()
            } else {
                assertionFailure()
            }
            if pass == frame.passes.objectAtIndex(frame.passes.count - 1) as! Pass {
                commandBuffer.addCompletedHandler() {(commandBuffer) in
                    dispatch_async(dispatch_get_main_queue()) {
                        self.lock.unlock()
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