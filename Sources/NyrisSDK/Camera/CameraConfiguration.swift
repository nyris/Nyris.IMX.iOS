//
//  CameraConfiguration.swift
//  NyrisSDK
//
//  Created by MOSTEFAOUI Anas on 24/07/2017.
//  Copyright © 2017 nyris. All rights reserved.
//
import Foundation
import AVFoundation

public enum CaptureMode {
    case continus
    case once
    case none
}

public enum TorchMode {
    case on
    case off
    case auto
}

/// enumeration that list quality available
/// source : https://github.com/remirobert/CameraEngine
public enum SessionPreset : String {
    case photo
    case high
    case medium
    case low
    case res352x288
    case res640x480
    case res1280x720
    case res1920x1080
    case res3840x2160
    case frame960x540
    case frame1280x720
    case inputPriority
    
    private func presetMaping() -> [SessionPreset:String] {
        var preset3840x2160 = ""
        if #available(iOS 9.0, *) {
            preset3840x2160 = AVCaptureSessionPreset3840x2160
        } else {
            preset3840x2160 = AVCaptureSessionPresetPhoto
        }
        return [
            .photo:AVCaptureSessionPresetPhoto,
            .high:AVCaptureSessionPresetHigh,
            .medium:AVCaptureSessionPresetMedium,
            .low:AVCaptureSessionPresetLow,
            .res352x288:AVCaptureSessionPreset352x288,
            .res640x480:AVCaptureSessionPreset640x480,
            .res1280x720:AVCaptureSessionPreset1280x720,
            .res1920x1080:AVCaptureSessionPreset1920x1080,
            .res3840x2160:preset3840x2160,
            .frame960x540:AVCaptureSessionPresetiFrame960x540,
            .frame1280x720:AVCaptureSessionPresetiFrame1280x720,
            .inputPriority:AVCaptureSessionPresetPhoto
        ]
    }
    
    public func foundationPreset() -> String {
        let mapping = self.presetMaping()
        return mapping[self] ?? AVCaptureSessionPresetPhoto
    }
    
    public static func availablePresset() -> [SessionPreset] {
        return [
            .photo,
            .high,
            .medium,
            .low,
            .res352x288,
            .res640x480,
            .res1280x720,
            .res1920x1080,
            .res3840x2160,
            .frame960x540,
            .frame1280x720,
            .inputPriority
        ]
    }
}

public struct CameraConfiguration {
    public var metadata:[String]
    public var captureMode:CaptureMode
    
    // focus
    public var focusMode:AVCaptureFocusMode
    public var allowTapToFocus:Bool
    // light
    public var torchMode:TorchMode
    public var flashMode:TorchMode
    
    public let allowBarcodeScan:Bool
    
    public var shouldUseDeviceOrientation:Bool
    // preset
    public var preset:SessionPreset
    
    /// configuration object initializer
    public init(metadata:[String], captureMode:CaptureMode,
                sessionPresent:SessionPreset,
                torchMode:TorchMode = .off,
                flashMode:TorchMode = .off,
                focusMode:AVCaptureFocusMode = .continuousAutoFocus,
                allowTapToFocus:Bool = true,
                allowBarcodeScan:Bool = false, shouldUseDeviceOrientation:Bool = true
        ) {
        self.captureMode = captureMode
        self.metadata = metadata
        
        self.flashMode = flashMode
        self.torchMode = torchMode
        self.focusMode = focusMode
        self.allowTapToFocus = allowTapToFocus
        
        self.preset = sessionPresent
        self.allowBarcodeScan = allowBarcodeScan
        self.shouldUseDeviceOrientation = shouldUseDeviceOrientation
    }
    
    static public func codebarScanConfiguration(captureMode:CaptureMode, preset:SessionPreset) -> CameraConfiguration {
        let configuration = CameraConfiguration(metadata: [AVMetadataObjectTypeEAN8Code,
                                                           AVMetadataObjectTypeEAN13Code,
                                                           AVMetadataObjectTypePDF417Code],
                                                captureMode: captureMode, sessionPresent:preset,
                                                allowBarcodeScan: true )
        return configuration
    }
}
