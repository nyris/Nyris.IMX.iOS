//
//  CodebarScannerDelegate.swift
//  NyrisSDK
//
//  Created by MOSTEFAOUI Anas on 24/07/2017.
//  Copyright © 2017 nyris. All rights reserved.
//
import Foundation
import AVFoundation

/// Delegate to handle the captured code.
public protocol CodebarScannerDelegate: class {
    func didCaptureCode( code: String, type: String)
    func lockDidChange(newValue:Bool)
    func didReceiveError( error: Error)
}

public class CodebarCaptureDelegate: NSObject, AVCaptureMetadataOutputObjectsDelegate {
    
    /// Flag to lock session from capturing.
    var locked = false
    
    public func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [Any]!, from connection: AVCaptureConnection!) {
        guard self.locked == false else {
            return
        }
    }
}

public class CodebarScanner : NSObject, CodebarScannerDelegate {
    public func lockDidChange(newValue:Bool) {
    }
    
    public func didCaptureCode( code: String, type: String) {
    }
    
    public func didReceiveError( error: Error) {
    }
    
}
