//
//  JsonDownloaderTask.swift
//  NyrisSDK
//
//  link: https://medium.com/compileswift/using-closures-generics-pop-and-protocols-with-associated-types-to-create-reusable-apis-for-your-a9d3468ce6b1
//

import Foundation
import SystemConfiguration

public enum Result<T> {
    case success(T)
    case error(error:Error, json:[String:Any]?)
}

/// Json Download and serialization task
struct JSONDownloader {
    
    typealias JSON = [String: AnyObject]
    typealias JSONTaskCompletionHandler = (Result<JSON>) -> Void
    
    let session: URLSession
    
    init(apiKey:String, configuration: URLSessionConfiguration) {
        
        guard apiKey.isEmpty == false else {
            fatalError("Empty API key")
        }
        
        configuration.httpAdditionalHeaders = [
            "X-Api-Key" : apiKey,
            "user-agent": JSONDownloader.userAgent
        ]
        
        self.session = URLSession(configuration: configuration)

    }
    
    init(apiKey:String) {
        guard apiKey.isEmpty == false else {
            fatalError("Empty API key")
        }
        self.init(apiKey:apiKey, configuration: .default)
    }
    
    public static var userAgent : String {
        let appVersion = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") ?? "0"
        let appBuild = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") ?? "0"
        
        let bundle = Bundle.main.bundleIdentifier ?? ""
        let osVersion = ProcessInfo().operatingSystemVersion
        let osVersionString = "\(osVersion.majorVersion).\(osVersion.minorVersion).\(osVersion.patchVersion)"
        let userAgent = "nyris/\(bundle)-\(appVersion)-build(\(appBuild)) (iOS; \(osVersionString))"
        
        return userAgent
    }
    
    /// download json string and parse it
    func execute(with request: URLRequest, completionHandler completion: @escaping JSONTaskCompletionHandler) -> URLSessionDataTask? {
        
        guard self.isNetworkReachable == true else {
            let error = RequestError.unreachableNetwork(message: "Internet not reachable")
            completion(.error(error: error, json:nil))
            return nil
        }
        
        let task = session.dataTask(with: request) { (data, response, error) in
            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.error(error:RequestError.requestFailed(message:""), json: nil))
                return
            }
            
            // check http status code validity
            guard httpResponse.statusCode >= 200 && httpResponse.statusCode < 300 else {
                debugPrint(error?.localizedDescription ?? "")
                let message = "Status code does not indicate success: \(httpResponse.statusCode)"
                let unsuccessfullRequest = RequestError.invalidHTTPCode(message: message, status: httpResponse.statusCode)
                var json:[String:AnyObject]? = nil
                if let data = data {
                    if let errorJson = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: AnyObject] {
                        json = errorJson
                    }
                }
                completion(.error(error:unsuccessfullRequest,json:json))
                return
            }
            
            guard let data = data else {
                completion(.error(error:RequestError.invalidData(message: "Invalid data from the server"),json:nil))
                return
            }
            
            // data seems valid, parse the data to json
            do {
                guard let jsonString = String(data: data, encoding: String.Encoding.utf8) else {
                    completion(.error(error:RequestError.parsingFailed, json:nil))
                    return
                }
                // in case the server send sucessfull status code but with no content (e.g: 204)
                // this will avoid sending "parsing failure" in this valid case
                guard jsonString.isEmpty == false else {
                    completion(.success([:]))
                    return
                }
                
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: AnyObject] {
                    completion(.success(json))
                } else {
                    completion(.error(error:RequestError.parsingFailed, json:nil))
                }
                
            } catch {
                completion(.error(error:RequestError.parsingFailed, json:nil))
            }
        }
        return task
    }
}

extension JSONDownloader {
    var isNetworkReachable:Bool {
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        let defaultRouteReachability = withUnsafePointer(to: &zeroAddress) {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {zeroSockAddress in
                SCNetworkReachabilityCreateWithAddress(nil, zeroSockAddress)
            }
        }
        
        var flags = SCNetworkReachabilityFlags()
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) {
            return false
        }
        let isReachable = (flags.rawValue & UInt32(kSCNetworkFlagsReachable)) != 0
        let needsConnection = (flags.rawValue & UInt32(kSCNetworkFlagsConnectionRequired)) != 0
        return (isReachable && !needsConnection)
    }
}
