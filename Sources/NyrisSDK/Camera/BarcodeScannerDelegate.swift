//
//  BarcodeScannerDelegate.swift
//  NyrisSDK
//
//  Created by MOSTEFAOUI Anas on 24/07/2017.
//  Copyright © 2017 nyris. All rights reserved.
//
import Foundation
import AVFoundation

/// Delegate to handle the captured code.
public protocol BarcodeScannerDelegate: class {
    func didTapFocus()
    func didCaptureCode( code: String, type: String)
    func lockDidChange(newValue: Bool)
    func didReceiveError( error: Error)
}

public class BarcodeScanner: NSObject, BarcodeScannerDelegate {
    public func lockDidChange(newValue: Bool) {
    }
    
    public func didCaptureCode( code: String, type: String) {
    }
    
    public func didReceiveError( error: Error) {
    }
    
    public func didTapFocus() {
        
    }
}
