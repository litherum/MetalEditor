//
//  main.swift
//  TestDatabaseWriter
//
//  Created by Litherum on 7/18/15.
//  Copyright © 2015 Litherum. All rights reserved.
//

import CoreData
import Metal

func main() {
    let mom = NSManagedObjectModel(contentsOfURL: NSURL(fileURLWithPath: "/Users/litherum/Build/Products/Debug/Document.momd"))
    guard let managedObjectModel = mom else {
        fatalError()
    }
    let persistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: managedObjectModel)
    let managedObjectContext = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
    managedObjectContext.persistentStoreCoordinator = persistentStoreCoordinator

    let databaseURL = NSURL(fileURLWithPath: "/Users/litherum/Documents/Untitled.xml")
    let fileManager = NSFileManager()
    do {
        try fileManager.removeItemAtURL(databaseURL)
    } catch {
    }

    do {
        try persistentStoreCoordinator.addPersistentStoreWithType(NSXMLStoreType, configuration: nil, URL: databaseURL, options: nil)
    } catch {
        fatalError()
    }

    let library = NSEntityDescription.insertNewObjectForEntityForName("Library", inManagedObjectContext: managedObjectContext) as! Library
    do {
        try library.source = String(contentsOfFile: "/Users/litherum/src/MetalEditor/TestDatabaseWriter/Shaders.metal")
    } catch {
        fatalError()
    }
    
    let buffer = NSEntityDescription.insertNewObjectForEntityForName("Buffer", inManagedObjectContext: managedObjectContext) as! Buffer
    var array: [Float] = [0, 0, 1, 0, 0.5, 1]
    var array2: [Float] = [0, 0, 1, 0.5, 0, 1]
    let data = NSData(bytes: &array, length: array.count * sizeof(Float))
    let data2 = NSData(bytes: &array2, length: array2.count * sizeof(Float))
    buffer.initialData = data
    data2.writeToFile("/Users/litherum/Documents/VertexData", atomically: true)
    buffer.initialLength = nil
    buffer.name = "Buffer"
    buffer.id = 0
    
    let vertexAttribute = NSEntityDescription.insertNewObjectForEntityForName("VertexAttribute", inManagedObjectContext: managedObjectContext) as! VertexAttribute
    vertexAttribute.format = MTLVertexFormat.Float2.rawValue
    vertexAttribute.offset = 0
    vertexAttribute.bufferIndex = 0

    let vertexBufferLayout = NSEntityDescription.insertNewObjectForEntityForName("VertexBufferLayout", inManagedObjectContext: managedObjectContext) as! VertexBufferLayout
    vertexBufferLayout.stepFunction = MTLVertexStepFunction.PerVertex.rawValue
    vertexBufferLayout.stepRate = 1
    vertexBufferLayout.stride = 8

    let colorAttachment = NSEntityDescription.insertNewObjectForEntityForName("RenderPipelineColorAttachment", inManagedObjectContext: managedObjectContext) as! RenderPipelineColorAttachment
    colorAttachment.pixelFormat = nil

    let renderPipelineState = NSEntityDescription.insertNewObjectForEntityForName("RenderPipelineState", inManagedObjectContext: managedObjectContext) as! RenderPipelineState
    renderPipelineState.id = 0
    renderPipelineState.name = "Render State"
    renderPipelineState.vertexFunction = "vertexIdentity"
    renderPipelineState.fragmentFunction = "fragmentRed"
    renderPipelineState.mutableOrderedSetValueForKey("colorAttachments").addObject(colorAttachment)
    renderPipelineState.mutableOrderedSetValueForKey("vertexAttributes").addObject(vertexAttribute)
    renderPipelineState.mutableOrderedSetValueForKey("vertexBufferLayouts").addObject(vertexBufferLayout)
    
    let vertexBufferBinding = NSEntityDescription.insertNewObjectForEntityForName("BufferBinding", inManagedObjectContext: managedObjectContext) as! BufferBinding
    vertexBufferBinding.buffer = buffer

    let renderInvocation = NSEntityDescription.insertNewObjectForEntityForName("RenderInvocation", inManagedObjectContext: managedObjectContext) as! RenderInvocation
    renderInvocation.mutableOrderedSetValueForKey("vertexBufferBindings").addObject(vertexBufferBinding)
    renderInvocation.state = renderPipelineState
    renderInvocation.primitive = MTLPrimitiveType.Triangle.rawValue
    renderInvocation.vertexStart = 0
    renderInvocation.vertexCount = 3

    let renderPass = NSEntityDescription.insertNewObjectForEntityForName("RenderPass", inManagedObjectContext: managedObjectContext) as! RenderPass
    renderPass.mutableOrderedSetValueForKey("invocations").addObject(renderInvocation)

    let bufferBinding = NSEntityDescription.insertNewObjectForEntityForName("BufferBinding", inManagedObjectContext: managedObjectContext) as! BufferBinding
    bufferBinding.buffer = buffer

    let computePipelineState = NSEntityDescription.insertNewObjectForEntityForName("ComputePipelineState", inManagedObjectContext: managedObjectContext) as! ComputePipelineState
    computePipelineState.functionName = "increment"
    computePipelineState.name = "Compute State"
    computePipelineState.id = 0

    let threadgroupsPerGrid = NSEntityDescription.insertNewObjectForEntityForName("Size", inManagedObjectContext: managedObjectContext) as! Size
    threadgroupsPerGrid.width = 1
    threadgroupsPerGrid.height = 1
    threadgroupsPerGrid.depth = 1

    let threadsPerThreadgroup = NSEntityDescription.insertNewObjectForEntityForName("Size", inManagedObjectContext: managedObjectContext) as! Size
    threadsPerThreadgroup.width = array.count
    threadsPerThreadgroup.height = 1
    threadsPerThreadgroup.depth = 1

    let computeInvocation = NSEntityDescription.insertNewObjectForEntityForName("ComputeInvocation", inManagedObjectContext: managedObjectContext) as! ComputeInvocation
    computeInvocation.mutableOrderedSetValueForKey("bufferBindings").addObject(bufferBinding)
    computeInvocation.state = computePipelineState
    computeInvocation.threadgroupsPerGrid = threadgroupsPerGrid
    computeInvocation.threadsPerThreadgroup = threadsPerThreadgroup

    let computePass = NSEntityDescription.insertNewObjectForEntityForName("ComputePass", inManagedObjectContext: managedObjectContext) as! ComputePass
    computePass.mutableOrderedSetValueForKey("invocations").addObject(computeInvocation)

    let frame = NSEntityDescription.insertNewObjectForEntityForName("Frame", inManagedObjectContext: managedObjectContext) as! Frame
    frame.mutableOrderedSetValueForKey("passes").addObject(computePass)
    frame.mutableOrderedSetValueForKey("passes").addObject(renderPass)

    do {
        try managedObjectContext.save()
    } catch {
        fatalError()
    }
}

main()