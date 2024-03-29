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
public protocol BarcodeScannerDelegate: AnyObject {
    func didTapFocus()
    func didCaptureCode( code: String, type: String)
    func lockDidChange(newValue: Bool)
    func didReceiveError( error: Error)
}

extension BarcodeScannerDelegate {
    public func lockDidChange(newValue: Bool) {
    }
    public func didReceiveError( error: Error) {
    }
    
    public func didTapFocus() {
        
    }
}
