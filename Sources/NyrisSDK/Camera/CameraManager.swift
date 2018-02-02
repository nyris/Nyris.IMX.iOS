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

public enum SessionSetupResult {
    case authorized
    case notAuthorized
    case configurationFailed
    case none
}

public protocol CameraAuthorizationDelegate : class {
    func didChangeAuthorization(cameraManager:CameraManager, authorization:SessionSetupResult)
}

public class CameraManager : NSObject {
    
    fileprivate let sessionQueue:DispatchQueue = DispatchQueue(label: "session queue",
                                                               attributes: [],
                                                               target: nil)
    
    fileprivate var captureSession:AVCaptureSession?
    fileprivate var scannerOutput:AVCaptureMetadataOutput?
    fileprivate var videoPreviewLayer:AVCaptureVideoPreviewLayer?
    fileprivate var focusTapGesture:UITapGestureRecognizer?
    fileprivate weak var displayView:UIView?
    fileprivate var circleShape:CAShapeLayer?
    
    public weak var authorizationDelegate:CameraAuthorizationDelegate?
    // image settings
    public let stillImageOutput:AVCaptureStillImageOutput = AVCaptureStillImageOutput()
    
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
    
    public weak var codebarScannerDelegate:CodebarScannerDelegate?
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
    /// prepare the manager to handle device camera, and scanner
    public func setup() {
        
        // sessionQueue.async { [unowned self] in
        guard let captureDevice = AVCaptureDevice.default(for: AVMediaType.video) else {
            fatalError("Default capture device is not available")
        }
        
        do {
            // Get an instance of the AVCaptureDeviceInput class using the previous device object.
            let input = try AVCaptureDeviceInput(device: captureDevice)
            
            // Initialize the captureSession object.
            self.captureSession = AVCaptureSession()
            
            guard let captureSession = self.captureSession else {
                return
            }
            
            // Set the input device on the capture session.
            captureSession.addInput(input)
            
            // allow picture saving
            self.stillImageOutput.outputSettings = [AVVideoCodecKey:AVVideoCodecJPEG]
            
            if captureSession.canAddOutput(self.stillImageOutput) {
                captureSession.addOutput(self.stillImageOutput)
            }
            
            if captureSession.canSetSessionPreset(AVCaptureSession.Preset(rawValue: self.configObject.preset.foundationPreset())) {
                captureSession.sessionPreset = AVCaptureSession.Preset(rawValue: self.configObject.preset.foundationPreset())
            } else {
                fatalError("can not set \(self.configObject.preset.foundationPreset()) as preset")
            }
            
            // tap to focus
            self.focusTapGesture = UITapGestureRecognizer(target: self,
                                                          action: #selector(CameraManager.tapToFocusAction(sender:)))
            
            // setup scanner
            if self.configObject.allowBarcodeScan == true {
                self.setupScanner()
            }
            
        } catch {
            // If any error occurs, simply print it out and don't continue any more.
            print(error)
            return
        }
        // }
    }
    
    /// setup scanner
    private func setupScanner() {
        assert(self.captureSession != nil, "Setup must be called before capture setup")
        
        let captureMetadataOutput = AVCaptureMetadataOutput()
        self.captureSession?.addOutput(captureMetadataOutput)
        
        // Set delegate and use the default dispatch queue to execute the call back
        captureMetadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
        captureMetadataOutput.metadataObjectTypes =
            captureMetadataOutput.availableMetadataObjectTypes
        
        self.scannerOutput = captureMetadataOutput
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
            fatalError("Setup must be called befor displaying a preview")
        }
        
        DispatchQueue.main.async {
            
            self.displayView = view
            // Initialize the video preview layer and add it as a sublayer to the viewPreview view's layer.
            self.videoPreviewLayer = AVCaptureVideoPreviewLayer(session: validCaptureSession)
            // otherwise the final saved image will be wrongly rotated
            if let videoPreviewLayer = self.videoPreviewLayer, videoPreviewLayer.connection?.isVideoOrientationSupported == true {
                self.videoPreviewLayer?.connection?.videoOrientation = .portrait
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
            let code = firstCode.stringValue, self.configObject.metadata.contains(firstCode.type.rawValue) else {
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
    
    /// Take a picture from camera video stream
    ///
    /// - Parameter completion: resizedImage, originalImage
    public func takePicture(completion:@escaping (_ resizedImage:UIImage?, _ originalImage:UIImage?) -> Void) {
        
        if let videoConnection = stillImageOutput.connection(with: AVMediaType.video) {
            
            stillImageOutput.captureStillImageAsynchronously(from: videoConnection) { (imageDataSampleBuffer, _) -> Void in
                
                // if no content available from the camera abort
                guard let sampleBuffer = imageDataSampleBuffer else {
                    completion(nil, nil)
                    return
                }
                
                guard let imageData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(sampleBuffer) else {
                    completion(nil, nil)
                    return
                }
                
                guard let correctedImage = self.processPhoto(imageData) else {
                    // getting CGDataProvider failed.
                    completion(nil, nil)
                    return
                }
                
                let finalImage = ImageHelper.resizeWithRatio(
                    image: correctedImage,
                    size: CGSize(width: 512, height: 512))
                
                // correct the original image orientation.
                // setting the size to the same image size will ignore scaling.
                // this image will be used as canvas for extraction services result.
                // the extraction service will receive a resized image,
                // and return boxes with coordinate based on that resized image.
                // This will lead to a small boxes or croped images (less than 512xY)
                // which will not be accepted but matching service.
                // We need the original image which is in higher resolution.
                // We scale the boxes to the original image size, and we crop again images with at least 512 in width/height
                let originalImageRotated = ImageHelper.resizeWithRatio(
                    image: correctedImage,
                    size: CGSize(width: correctedImage.size.height,
                                 height: correctedImage.size.width))
                
                completion(finalImage, originalImageRotated)
            }
        } else {
            completion(nil, nil)
        }
    }
    
    // source: SwiftyCam: SwiftyCamViewController.swift
    // link : https://github.com/Awalz/SwiftyCam
    /**
     Returns a UIImage from Image Data.
     - Parameter imageData: Image Data returned from capturing photo from the capture session.
     - Returns: UIImage from the image data, adjusted for proper orientation.
     */
    fileprivate func processPhoto(_ imageData: Data) -> UIImage? {
        let shouldUseDeviceOrientation = self.configObject.shouldUseDeviceOrientation
        let image = ImageHelper.correctOrientation(imageData, useDeviceOrientation: shouldUseDeviceOrientation)
        return image
    }
}
