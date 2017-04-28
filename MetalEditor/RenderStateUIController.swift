//
//  RenderStateUIController.swift
//  MetalEditor
//
//  Created by Litherum on 8/2/15.
//  Copyright © 2015 Litherum. All rights reserved.
//

import Cocoa

protocol RenderPipelineStateRemoveObserver: class {
    func removeRenderPipelineState(_ controller: RenderStateViewController)
}

class RenderStateUIController: NSViewController, RenderPipelineStateRemoveObserver {
    var managedObjectContext: NSManagedObjectContext!
    weak var modelObserver: ModelObserver!
    @IBOutlet var stackView: NSStackView!

    fileprivate func numberOfStates() -> Int {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "RenderPipelineState")
        
        let result = try! managedObjectContext.count(for: fetchRequest)
        
        return result
    }

    fileprivate func numberOfVertexAttributes() -> Int {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "VertexAttribute")
        
        let result = try! managedObjectContext.count(for: fetchRequest)
        
        return result
    }

    fileprivate func numberOfVertexBufferLayouts() -> Int {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "VertexBufferLayout")
        
        let result = try! managedObjectContext.count(for: fetchRequest)
        
        return result
    }

    func populate() {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "RenderPipelineState")
        do {
            let states = try managedObjectContext!.fetch(fetchRequest) as! [RenderPipelineState]
            for state in states {
                addStateView(state)
            }
        } catch {
        }
    }

    func addStateView(_ renderPipelineState: RenderPipelineState) {
        let controller = RenderStateViewController(nibName: "RenderStateView", bundle: nil, managedObjectContext: managedObjectContext, modelObserver: modelObserver, state: renderPipelineState, removeObserver: self)!
        addChildViewController(controller)
        controller.view.addConstraint(NSLayoutConstraint(item: controller.view, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1, constant: 600))
        stackView.addArrangedSubview(controller.view)
    }

    @IBAction func add(_ sender: NSButton) {
        let vertexAttribute = NSEntityDescription.insertNewObject(forEntityName: "VertexAttribute", into: managedObjectContext) as! VertexAttribute
        vertexAttribute.index = 0
        vertexAttribute.format = NSNumber(value: MTLVertexFormat.float2.rawValue)
        vertexAttribute.offset = 0
        vertexAttribute.bufferIndex = 0
        vertexAttribute.id = NSNumber(value: numberOfVertexAttributes())

        let vertexBufferLayout = NSEntityDescription.insertNewObject(forEntityName: "VertexBufferLayout", into: managedObjectContext) as! VertexBufferLayout
        vertexBufferLayout.index = 0
        vertexBufferLayout.stepFunction = NSNumber(value: MTLVertexStepFunction.perVertex.rawValue)
        vertexBufferLayout.stepRate = 1
        vertexBufferLayout.stride = 8
        vertexBufferLayout.id = NSNumber(value: numberOfVertexBufferLayouts())

        let colorAttachment = NSEntityDescription.insertNewObject(forEntityName: "RenderPipelineColorAttachment", into: managedObjectContext) as! RenderPipelineColorAttachment
        colorAttachment.pixelFormat = nil
        colorAttachment.writeAlpha = true
        colorAttachment.writeRed = true
        colorAttachment.writeGreen = true
        colorAttachment.writeBlue = true
        colorAttachment.blendingEnabled = true
        colorAttachment.alphaBlendOperation = NSNumber(value: MTLBlendOperation.add.rawValue)
        colorAttachment.rgbBlendOperation = NSNumber(value: MTLBlendOperation.add.rawValue)
        colorAttachment.destinationAlphaBlendFactor = NSNumber(value: MTLBlendFactor.zero.rawValue)
        colorAttachment.destinationRGBBlendFactor = NSNumber(value: MTLBlendFactor.zero.rawValue)
        colorAttachment.sourceAlphaBlendFactor = NSNumber(value: MTLBlendFactor.one.rawValue)
        colorAttachment.sourceRGBBlendFactor = NSNumber(value: MTLBlendFactor.one.rawValue)

        let renderPipelineState = NSEntityDescription.insertNewObject(forEntityName: "RenderPipelineState", into: managedObjectContext) as! RenderPipelineState
        renderPipelineState.name = "Render State \(numberOfStates())"
        renderPipelineState.vertexFunction = "vertexIdentity"
        renderPipelineState.fragmentFunction = "fragmentRed"
        renderPipelineState.alphaToCoverageEnabled = false
        renderPipelineState.alphaToOneEnabled = false
        renderPipelineState.rasterizationEnabled = true
        renderPipelineState.inputPrimitiveTopology = NSNumber(value: MTLPrimitiveTopologyClass.unspecified.rawValue)
        // FIXME: Why do these sets need to start with nonzero size?
        renderPipelineState.mutableOrderedSetValue(forKey: "colorAttachments").add(colorAttachment)
        renderPipelineState.mutableOrderedSetValue(forKey: "vertexAttributes").add(vertexAttribute)
        renderPipelineState.mutableOrderedSetValue(forKey: "vertexBufferLayouts").add(vertexBufferLayout)

        addStateView(renderPipelineState)
        modelObserver.modelDidChange()
    }

    func removeRenderPipelineState(_ controller: RenderStateViewController) {
        let state = controller.state
        for attachment in (state?.colorAttachments)! {
            managedObjectContext.delete(attachment as! NSManagedObject)
        }
        for attribute in (state?.vertexAttributes)! {
            managedObjectContext.delete(attribute as! NSManagedObject)
        }
        for layout in (state?.vertexBufferLayouts)! {
            managedObjectContext.delete(layout as! NSManagedObject)
        }
        managedObjectContext.delete(state!)
        for i in 0 ..< childViewControllers.count {
            if childViewControllers[i] == controller {
                childViewControllers.remove(at: i)
                break
            }
        }
        controller.view.removeFromSuperview()
        modelObserver.modelDidChange()
    }
}
