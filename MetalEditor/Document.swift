//
//  Document.swift
//  MetalEditor
//
//  Created by Litherum on 7/16/15.
//  Copyright © 2015 Litherum. All rights reserved.
//

import Cocoa

protocol ModelObserver: class {
    func modelDidChange()
}

protocol PassRemoveObserver: class {
    func removePass(controller: InvocationsViewController, pass: Pass)
}

protocol DepthStencilStateRemoveObserver: class {
    func removeDepthStencilState(controller: DepthStencilStateViewController)
}

class Document: NSPersistentDocument, NSTextDelegate, MetalStateDelegate, ModelObserver, PassRemoveObserver, DepthStencilStateRemoveObserver {
    @IBOutlet var previewController: PreviewController!
    @IBOutlet var librarySourceView: NSTextView!
    @IBOutlet var buffersTableViewDelegate: BuffersTableViewDelegate!
    @IBOutlet var texturesTableViewDelegate: TexturesTableViewDelegate!
    @IBOutlet var renderStateUIController: RenderStateUIController!
    @IBOutlet var splitView: NSSplitView!
    @IBOutlet var depthStencilStateStackView: NSStackView!
    @IBOutlet var invocationsStackView: NSStackView!
    var device: MTLDevice!
    var commandQueue: MTLCommandQueue!
    var frame: Frame!
    var library: Library!
    var metalState: MetalState!
    // FIXME: These can just be sets. We have access to the managed objects via the controllers.
    var depthStencilStateMap: [DepthStencilStateViewController : DepthStencilState] = [:]
    var invocationMap: [InvocationsViewController : Pass] = [:]
    
    func setupFrame() {
        let fetchRequest = NSFetchRequest(entityName: "Frame")
        do {
            let frames = try managedObjectContext!.executeFetchRequest(fetchRequest) as! [Frame]
            assert(frames.count == 0 || frames.count == 1)
            if frames.count == 1 {
                frame = frames[0]
            }
        } catch {
        }
        
        if frame == nil {
            frame = NSEntityDescription.insertNewObjectForEntityForName("Frame", inManagedObjectContext: managedObjectContext!) as! Frame
        }
    }
    
    func setupLibrary() {
        let fetchRequest = NSFetchRequest(entityName: "Library")
        do {
            let libraries = try managedObjectContext!.executeFetchRequest(fetchRequest) as! [Library]
            assert(libraries.count == 0 || libraries.count == 1)
            if libraries.count == 1 {
                library = libraries[0]
            }
        } catch {
        }
        
        if library == nil {
            library = NSEntityDescription.insertNewObjectForEntityForName("Library", inManagedObjectContext: managedObjectContext!) as! Library
            library.source = ""
        }
    }

    func addRenderPassView(pass: RenderPass) {
        let controller = RenderInvocationsViewController(nibName: "RenderInvocationSequence", bundle: nil, managedObjectContext: managedObjectContext!, modelObserver: self, removeObserver: self, pass: pass)!
        controller.loadView()
        for i in pass.invocations {
            controller.addRenderInvocationView(i as! RenderInvocation)
        }
        invocationsStackView.addArrangedSubview(controller.view)
        invocationMap[controller] = pass
    }

    func addComputePassView(pass: ComputePass) {
        let controller = ComputeInvocationsViewController(nibName: "ComputeInvocationSequence", bundle: nil, managedObjectContext: managedObjectContext!, modelObserver: self, removeObserver: self, pass: pass)!
        controller.loadView()
        for i in pass.invocations {
            controller.addComputeInvocationView(i as! ComputeInvocation)
        }
        invocationsStackView.addArrangedSubview(controller.view)
        invocationMap[controller] = pass
    }

    override func windowControllerDidLoadNib(aController: NSWindowController) {
        super.windowControllerDidLoadNib(aController)

        guard let device = MTLCreateSystemDefaultDevice() else {
            exit(EXIT_FAILURE)
        }
        self.device = device
        commandQueue = device.newCommandQueue()

        setupFrame()
        setupLibrary()

        buffersTableViewDelegate.managedObjectContext = managedObjectContext
        buffersTableViewDelegate.modelObserver = self
        texturesTableViewDelegate.managedObjectContext = managedObjectContext
        texturesTableViewDelegate.modelObserver = self
        texturesTableViewDelegate.device = device
        renderStateUIController.managedObjectContext = managedObjectContext
        renderStateUIController.modelObserver = self

        let fetchRequest = NSFetchRequest(entityName: "DepthStencilState")
        do {
            let states = try managedObjectContext!.executeFetchRequest(fetchRequest) as! [DepthStencilState]
            for state in states {
                addDepthStencilStateView(state)
            }
        } catch {
        }

        for p in frame.passes {
            if let pass = p as? ComputePass {
                addComputePassView(pass)
            } else {
                addRenderPassView(p as! RenderPass)
            }
        }

        librarySourceView.string = library.source
        librarySourceView.font = CTFontCreateWithName("Courier New", 14, nil) // FIXME: Should be able to set this in IB
        
        metalState = MetalState()
        metalState.delegate = self
        modelDidChange()
        
        previewController.initializeWithDevice(device, commandQueue: commandQueue, frame: frame, metalState: metalState)

        assert(windowControllers.count == 1)
        let window = windowControllers[0].window!
        splitView.setPosition(window.frame.width / 2, ofDividerAtIndex: 0)
    }

    func compilationCompleted(success: Bool) {
        if !success {
            librarySourceView.backgroundColor = NSColor.redColor()
        } else {
            librarySourceView.backgroundColor = NSColor.whiteColor()
        }
    }

    func textDidChange(notification: NSNotification) {
        if let source = librarySourceView.string {
            library.source = source
        } else {
            library.source = ""
        }
        modelDidChange()
    }

    func addDepthStencilStateView(depthStencilState: DepthStencilState) {
        let viewController = DepthStencilStateViewController(nibName: "DepthStencilStateView", bundle: nil, managedObjectContext: managedObjectContext!, modelObserver: self, state: depthStencilState, removeObserver: self)!
        depthStencilStateStackView.addArrangedSubview(viewController.view)
        depthStencilStateMap[viewController] = depthStencilState
    }

    @IBAction func addDepthStencilState(sender: NSButton) {
        let backFaceStencil = NSEntityDescription.insertNewObjectForEntityForName("StencilState", inManagedObjectContext: managedObjectContext!) as! StencilState
        backFaceStencil.stencilFailureOperation = MTLStencilOperation.Keep.rawValue
        backFaceStencil.depthFailureOperation = MTLStencilOperation.Keep.rawValue
        backFaceStencil.depthStencilPassOperation = MTLStencilOperation.Keep.rawValue
        backFaceStencil.stencilCompareFunction = MTLCompareFunction.Less.rawValue
        backFaceStencil.readMask = 0xFFFFFF
        backFaceStencil.writeMask = 0xFFFFFF

        let frontFaceStencil = NSEntityDescription.insertNewObjectForEntityForName("StencilState", inManagedObjectContext: managedObjectContext!) as! StencilState
        frontFaceStencil.stencilFailureOperation = MTLStencilOperation.Keep.rawValue
        frontFaceStencil.depthFailureOperation = MTLStencilOperation.Keep.rawValue
        frontFaceStencil.depthStencilPassOperation = MTLStencilOperation.Keep.rawValue
        frontFaceStencil.stencilCompareFunction = MTLCompareFunction.Less.rawValue
        frontFaceStencil.readMask = 0xFFFFFF
        frontFaceStencil.writeMask = 0xFFFFFF

        let depthStencilState = NSEntityDescription.insertNewObjectForEntityForName("DepthStencilState", inManagedObjectContext: managedObjectContext!) as! DepthStencilState
        depthStencilState.name = "Depth & Stencil State"
        depthStencilState.depthCompareFunction = MTLCompareFunction.Always.rawValue
        depthStencilState.depthWriteEnabled = false
        depthStencilState.backFaceStencil = backFaceStencil
        depthStencilState.frontFaceStencil = frontFaceStencil

        addDepthStencilStateView(depthStencilState)
    }

    func removeDepthStencilState(controller: DepthStencilStateViewController) {
        let state = depthStencilStateMap[controller]!
        managedObjectContext!.deleteObject(state.backFaceStencil)
        managedObjectContext!.deleteObject(state.frontFaceStencil)
        managedObjectContext!.deleteObject(state)
        depthStencilStateStackView.removeArrangedSubview(controller.view)
        depthStencilStateMap.removeValueForKey(controller)
    }

    @IBAction func addRenderPass(sender: NSButton) {
        let renderPass = NSEntityDescription.insertNewObjectForEntityForName("RenderPass", inManagedObjectContext: managedObjectContext!) as! RenderPass
        frame.mutableOrderedSetValueForKey("passes").addObject(renderPass)
        addRenderPassView(renderPass)
        modelDidChange()
    }

    @IBAction func addComputePass(sender: NSButton) {
        let computePass = NSEntityDescription.insertNewObjectForEntityForName("ComputePass", inManagedObjectContext: managedObjectContext!) as! ComputePass
        frame.mutableOrderedSetValueForKey("passes").addObject(computePass)
        addComputePassView(computePass)
        modelDidChange()
    }

    func removePass(controller: InvocationsViewController, pass: Pass) {
        frame.mutableOrderedSetValueForKey("passes").removeObject(pass)
        managedObjectContext!.deleteObject(pass)
        controller.view.removeFromSuperview()
        invocationMap.removeValueForKey(controller)
        modelDidChange()
    }

    func modelDidChange() {
        metalState.populate(managedObjectContext!, device: device, view: previewController.metalView)
    }

    override class func autosavesInPlace() -> Bool {
        return true
    }

    override var windowNibName: String? {
        // Returns the nib file name of the document
        // If you need to use a subclass of NSWindowController or if your document supports multiple NSWindowControllers, you should remove this property and override -makeWindowControllers instead.
        return "Document"
    }
}
