//
//  RenderStateUIController.swift
//  MetalEditor
//
//  Created by Litherum on 8/2/15.
//  Copyright © 2015 Litherum. All rights reserved.
//

import Cocoa

protocol RenderPipelineStateRemoveObserver: class {
    func removeRenderPipelineState(controller: RenderStateViewController)
}

class RenderStateUIController: NSViewController, RenderPipelineStateRemoveObserver {
    var managedObjectContext: NSManagedObjectContext!
    weak var modelObserver: ModelObserver!
    @IBOutlet var stackView: NSStackView!

    private func numberOfStates() -> Int {
        let fetchRequest = NSFetchRequest(entityName: "RenderPipelineState")
        var error: NSError?
        let result = managedObjectContext.countForFetchRequest(fetchRequest, error: &error)
        assert(error == nil)
        return result
    }

    private func numberOfVertexAttributes() -> Int {
        let fetchRequest = NSFetchRequest(entityName: "VertexAttribute")
        var error: NSError?
        let result = managedObjectContext.countForFetchRequest(fetchRequest, error: &error)
        assert(error == nil)
        return result
    }

    private func numberOfVertexBufferLayouts() -> Int {
        let fetchRequest = NSFetchRequest(entityName: "VertexBufferLayout")
        var error: NSError?
        let result = managedObjectContext.countForFetchRequest(fetchRequest, error: &error)
        assert(error == nil)
        return result
    }

    func populate() {
        let fetchRequest = NSFetchRequest(entityName: "RenderPipelineState")
        do {
            let states = try managedObjectContext!.executeFetchRequest(fetchRequest) as! [RenderPipelineState]
            for state in states {
                addStateView(state)
            }
        } catch {
        }
    }

    func addStateView(renderPipelineState: RenderPipelineState) {
        let controller = RenderStateViewController(nibName: "RenderStateView", bundle: nil, managedObjectContext: managedObjectContext, modelObserver: modelObserver, state: renderPipelineState, removeObserver: self)!
        addChildViewController(controller)
        controller.view.addConstraint(NSLayoutConstraint(item: controller.view, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .Height, multiplier: 1, constant: 600))
        stackView.addArrangedSubview(controller.view)
    }

    @IBAction func add(sender: NSButton) {
        let vertexAttribute = NSEntityDescription.insertNewObjectForEntityForName("VertexAttribute", inManagedObjectContext: managedObjectContext) as! VertexAttribute
        vertexAttribute.index = 0
        vertexAttribute.format = MTLVertexFormat.Float2.rawValue
        vertexAttribute.offset = 0
        vertexAttribute.bufferIndex = 0
        vertexAttribute.id = numberOfVertexAttributes()

        let vertexBufferLayout = NSEntityDescription.insertNewObjectForEntityForName("VertexBufferLayout", inManagedObjectContext: managedObjectContext) as! VertexBufferLayout
        vertexBufferLayout.index = 0
        vertexBufferLayout.stepFunction = MTLVertexStepFunction.PerVertex.rawValue
        vertexBufferLayout.stepRate = 1
        vertexBufferLayout.stride = 8
        vertexBufferLayout.id = numberOfVertexBufferLayouts()

        let colorAttachment = NSEntityDescription.insertNewObjectForEntityForName("RenderPipelineColorAttachment", inManagedObjectContext: managedObjectContext) as! RenderPipelineColorAttachment
        colorAttachment.pixelFormat = nil
        colorAttachment.writeAlpha = true
        colorAttachment.writeRed = true
        colorAttachment.writeGreen = true
        colorAttachment.writeBlue = true
        colorAttachment.blendingEnabled = true
        colorAttachment.alphaBlendOperation = MTLBlendOperation.Add.rawValue
        colorAttachment.rgbBlendOperation = MTLBlendOperation.Add.rawValue
        colorAttachment.destinationAlphaBlendFactor = MTLBlendFactor.Zero.rawValue
        colorAttachment.destinationRGBBlendFactor = MTLBlendFactor.Zero.rawValue
        colorAttachment.sourceAlphaBlendFactor = MTLBlendFactor.One.rawValue
        colorAttachment.sourceRGBBlendFactor = MTLBlendFactor.One.rawValue

        let renderPipelineState = NSEntityDescription.insertNewObjectForEntityForName("RenderPipelineState", inManagedObjectContext: managedObjectContext) as! RenderPipelineState
        renderPipelineState.name = "Render State \(numberOfStates())"
        renderPipelineState.vertexFunction = "vertexIdentity"
        renderPipelineState.fragmentFunction = "fragmentRed"
        renderPipelineState.alphaToCoverageEnabled = false
        renderPipelineState.alphaToOneEnabled = false
        renderPipelineState.rasterizationEnabled = true
        renderPipelineState.inputPrimitiveTopology = MTLPrimitiveTopologyClass.Unspecified.rawValue
        // FIXME: Why do these sets need to start with nonzero size?
        renderPipelineState.mutableOrderedSetValueForKey("colorAttachments").addObject(colorAttachment)
        renderPipelineState.mutableOrderedSetValueForKey("vertexAttributes").addObject(vertexAttribute)
        renderPipelineState.mutableOrderedSetValueForKey("vertexBufferLayouts").addObject(vertexBufferLayout)

        addStateView(renderPipelineState)
        modelObserver.modelDidChange()
    }

    func removeRenderPipelineState(controller: RenderStateViewController) {
        let state = controller.state
        for attachment in state.colorAttachments {
            managedObjectContext.deleteObject(attachment as! NSManagedObject)
        }
        for attribute in state.vertexAttributes {
            managedObjectContext.deleteObject(attribute as! NSManagedObject)
        }
        for layout in state.vertexBufferLayouts {
            managedObjectContext.deleteObject(layout as! NSManagedObject)
        }
        managedObjectContext.deleteObject(state)
        for i in 0 ..< childViewControllers.count {
            if childViewControllers[i] == controller {
                childViewControllers.removeAtIndex(i)
                break
            }
        }
        controller.view.removeFromSuperview()
        modelObserver.modelDidChange()
    }
}