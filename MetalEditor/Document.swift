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
    func removePass(controller: InvocationsViewController);
}

class Document: NSPersistentDocument, NSTextDelegate, MetalStateDelegate, ModelObserver, PassRemoveObserver {
    @IBOutlet var previewController: PreviewController!
    @IBOutlet var librarySourceView: NSTextView!
    @IBOutlet var buffersUIController: BuffersUIController!
    @IBOutlet var renderStateUIController: RenderStateUIController!
    @IBOutlet var splitView: NSSplitView!
    @IBOutlet var invocationsStackView: NSStackView!
    var device: MTLDevice!
    var commandQueue: MTLCommandQueue!
    var frame: Frame!
    var library: Library!
    var metalState: MetalState!
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
        }
    }

    func addRenderPassView(pass: RenderPass) {
        let controller = InvocationsViewController(nibName: "InvocationSequence", bundle: nil, managedObjectContext: managedObjectContext!, modelObserver: self, removeObserver: self, pass: pass)!
        controller.loadView()
        for i in pass.invocations {
            controller.addRenderInvocationView(i as! RenderInvocation)
        }
        invocationsStackView.addArrangedSubview(controller.view)
        invocationMap[controller] = pass
    }

    func addComputePassView(pass: ComputePass) {
        let controller = InvocationsViewController(nibName: "InvocationSequence", bundle: nil, managedObjectContext: managedObjectContext!, modelObserver: self, removeObserver: self, pass: pass)!
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

        buffersUIController.managedObjectContext = managedObjectContext
        buffersUIController.modelObserver = self
        renderStateUIController.managedObjectContext = managedObjectContext
        renderStateUIController.modelObserver = self

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

    func removePass(controller: InvocationsViewController) {
        frame.mutableOrderedSetValueForKey("passes").removeObject(controller.pass)
        managedObjectContext!.deleteObject(controller.pass)
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
