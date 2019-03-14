//
//  RequestUtility.swift
//  Nyris.IMX.iOS
//
//  Created by MOSTEFAOUI Anas on 12/01/2018.
//  Copyright © 2018 nyris. All rights reserved.
//

import Foundation

internal struct RequestUtility {
    internal static var userAgent : String {
        let appVersion = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") ?? "0"
        let appBuild = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") ?? "0"
        
        let bundle = Bundle.main.bundleIdentifier ?? ""
        let osVersion = ProcessInfo().operatingSystemVersion
        let osVersionString = "\(osVersion.majorVersion).\(osVersion.minorVersion).\(osVersion.patchVersion)"
        let userAgent = "nyris/\(bundle)-\(appVersion)-build(\(appBuild)) (iOS; \(osVersionString))"
        
        return userAgent
    }
    
    /// Check if the HTTP code is valid
    ///
    /// - Parameters:
    ///   - statusCode: http code
    ///   - data: data that came from the server attached to that code
    /// - Returns: true if valid, else false
    internal static func getStatusError(statusCode:Int, data:Data?) -> RequestError? {
        // check http status code validity
        guard statusCode >= 200 && statusCode < 300 else {
            let message = "Status code does not indicate success: \(statusCode)"
            let unsuccessfulRequest = RequestError.invalidHTTPCode(message: message, status: statusCode)
            return unsuccessfulRequest
        }
        return nil
    }
}
