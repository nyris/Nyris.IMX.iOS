//
//  CameraManager.swift
//  NyrisSDK
//
//  Created by MOSTEFAOUI Anas on 24/07/2017.
//  Copyright © 2017 nyris. All rights reserved.
//

import Foundation
import AVFoundation
import UIKit

/// Session setup result enum
///
/// - authorized: authorized
/// - notAuthorized: notAuthorized
/// - configurationFailed: configurationFailed
/// - none: none
public enum SessionSetupResult {
    case authorized
    case notAuthorized
    case configurationFailed
    case none
}

public protocol CameraAuthorizationDelegate : AnyObject {
    func didChangeAuthorization(cameraManager:CameraManager, authorization:SessionSetupResult)
}

public class CameraManager : NSObject {
    
    fileprivate let sessionQueue:DispatchQueue = DispatchQueue(label: "session queue",
                                                               attributes: [],
                                                               target: nil)
    
    fileprivate var videoFramePixelBuffer: CMSampleBuffer?
    fileprivate var captureSession:AVCaptureSession? = AVCaptureSession()
    fileprivate var scannerOutput:AVCaptureMetadataOutput?
    fileprivate var videoPreviewLayer:AVCaptureVideoPreviewLayer?
    fileprivate var focusTapGesture:UITapGestureRecognizer?
    fileprivate weak var displayView:UIView?
    fileprivate var circleShape:CAShapeLayer?
    fileprivate let videoOutput = AVCaptureVideoDataOutput()
    
    public weak var authorizationDelegate:CameraAuthorizationDelegate?
    // image settings
    public let stillImageOutput:AVCaptureStillImageOutput = AVCaptureStillImageOutput()
    
    /// Last changed orientation
    fileprivate var orientation: CameraOrientation = CameraOrientation()
    
    /// Variable to store result of capture session setup
    fileprivate var setupResult : SessionSetupResult {
        didSet {
            DispatchQueue.main.async {
                self.authorizationDelegate?.didChangeAuthorization(cameraManager: self, authorization: self.permission)
            }
        }
    }
    
    /// public permission
    public var permission:SessionSetupResult {
        return self.setupResult
    }
    
    public weak var codebarScannerDelegate:BarcodeScannerDelegate?
    public private(set) var configObject:CameraConfiguration
    
    public fileprivate(set) var isTorchActive:Bool = false
    public fileprivate(set) var isLocked: Bool {
        didSet {
            self.codebarScannerDelegate?.lockDidChange(newValue:self.isLocked)
        }
    }
    
    public var isTapToFocusActive : Bool {
        get {
            return self.configObject.allowTapToFocus
        }
        set(value) {
            self.configObject.allowTapToFocus = value
        }
    }
    
    public var shouldUseDeviceOrientation: Bool = false {
        didSet {
            orientation.shouldUseDeviceOrientation = shouldUseDeviceOrientation
        }
    }
    
    public var isRunning : Bool {
        return self.captureSession?.isRunning ?? false
    }
    
    public init(configuration:CameraConfiguration) {
        self.isLocked = false
        self.configObject = configuration
        let device = AVCaptureDevice.default(for: AVMediaType.video)
        
        let authorization = AVCaptureDevice.authorizationStatus(for: AVMediaType.video)
        self.setupResult = authorization == .authorized ? .authorized : .none
        
        try? device?.lockForConfiguration()
        device?.focusMode = self.configObject.focusMode
        device?.unlockForConfiguration()
        
    }
    
    private override init() {
        fatalError("call init(configuration:)")
    }
    
    deinit {
        self.unsubscribeFromDeviceOrientation()
        NotificationCenter.default.removeObserver(self)
    }
    
    /// prepare the manager to handle device camera, and scanner
    public func setup(useDeviceRotation:Bool = false) {
        
        self.shouldUseDeviceOrientation = useDeviceRotation
        guard let captureDevice = AVCaptureDevice.default(for: AVMediaType.video) else {
            fatalError("Default capture device is not available")
        }
        
        guard let videoInput = try? AVCaptureDeviceInput(device: captureDevice) else {
            fatalError("Error: could not create AVCaptureDeviceInput")
        }
        
        guard let captureSession = self.captureSession else {
            fatalError("Invalid Capture session")
        }
        
        if self.shouldUseDeviceOrientation {
            self.subscribeToDeviceOrientation()
        }
        
        captureSession.beginConfiguration()
        // Set the input device on the capture session.
        captureSession.addInput(videoInput)
        
        // allow picture saving
        self.stillImageOutput.outputSettings = [AVVideoCodecKey:AVVideoCodecType.jpeg]
        
        if captureSession.canAddOutput(self.stillImageOutput) {
            captureSession.addOutput(self.stillImageOutput)
        }
        
        if captureSession.canSetSessionPreset(AVCaptureSession.Preset(rawValue: self.configObject.preset.foundationPreset())) {
            captureSession.sessionPreset = AVCaptureSession.Preset(rawValue: self.configObject.preset.foundationPreset())
        } else {
            fatalError("can not set \(self.configObject.preset.foundationPreset()) as preset")
        }
        
        let settings: [String : Any] = [
            kCVPixelBufferPixelFormatTypeKey as String: NSNumber(value: kCVPixelFormatType_32BGRA)
            ]
        
        videoOutput.videoSettings = settings
        videoOutput.alwaysDiscardsLateVideoFrames = true
        videoOutput.setSampleBufferDelegate(self, queue: sessionQueue)
        if captureSession.canAddOutput(videoOutput) {
            captureSession.addOutput(videoOutput)
        }
        
        videoOutput.setSampleBufferDelegate(self, queue: sessionQueue)
        videoOutput.connection(with: AVMediaType.video)?.videoOrientation =  self.orientation.getVideoOrientation() ??  .portrait
        
        captureSession.commitConfiguration()
        // tap to focus
        self.focusTapGesture = UITapGestureRecognizer(target: self,
                                                      action: #selector(CameraManager.tapToFocusAction(sender:)))
        
        // setup scanner
        if self.configObject.allowBarcodeScan == true {
            self.setupScanner()
        }
    }
    
    /// setup scanner
    private func setupScanner() {
        assert(self.captureSession != nil, "Setup must be called before capture setup")
        
        let captureMetadataOutput = AVCaptureMetadataOutput()
        self.captureSession?.addOutput(captureMetadataOutput)
        
        // Set delegate and use the default dispatch queue to execute the call back
        captureMetadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
        
        if self.configObject.metadata.isEmpty {
            captureMetadataOutput.metadataObjectTypes  = captureMetadataOutput.availableMetadataObjectTypes
        } else {
            captureMetadataOutput.metadataObjectTypes = self.configObject.metadata
        }
        
        self.scannerOutput = captureMetadataOutput
    }
    
    private func subscribeToDeviceOrientation() {
        if shouldUseDeviceOrientation {
            NotificationCenter.default.addObserver(self,
                                                   selector: #selector(CameraManager.deviceOrientationDidChange),
                                                   name: UIDevice.orientationDidChangeNotification,
                                                   object: nil)
            orientation.start()
        }
    }
    
    private func updatePreviewLayer(layer: AVCaptureConnection, orientation: AVCaptureVideoOrientation) {
        guard let bounds = self.displayView?.bounds else {
            return
        }
        layer.videoOrientation = orientation
        videoPreviewLayer?.frame = bounds
    }
    
    @objc public func deviceOrientationDidChange() {
        guard let connection =  self.videoPreviewLayer?.connection, connection.isVideoOrientationSupported == true else {
            return
        }
        
        videoOutput.connection(with: AVMediaType.video)?.videoOrientation =  self.orientation.getVideoOrientation() ??  .portrait
        
        let orientation: UIDeviceOrientation = UIDevice.current.orientation
        let previewLayerConnection : AVCaptureConnection = connection
        switch orientation {
        case .portrait:
            updatePreviewLayer(layer: previewLayerConnection, orientation: .portrait)
        case .landscapeRight:
            updatePreviewLayer(layer: previewLayerConnection, orientation: .landscapeLeft)
        case .landscapeLeft:
            updatePreviewLayer(layer: previewLayerConnection, orientation: .landscapeRight)
        case .portraitUpsideDown:
            updatePreviewLayer(layer: previewLayerConnection, orientation: .portraitUpsideDown)
        default:
            updatePreviewLayer(layer: previewLayerConnection, orientation: .portrait)
        }
    }
    
    private func unsubscribeFromDeviceOrientation() {
        if shouldUseDeviceOrientation {
            orientation.stop()
        }
    }
    
    /// unlock the camera manager to be able to scan again
    public func unlock() {
        self.isLocked = false
    }
    
    /// reset torch light and locking systems
    public func reset() {
        self.isTorchActive = false
        self.isLocked = false
    }
    
    public func updatePermission() {
        switch AVCaptureDevice.authorizationStatus(for: AVMediaType.video) {
        case .authorized:
            self.setupResult = .authorized
        case .notDetermined, .denied:
            AVCaptureDevice.requestAccess(for: AVMediaType.video, completionHandler: { [unowned self] granted in
                if granted == false {
                    self.setupResult = .notAuthorized
                } else {
                    self.setupResult = .authorized
                }
            })
        default:
            setupResult = .notAuthorized
        }
    }
    
    /// display captured video stream on a view
    public func display(on view:UIView, scannerFrame:CGRect? = nil) {
        
        guard let validCaptureSession = self.captureSession else {
            fatalError("Setup must be called before displaying a preview")
        }
        
        DispatchQueue.main.async {
            
            self.displayView = view
            // Initialize the video preview layer and add it as a sublayer to the viewPreview view's layer.
            self.videoPreviewLayer = AVCaptureVideoPreviewLayer(session: validCaptureSession)
            // otherwise the final saved image will be wrongly rotated
            if let videoPreviewLayer = self.videoPreviewLayer, videoPreviewLayer.connection?.isVideoOrientationSupported == true {
                self.videoPreviewLayer?.connection?.videoOrientation = self.orientation.getPreviewLayerOrientation()
            }
            self.videoPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
            self.videoPreviewLayer?.frame = view.layer.bounds
            
            if let videoLayer = self.videoPreviewLayer {
                view.layer.addSublayer(videoLayer)
            }
            
            // tap to focus handler
            if let focusGesture = self.focusTapGesture {
                view.isUserInteractionEnabled = true
                view.addGestureRecognizer(focusGesture)
            }
            
            if validCaptureSession.isRunning == false {
                validCaptureSession.startRunning()
            }
            
            // reduce the scaning area to improve performance
            if let scanZone = scannerFrame {
                if let frame = self.videoPreviewLayer?.metadataOutputRectConverted(fromLayerRect: scanZone) {
                    self.scannerOutput?.rectOfInterest = frame
                }
            }
            
        }
    }
    
    public func start() {
        self.captureSession?.startRunning()
    }
    
    public func stop() {
        self.captureSession?.stopRunning()
    }
    
    @objc public func tapToFocusAction(sender:UITapGestureRecognizer) {
        guard let view = self.displayView, let previewLayer = self.videoPreviewLayer else {
            return
        }
        
        let touchPoint = sender.location(ofTouch: 0, in: view)
        let focusPoint = previewLayer.captureDevicePointConverted(fromLayerPoint: touchPoint)
        
        // clear previous shapes
        self.circleShape?.removeFromSuperlayer()
        self.addFocusCircle(view: view, point: touchPoint)
        
        if let device = AVCaptureDevice.default(for: AVMediaType.video) {
            do {
                try device.lockForConfiguration()
                if device.isFocusPointOfInterestSupported {
                    device.focusPointOfInterest = focusPoint
                    device.focusMode = self.configObject.focusMode
                }
                if device.isExposurePointOfInterestSupported {
                    device.exposurePointOfInterest = focusPoint
                    device.exposureMode = AVCaptureDevice.ExposureMode.autoExpose
                }
                device.unlockForConfiguration()
                self.codebarScannerDelegate?.didTapFocus()
                
            } catch {
                debugPrint(error.localizedDescription)
            }
        }
    }
    
    public func addFocusCircle(view:UIView, point:CGPoint) {
        
        let circle = self.generateFocusCircle(at: point)
        circle.opacity = 0
        view.layer.addSublayer(circle)
        self.circleShape = circle
        
        CATransaction.begin()
        let fadeAnimator = CABasicAnimation(keyPath: "opacity")
        fadeAnimator.fromValue = 1
        fadeAnimator.toValue   = 0
        fadeAnimator.duration  = 0.5
        fadeAnimator.isRemovedOnCompletion = true
        
        // Callback function
        CATransaction.setCompletionBlock {
            self.circleShape?.opacity = 0
            self.circleShape?.removeFromSuperlayer()
        }
        
        self.circleShape?.add(fadeAnimator, forKey: "opacity")
        CATransaction.commit()
    }
    
    private func generateFocusCircle(at point:CGPoint) -> CAShapeLayer {
        let circlePath = UIBezierPath(arcCenter: CGPoint(x: point.x, y: point.y),
                                      radius: 40,
                                      startAngle: 0,
                                      endAngle:CGFloat(Double.pi * 2),
                                      clockwise: true)
        
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = circlePath.cgPath
        
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.strokeColor = UIColor.white.cgColor
        shapeLayer.lineWidth = 3.0
        return shapeLayer
    }
}

extension CameraManager : AVCaptureMetadataOutputObjectsDelegate {
    
    public func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        guard self.isLocked == false  else {
            print(self.isLocked)
            debugPrint("capture is locked, data will be ignored")
            return
        }
        
        guard metadataObjects.isEmpty == false else { return }
        
        guard let firstCode = metadataObjects.first as? AVMetadataMachineReadableCodeObject,
            let code = firstCode.stringValue, self.configObject.metadata.contains(firstCode.type) else {
                return
        }
        
        // lock the capture if the capture mode is set once
        if self.configObject.captureMode == .once {
            self.isLocked = true
        }
        
        // capture the data
        self.codebarScannerDelegate?.didCaptureCode(code: code, type: firstCode.type.rawValue)
    }
}

/// Torch logic
extension CameraManager {
    
    public func toggleTorch() {
        self.isTorchActive = !self.isTorchActive
        self.enableTorch(isOn: self.isTorchActive)
    }
    
    public func enableTorch(isOn: Bool) {
        guard let device = AVCaptureDevice.default(for: AVMediaType.video) else {
            return
        }
        
        if device.hasTorch {
            do {
                try device.lockForConfiguration()
                
                if isOn == true {
                    device.torchMode = .on
                } else {
                    device.torchMode = .off
                }
                
                device.unlockForConfiguration()
            } catch {
                print("Torch could not be used")
            }
        } else {
            print("Torch is not available")
        }
    }
}

// picture capture
extension CameraManager {
    
    private func takeScreenshoot() -> UIImage? {
        guard let sampleBuffer = self.videoFramePixelBuffer ,
            let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer),
            let bounds = self.displayView?.bounds else {
            return nil
        }
        
        UIGraphicsBeginImageContextWithOptions(bounds.size, false, UIScreen.main.scale)
        
        // convert video frame buffer to Image
        // to avoid creating a new UIView just for screenshot, and to avoid nil exception when moving views to a different UIView.
        let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
        let preview = UIImage(ciImage: ciImage)
        
        let mainView = UIView(frame: bounds)
        let imageView = UIImageView(frame: bounds)
        imageView.image = preview
        
        mainView.addSubview(imageView)
        mainView.drawHierarchy(in: bounds, afterScreenUpdates: true)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        imageView.removeFromSuperview()
        videoFramePixelBuffer = nil
        return image
    }
    
    /// Take a picture from camera video stream
    ///
    /// - Parameter completion: resizedImage, originalImage
    public func takePicture(completion:@escaping (_ resizedImage:UIImage?, _ originalImage:UIImage?) -> Void) {
        
        guard let screenshot = takeScreenshoot() else {
            completion(nil, nil)
            return
        }
        let finalImage = ImageHelper.resizeWithRatio(
            image: screenshot,
            size: CGSize(width: 1024, height: 1024))
        completion(finalImage, screenshot)
    }
    
    // source: SwiftyCam: SwiftyCamViewController.swift
    // link : https://github.com/Awalz/SwiftyCam
    /**
     Returns a UIImage from Image Data.
     - Parameter imageData: Image Data returned from capturing photo from the capture session.
     - Returns: UIImage from the image data, adjusted for proper orientation.
     */
    fileprivate func processPhoto(_ imageData: Data) -> UIImage? {
        _ = self.configObject.shouldUseDeviceOrientation
        guard let dataProvider = CGDataProvider(data: imageData as CFData) else {
            return nil
        }
        guard let cgImageRef = CGImage(jpegDataProviderSource: dataProvider,
                                       decode: nil,
                                       shouldInterpolate: true,
                                       intent: CGColorRenderingIntent.defaultIntent) else {
            return nil
        }
        
        // Set proper orientation for photo
        // If camera is currently set to front camera, flip image
        let image = UIImage(cgImage: cgImageRef, scale: 1.0, orientation: self.orientation.getImageOrientation())

        return image
    }
    
    private func cropToPreviewLayer(originalImage: UIImage) -> UIImage? {
        
        guard let previewLayer = self.videoPreviewLayer,
            let cgImage = originalImage.cgImage else {
            return nil
        }
        
        let outputRect = previewLayer.metadataOutputRectConverted(fromLayerRect: previewLayer.bounds)
        
        let width = CGFloat(cgImage.width)
        let height = CGFloat(cgImage.height)
        let cropRect = CGRect(x: outputRect.origin.x * width,
                              y: outputRect.origin.y * height,
                              width: outputRect.size.width * width,
                              height: outputRect.size.height * height)
        
        guard let croppedImageCgi = cgImage.cropping(to: cropRect) else {
            return nil
        }
        
        let croppedUIImage = UIImage(cgImage: croppedImageCgi, scale: 1.0, orientation: originalImage.imageOrientation)
        
        return croppedUIImage
    }
}

extension CameraManager : AVCaptureVideoDataOutputSampleBufferDelegate {
    public func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        self.videoFramePixelBuffer = sampleBuffer
    }
    
    public func captureOutput(_ output: AVCaptureOutput, didDrop sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
    }
}
