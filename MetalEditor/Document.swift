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
    func removePass(_ controller: InvocationsViewController, pass: Pass)
}

protocol DepthStencilStateRemoveObserver: class {
    func removeDepthStencilState(_ controller: DepthStencilStateViewController)
}

class Document: NSPersistentDocument, NSTextDelegate, MetalStateDelegate, ModelObserver, TextureRemoveObserver, PassRemoveObserver, DepthStencilStateRemoveObserver {
    @IBOutlet var previewController: PreviewController!
    @IBOutlet var librarySourceView: NSTextView!
    @IBOutlet var buffersTableViewDelegate: BuffersTableViewDelegate!
    @IBOutlet var renderStateUIController: RenderStateUIController!
    @IBOutlet var splitView: NSSplitView!
    @IBOutlet var texturesStackView: NSStackView!
    @IBOutlet var depthStencilStateStackView: NSStackView!
    @IBOutlet var invocationsStackView: NSStackView!
    @IBOutlet var sliderValues: SliderValues!
    var device: MTLDevice!
    var commandQueue: MTLCommandQueue!
    var frame: Frame!
    var library: Library!
    var metalState: MetalState!
    var textureInfoViewControllers: Set<TextureInfoViewController> = Set()
    // FIXME: These can just be sets. We have access to the managed objects via the controllers.
    var depthStencilStateMap: [DepthStencilStateViewController : DepthStencilState] = [:]
    var invocationMap: [InvocationsViewController : Pass] = [:]
    
    func setupFrame() {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Frame")
        do {
            let frames = try managedObjectContext!.fetch(fetchRequest) as! [Frame]
            assert(frames.count == 0 || frames.count == 1)
            if frames.count == 1 {
                frame = frames[0]
            }
        } catch {
        }
        
        if frame == nil {
            frame = NSEntityDescription.insertNewObject(forEntityName: "Frame", into: managedObjectContext!) as! Frame
        }
    }
    
    func setupLibrary() {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Library")
        do {
            let libraries = try managedObjectContext!.fetch(fetchRequest) as! [Library]
            assert(libraries.count == 0 || libraries.count == 1)
            if libraries.count == 1 {
                library = libraries[0]
            }
        } catch {
        }
        
        if library == nil {
            library = NSEntityDescription.insertNewObject(forEntityName: "Library", into: managedObjectContext!) as! Library
            library.source = ""
        }
    }

    func addRenderPassView(_ pass: RenderPass) {
        let controller = RenderInvocationsViewController(nibName: "RenderInvocationSequence", bundle: nil, managedObjectContext: managedObjectContext!, modelObserver: self, removeObserver: self, pass: pass)!
        _ = controller.view
        for i in pass.invocations {
            controller.addRenderInvocationView(i as! RenderInvocation)
        }
        invocationsStackView.addArrangedSubview(controller.view)
        invocationMap[controller] = pass
    }

    func addComputePassView(_ pass: ComputePass) {
        let controller = ComputeInvocationsViewController(nibName: "ComputeInvocationSequence", bundle: nil, managedObjectContext: managedObjectContext!, modelObserver: self, removeObserver: self, pass: pass)!
        _ = controller.view
        for i in pass.invocations {
            controller.addComputeInvocationView(i as! ComputeInvocation)
        }
        invocationsStackView.addArrangedSubview(controller.view)
        invocationMap[controller] = pass
    }

    override func windowControllerDidLoadNib(_ aController: NSWindowController) {
        super.windowControllerDidLoadNib(aController)

        guard let device = MTLCreateSystemDefaultDevice() else {
            fatalError()
        }
        self.device = device
        commandQueue = device.makeCommandQueue()

        setupFrame()
        setupLibrary()

        buffersTableViewDelegate.managedObjectContext = managedObjectContext
        buffersTableViewDelegate.modelObserver = self
        renderStateUIController.managedObjectContext = managedObjectContext
        renderStateUIController.modelObserver = self
        renderStateUIController.populate()

        let textureFetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Texture")
        do {
            let textures = try managedObjectContext!.fetch(textureFetchRequest) as! [Texture]
            for texture in textures {
                addTextureView(texture)
            }
        } catch {
        }

        let depthStencilFetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "DepthStencilState")
        do {
            let states = try managedObjectContext!.fetch(depthStencilFetchRequest) as! [DepthStencilState]
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
        librarySourceView.font = CTFontCreateWithName("Courier New" as CFString, 14, nil) // FIXME: Should be able to set this in IB
        
        metalState = MetalState()
        metalState.delegate = self
        modelDidChange()
        
        previewController.initializeWithDevice(device, commandQueue: commandQueue, frame: frame, metalState: metalState)

        assert(windowControllers.count == 1)
        let window = windowControllers[0].window!
        splitView.setPosition(window.frame.width / 2, ofDividerAt: 0)
    }

    func compilationCompleted(_ success: Bool) {
        if !success {
            librarySourceView.backgroundColor = NSColor.red
        } else {
            librarySourceView.backgroundColor = NSColor.white
        }
    }

    func textDidChange(_ notification: Notification) {
        if let source = librarySourceView.string {
            library.source = source
        } else {
            library.source = ""
        }
        modelDidChange()
    }

    func addTextureView(_ texture: Texture) {
        let viewController = TextureInfoViewController(nibName: "TextureInfoView", bundle: nil, modelObserver: self, removeObserver: self, texture: texture, device: device)!
        texturesStackView.addArrangedSubview(viewController.view)
        textureInfoViewControllers.insert(viewController)
    }

    @IBAction func addTexture(_ sender: NSButton) {
        let texture = NSEntityDescription.insertNewObject(forEntityName: "Texture", into: managedObjectContext!) as! Texture
        texture.name = "Texture"
        texture.initialData = nil
        texture.arrayLength = 1
        texture.width = 1
        texture.height = 1
        texture.depth = 1
        texture.mipmapLevelCount = 1
        texture.sampleCount = 1
        texture.textureType =  NSNumber(value: MTLTextureType.type2D.rawValue)
        texture.pixelFormat =  NSNumber(value: MTLPixelFormat.invalid.rawValue)
        addTextureView(texture)
    }

    func remove(_ controller: TextureInfoViewController) {
        textureInfoViewControllers.remove(controller)
        controller.view.removeFromSuperview()
        managedObjectContext!.delete(controller.texture)
        modelDidChange()
    }

    func addDepthStencilStateView(_ depthStencilState: DepthStencilState) {
        let viewController = DepthStencilStateViewController(nibName: "DepthStencilStateView", bundle: nil, managedObjectContext: managedObjectContext!, modelObserver: self, state: depthStencilState, removeObserver: self)!
        depthStencilStateStackView.addArrangedSubview(viewController.view)
        depthStencilStateMap[viewController] = depthStencilState
    }

    @IBAction func addDepthStencilState(_ sender: NSButton) {
        let backFaceStencil = NSEntityDescription.insertNewObject(forEntityName: "StencilState", into: managedObjectContext!) as! StencilState
        backFaceStencil.stencilFailureOperation =  NSNumber(value: MTLStencilOperation.keep.rawValue)
        backFaceStencil.depthFailureOperation =  NSNumber(value: MTLStencilOperation.keep.rawValue)
        backFaceStencil.depthStencilPassOperation =  NSNumber(value: MTLStencilOperation.keep.rawValue)
        backFaceStencil.stencilCompareFunction =  NSNumber(value: MTLCompareFunction.less.rawValue)
        backFaceStencil.readMask = 0xFFFFFF
        backFaceStencil.writeMask = 0xFFFFFF

        let frontFaceStencil = NSEntityDescription.insertNewObject(forEntityName: "StencilState", into: managedObjectContext!) as! StencilState
        frontFaceStencil.stencilFailureOperation =  NSNumber(value: MTLStencilOperation.keep.rawValue)
        frontFaceStencil.depthFailureOperation =  NSNumber(value: MTLStencilOperation.keep.rawValue)
        frontFaceStencil.depthStencilPassOperation =  NSNumber(value: MTLStencilOperation.keep.rawValue)
        frontFaceStencil.stencilCompareFunction =  NSNumber(value: MTLCompareFunction.less.rawValue)
        frontFaceStencil.readMask = 0xFFFFFF
        frontFaceStencil.writeMask = 0xFFFFFF

        let depthStencilState = NSEntityDescription.insertNewObject(forEntityName: "DepthStencilState", into: managedObjectContext!) as! DepthStencilState
        depthStencilState.name = "Depth & Stencil State"
        depthStencilState.depthCompareFunction = NSNumber(value: MTLCompareFunction.always.rawValue)
        depthStencilState.depthWriteEnabled = false
        depthStencilState.backFaceStencil = backFaceStencil
        depthStencilState.frontFaceStencil = frontFaceStencil

        addDepthStencilStateView(depthStencilState)
    }

    func removeDepthStencilState(_ controller: DepthStencilStateViewController) {
        let state = depthStencilStateMap[controller]!
        managedObjectContext!.delete(state.backFaceStencil)
        managedObjectContext!.delete(state.frontFaceStencil)
        managedObjectContext!.delete(state)
        controller.view.removeFromSuperview()
        depthStencilStateMap.removeValue(forKey: controller)
    }

    @IBAction func addRenderPass(_ sender: NSButton) {
        let renderPass = NSEntityDescription.insertNewObject(forEntityName: "RenderPass", into: managedObjectContext!) as! RenderPass
        frame.mutableOrderedSetValue(forKey: "passes").add(renderPass)
        addRenderPassView(renderPass)
        modelDidChange()
    }

    @IBAction func addComputePass(_ sender: NSButton) {
        let computePass = NSEntityDescription.insertNewObject(forEntityName: "ComputePass", into: managedObjectContext!) as! ComputePass
        frame.mutableOrderedSetValue(forKey: "passes").add(computePass)
        addComputePassView(computePass)
        modelDidChange()
    }

    func removePass(_ controller: InvocationsViewController, pass: Pass) {
        frame.mutableOrderedSetValue(forKey: "passes").remove(pass)
        managedObjectContext!.delete(pass)
        controller.view.removeFromSuperview()
        invocationMap.removeValue(forKey: controller)
        modelDidChange()
    }

    func modelDidChange() {
        sliderValues.clear()
        metalState.populate(managedObjectContext!, device: device, view: previewController.metalView)
    }

    func reflection(_ reflection: [MTLArgument]) {
        sliderValues.reflection(reflection)
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
