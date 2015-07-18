//
//  MetalState.swift
//  MetalEditor
//
//  Created by Litherum on 7/17/15.
//  Copyright © 2015 Litherum. All rights reserved.
//

import Cocoa

class MetalState {
    var buffers: [Buffer: MTLBuffer] = [:]
    var computePipelineStates: [ComputePipelineState: MTLComputePipelineState] = [:]

    func fetchAll(managedObjectContext: NSManagedObjectContext, entityName: String) -> [NSManagedObject] {
        let fetchRequest = NSFetchRequest(entityName: entityName)
        do {
            return try managedObjectContext.executeFetchRequest(fetchRequest) as! [NSManagedObject]
        } catch {
            return []
        }
    }

    func populate(managedObjectContext: NSManagedObjectContext, device: MTLDevice) {
        var library: MTLLibrary!
        var functions: [String: MTLFunction] = [:]
        buffers = [:]
        computePipelineStates = [:]

        let libraries = fetchAll(managedObjectContext, entityName: "Library") as! [Library]
        if libraries.count != 0 {
            do {
                library = try device.newLibraryWithSource(libraries[0].source, options: MTLCompileOptions())
            } catch {
            }
            for functionName in library.functionNames {
                functions[functionName] = library.newFunctionWithName(functionName)
            }
        }

        for buffer in fetchAll(managedObjectContext, entityName: "Buffer") as! [Buffer] {
            if let initialData = buffer.initialData {
                buffers[buffer] = device.newBufferWithBytes(initialData.bytes, length: initialData.length, options: .StorageModePrivate)
            } else {
                buffers[buffer] = device.newBufferWithLength(Int(buffer.initialLength), options: .StorageModePrivate)
            }
        }
        
        for computePipelineState in fetchAll(managedObjectContext, entityName: "ComputePipelineState") as! [ComputePipelineState] {
            guard let function = functions[computePipelineState.functionName] else {
                continue
            }
            let descriptor = MTLComputePipelineDescriptor()
            descriptor.computeFunction = function
            do {
                try computePipelineStates[computePipelineState] = device.newComputePipelineStateWithDescriptor(descriptor, options: MTLPipelineOption(), reflection: nil)
            } catch {
            }
        }
    }
}