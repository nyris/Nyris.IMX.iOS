//
//  JsonDownloaderTask.swift
//  NyrisSDK
//
//  link: https://medium.com/compileswift/using-closures-generics-pop-and-protocols-with-associated-types-to-create-reusable-apis-for-your-a9d3468ce6b1
//

import Foundation

public enum Result<T> {
    case success(T)
    case error(error:Error, json:[String:Any]?)
}

/// Json Download and serialization task
public struct JSONDownloader {
    
    internal typealias JSON = [String: AnyObject]
    internal typealias JSONTaskCompletion = (Result<JSON>) -> Void
    internal typealias DataTaskCompletion = (Result<Data>) -> Void
    
    private let session: URLSession
    
    internal init(apiKey:String, configuration: URLSessionConfiguration, userAgent:String = RequestUtility.userAgent) {
        
        guard apiKey.isEmpty == false else {
            fatalError("Empty API key")
        }
        
        configuration.httpAdditionalHeaders = [
            "X-Api-Key" : apiKey,
            "user-agent": userAgent
        ]
        
        self.session = URLSession(configuration: configuration)
    }
    
    internal init(apiKey:String) {
        guard apiKey.isEmpty == false else {
            fatalError("Empty API key")
        }
        self.init(apiKey:apiKey, configuration: .default)
    }
    
    private func execute<T>(request: URLRequest,
                            completion: @escaping (Result<T>) -> Void,
                            logic:@escaping (_ data:Data?) -> Void) -> URLSessionDataTask? {
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
            let requestError = RequestUtility.getStatusError(statusCode: httpResponse.statusCode, data: data)
            
            if let requestError = requestError {
                
                var json:[String:AnyObject]?
                if let data = data {
                    if let errorJson = ((try? JSONSerialization.jsonObject(with: data, options: []) as? [String: AnyObject]) as [String : AnyObject]??) {
                        json = errorJson
                    }
                }
                completion(.error(error: requestError, json: json))
                return
            }
            logic(data)
        }
        return task
    }
    
    /// download json as data (for codable)
    internal func execute(request: URLRequest, completion: @escaping DataTaskCompletion) -> URLSessionDataTask? {
        
        let task = self.execute(request: request, completion: completion) { data in
            guard let data = data else {
                let message = "Invalid data from the server"
                let error = RequestError.invalidData(message:message)
                completion(.error(error:error, json:nil))
                return
            }
            completion(.success(data))
        }
        return task
    }
    
    /// Execute a json download task and get notify if it succeed or fails
    
    /// Execute a json download task and get notify if it succeed or fails
    ///
    /// - Parameters:
    ///   - request: request to execute
    ///   - onSuccess: onSuccess closure
    ///   - onFailure: onFailure closure
    /// - Returns: task that is been executed
    internal func execute(request: URLRequest,
                          onSuccess: @escaping (_ data:Data) -> Void,
                          onFailure: @escaping (_ error:Error, _ info:[String:Any]?) -> Void) -> URLSessionDataTask? {
        
        let task = self.execute(request: request) { (result:Result<Data>) in
            switch result {
            case .error(let error, let json):
                onFailure(error, json)
            case .success(let data):
                onSuccess(data)
            }
        }
        return task
    }
    
    /// download json string and parse it
    /// compatibility
    internal func execute(request: URLRequest, completion: @escaping JSONTaskCompletion) -> URLSessionDataTask? {

        let task = self.execute(request: request, completion: completion) { data in
            guard let data = data else {
                let message = "Invalid data from the server"
                let error = RequestError.invalidData(message: message)
                completion(.error(error:error, json:nil))
                return
            }
            
            // data seems valid, parse the data to json
            do {
                guard let jsonString = String(data: data, encoding: String.Encoding.utf8) else {
                    completion(.error(error:RequestError.parsingFailed, json:nil))
                    return
                }
                // in case the server send successful status code but with no content (e.g: 204)
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
    internal var isNetworkReachable:Bool {
        return NetworkUtility.isNetworkReachable
    }
}
