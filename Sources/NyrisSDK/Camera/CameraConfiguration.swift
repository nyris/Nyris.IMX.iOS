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
    case continuous
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
            preset3840x2160 = AVCaptureSession.Preset.hd4K3840x2160.rawValue
        } else {
            preset3840x2160 = AVCaptureSession.Preset.photo.rawValue
        }
        return [
            .photo:AVCaptureSession.Preset.photo.rawValue,
            .high:AVCaptureSession.Preset.high.rawValue,
            .medium:AVCaptureSession.Preset.medium.rawValue,
            .low:AVCaptureSession.Preset.low.rawValue,
            .res352x288:AVCaptureSession.Preset.cif352x288.rawValue,
            .res640x480:AVCaptureSession.Preset.vga640x480.rawValue,
            .res1280x720:AVCaptureSession.Preset.hd1280x720.rawValue,
            .res1920x1080:AVCaptureSession.Preset.hd1920x1080.rawValue,
            .res3840x2160:preset3840x2160,
            .frame960x540:AVCaptureSession.Preset.iFrame960x540.rawValue,
            .frame1280x720:AVCaptureSession.Preset.iFrame1280x720.rawValue,
            .inputPriority:AVCaptureSession.Preset.photo.rawValue
        ]
    }
    
    public func foundationPreset() -> String {
        let mapping = self.presetMaping()
        return mapping[self] ?? AVCaptureSession.Preset.photo.rawValue
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
    public var metadata:[AVMetadataObject.ObjectType]
    public var captureMode:CaptureMode
    
    // focus
    public var focusMode:AVCaptureDevice.FocusMode
    public var allowTapToFocus:Bool
    // light
    public var torchMode:TorchMode
    public var flashMode:TorchMode
    
    public let allowBarcodeScan:Bool
    
    public var shouldUseDeviceOrientation:Bool
    // preset
    public var preset:SessionPreset
    
    /// configuration object initializer
    public init(metadata:[AVMetadataObject.ObjectType], captureMode:CaptureMode,
                sessionPresent:SessionPreset,
                torchMode:TorchMode = .off,
                flashMode:TorchMode = .off,
                focusMode:AVCaptureDevice.FocusMode = .continuousAutoFocus,
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
    
    static public func BarcodeScanConfiguration(captureMode:CaptureMode, preset:SessionPreset) -> CameraConfiguration {
        let configuration = CameraConfiguration(metadata: [
            AVMetadataObject.ObjectType.qr,
            AVMetadataObject.ObjectType.ean8,
            AVMetadataObject.ObjectType.ean13,
            AVMetadataObject.ObjectType.pdf417],
                                                captureMode: captureMode, sessionPresent:preset,
                                                allowBarcodeScan: true )
        return configuration
    }
}
