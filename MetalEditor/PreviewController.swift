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
    var buffer: MTLBuffer!
    let bufferLength = 16
    var bufferLock: NSLock!
    var computePipelineState: MTLComputePipelineState!

    override func viewDidLoad() {
        super.viewDidLoad()
        print("View loaded \(view)")
        guard let device = MTLCreateSystemDefaultDevice() else {
            exit(EXIT_FAILURE)
        }
        self.device = device
        commandQueue = device.newCommandQueue()
        guard let library = device.newDefaultLibrary() else {
            exit(EXIT_FAILURE)
        }

        metalView = view as! MTKView
        metalView.delegate = self
        metalView.device = device

        metalView.enableSetNeedsDisplay = true

        //buffer = device.newBufferWithLength(bufferLength, options: .StorageModeAuto)
        var array = Array<UInt8>(count: bufferLength, repeatedValue: 17)
        buffer = device.newBufferWithBytes(&array, length: bufferLength, options: .StorageModeManaged)
        print("Mode: \(buffer.storageMode.rawValue)")
        bufferLock = NSLock()

        guard let function = library.newFunctionWithName("increment") else {
            exit(EXIT_FAILURE)
        }
        do {
            try computePipelineState = device.newComputePipelineStateWithFunction(function)
        } catch {
            exit(EXIT_FAILURE)
        }
    }

    func view(view: MTKView, willLayoutWithSize size: CGSize) {
    }

    func drawInView(view: MTKView) {
        guard bufferLock.tryLock() else {
            return
        }

        // 1. Compute shader
        let computeCommandBuffer = commandQueue.commandBuffer()
        let computeCommandEncoder = computeCommandBuffer.computeCommandEncoder()
        computeCommandEncoder.label = "Compute command encoder"
        computeCommandEncoder.setComputePipelineState(computePipelineState)
        computeCommandEncoder.setBuffer(buffer, offset: 0, atIndex: 0)
        computeCommandEncoder.dispatchThreadgroups(MTLSize(width: 1, height: 1, depth: 1), threadsPerThreadgroup: MTLSize(width: bufferLength, height: 1, depth: 1))
        computeCommandEncoder.endEncoding()
        computeCommandBuffer.commit()

        // 2. Copy results
        let blitCommandBuffer = commandQueue.commandBuffer()
        let blitCommandEncoder = blitCommandBuffer.blitCommandEncoder()
        blitCommandEncoder.label = "Blit command encoder"
        if buffer.storageMode  == .Managed {
            blitCommandEncoder.synchronizeResource(buffer)
        }
        blitCommandEncoder.endEncoding()
        blitCommandBuffer.addCompletedHandler() {(cmdBuffer) in
            let bufferContents = UnsafeMutablePointer<UInt8>(self.buffer.contents())
            for i in 0 ..< self.bufferLength {
                print("\(bufferContents[i]) ", appendNewline: false)
            }
            print("")
            dispatch_async(dispatch_get_main_queue()) {
                self.bufferLock.unlock()
                // Rather than kicking off another job, we can just wait for the next drawInView
            }
        }
        blitCommandBuffer.commit()

        // 3. Render something
        let renderCommandBuffer = commandQueue.commandBuffer()
        guard let renderPassDescriptor = metalView.currentRenderPassDescriptor else {
            exit(EXIT_FAILURE)
        }

        let renderCommandEncoder = renderCommandBuffer.renderCommandEncoderWithDescriptor(renderPassDescriptor)
        renderCommandEncoder.label = "Render command encoder"
        renderCommandEncoder.endEncoding()

        guard let drawable = metalView.currentDrawable else {
            exit(EXIT_FAILURE)
        }
        renderCommandBuffer.presentDrawable(drawable)
        renderCommandBuffer.commit()
    }
}