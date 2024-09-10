//
//  ImageMatchingService.swift
//  NyrisSDK
//
//  Created by MOSTEFAOUI Anas on 24/06/2017.
//  Copyright © 2017 nyris. All rights reserved.
//

import Foundation
import CoreLocation
import UIKit

/// Create filters for multipart form post requests.
public struct NyrisSearchFilter {
    /// Filter type
    public let type:String
    /// Filter values
    public let values:[String]
    
    /// Create a new nyris multipart filter
    public init(type: String, values: [String]) {
        self.type = type
        self.values = values
    }
    
    fileprivate func toMultiPartFormString(filterIndex:Int, boundry: String, newline:String) -> String {
        var body = "--\(boundry)\(newline)"
        body += "Content-Disposition:form-data; name=\"filters[\(filterIndex)].filterType\"\(newline)\(newline)"
        body += "\(type)\(newline)"
        
        for (valueIndex, value) in values.enumerated() {
            body += "--\(boundry)\(newline)"
            body += "Content-Disposition:form-data; name=\"filters[\(filterIndex)].filterValues[\(valueIndex)]\""
            body += "\(newline)\(newline)"
            body += "\(value)\(newline)"
        }
        return body
    }
}

final public class ImageMatchingService : BaseService, XOptionsProtocol {
    
    private let imageMatchingQueue:DispatchQueue = DispatchQueue(label: "com.nyris.imageMatchingQueue", qos: .background)
    
    public var xOptions: String = ""
    public var filters: [NyrisSearchFilter] = []
    
    /// Get products similar to the image's objects.
    /// This method will not apply any transformation on the given image.
    /// The caller is responsible for resizing/rotating the image
    
    /// completion will return on the main thread
    /// - Parameters:
    ///   - image: image containing the product
    ///   - position: GPS position
    ///   - isSemanticSearch: to enable/disable semantic search
    ///   - completion: completion
    public func getSimilarProducts(image:UIImage,
                                   position:CLLocation? = nil,
                                   isSemanticSearch:Bool,
                                   isFirstStageOnly:Bool = false,
                                   completion:@escaping OfferCompletion) {
        
        if let error = self.checkForError() {
            DispatchQueue.main.async {
                completion(nil, error)
            }
            return
        }
        
        guard let imageData = image.jpegData(compressionQuality: 0.5) else {
            let error = RequestError.invalidData(message: "invalid image data")
            DispatchQueue.main.async {
                completion(nil, error)
            }
            return
        }
        
        self.postSimilarProducts(
            imageData: imageData,
            position: position,
            isSemanticSearch: isSemanticSearch,
            isFirstStageOnly: isFirstStageOnly) { (offers, error) in
                DispatchQueue.main.async {
                    completion(offers, error)
                }
        }
    }
    
    /// Send similar product post request
    ///
    /// - Parameters:
    ///   - imageData: image of the product
    ///   - position: GPS position
    ///   - isSemanticSearch: semantic search
    ///   - completion: ([Product]?, Error?) -> void
    private func postSimilarProducts(
        imageData:Data,
        position:CLLocation?,
        isSemanticSearch:Bool,
        isFirstStageOnly:Bool,
        completion:@escaping OfferCompletion) {
        
        let request = self.buildRequest(imageData: imageData,
                                        position: position,
                                        isSemanticSearch: isSemanticSearch,
                                        isFirstStageOnly:isFirstStageOnly)
        self.imageMatchingQueue.async {
            let task = self.jsonTask.execute(request: request, onSuccess: { data in
                let result = self.parseMatchingResponse(data: data)
                completion(result, nil)
            }, onFailure: { (error, _) in
                completion(nil, error)
            })
            
            self.currentTask = task
            task?.resume()
        }
    }
    
    private func buildRequest(imageData:Data, position:CLLocation?, isSemanticSearch:Bool,
                              isFirstStageOnly:Bool) -> URLRequest {
        let latitude = position?.coordinate.latitude
        let longitude = position?.coordinate.longitude
        let api = API.matching(latitude: latitude, longitude: longitude)
        var request = URLRequest(url: api.endpoint(provider: self.endpointProvider, version: filters.isEmpty ? "1" : "1.1"))
        let dataLength = [UInt8](imageData)
        var headers = [
            "Accept-Language" : "\(self.acceptLanguage);q=0.5",
            "Accept" : self.outputFormat
        ]
        
        if isFirstStageOnly {
            headers["X-Only-First-Stage"] = "nyris"
        }
        
        if isSemanticSearch == true {
            headers["X-Only-Semantic-Search"] = "nyris"
        }
        
        if self.xOptions.isEmpty == false {
            headers["X-Options"] = self.xOptions
        }
        
        if !filters.isEmpty {
            let multipartBoundary = "\(UUID().uuidString)"
            headers["Content-Type"] = "multipart/form-data; boundary=\(multipartBoundary)"
            request.httpBody = getFilteringMultiPart(searchFilters: filters, imageData: imageData, multipartBoundary: multipartBoundary)
        } else {
            
            headers["Content-Type"] = "image/jpeg"
            headers["Content-Length"] = String(dataLength.count)
            request.httpBody = imageData
        }
        request.allHTTPHeaderFields = headers
        request.httpMethod = api.method
        return request
    }
    
    private func getFilteringMultiPart(searchFilters: [NyrisSearchFilter], imageData:Data, multipartBoundary: String) -> Data? {
        /// spec https://www.rfc-editor.org/rfc/rfc7578
        /// spec https://www.w3.org/Protocols/rfc1341/7_2_Multipart.html
        let newline = "\r\n"
        var multipartBody = ""
        let endBoundry = "\(newline)--\(multipartBoundary)--\(newline)"
        for (index, filter) in searchFilters.enumerated() {
            multipartBody += filter.toMultiPartFormString(filterIndex: index, boundry: multipartBoundary, newline: newline)
        }
        
        multipartBody += "--\(multipartBoundary)\(newline)"
        multipartBody += "Content-Disposition:form-data; name=\"image\"; filename=\"image.jpeg\"\(newline)"
        multipartBody += "Content-Type: image/jpeg\(newline)\(newline)"
        
        guard let formData = multipartBody.data(using: .utf8), let endBoundryData = endBoundry.data(using: .utf8) else {
            return nil
        }
        var mutableData = Data()
        mutableData.append(formData)
        mutableData.append(imageData)
        // we must close the delimter or the server won't parse the data correctly.
        mutableData.append(endBoundryData)
        return mutableData
    }
}

// Parsing
extension ImageMatchingService {

    private func parseMatchingResponse(data:Data) -> OffersResult? {
        do {
            let decoder = JSONDecoder()
            let offers = try decoder.decode(OffersResult.self, from: data)
            return offers
        } catch {
            print(error)
            return nil
        }
    }
}

// scaling abstraction extension
extension ImageMatchingService {
    
    /// Search for offers that matches the given image's objects.
    /// This method will automatically resize the given image to 512xHeight/Widthx512
    /// If the given image size is less than 512 on both weight and height, it will fails
    /// This method return on the main thread
    /// - Parameters:
    ///   - image: product image
    ///   - position: user position
    ///   - isSemanticSearch: enable MESS search only
    ///   - isFirstStageOnly: enable exact match
    ///   - useDeviceOrientation : rotate the image based on device orientation.
    ///     useful if the image was taken from the device camera.
    ///     If your image is already in the correct rotation, ignore this parameter.
    ///   - completion: (products:[Offer]?, error:Error) -> Void
    public func match(image:UIImage,
                      position:CLLocation? = nil,
                      isSemanticSearch:Bool = false,
                      isFirstStageOnly:Bool = false,
                      useDeviceOrientation:Bool = false,
                      completion:@escaping OfferCompletion ) {
        
        if let error = self.checkForError() {
            DispatchQueue.main.async {
                completion(nil, error)
            }
            return
        }

        // orient/resize image if needed
        let (preparedImage, error) = ImageHelper.prepareImage(image: image,
                                                              useDeviceOrientation: useDeviceOrientation)
        if let error = error, preparedImage == nil {
            DispatchQueue.main.async {
                completion(nil, error)
            }
            return
        }
        
        guard let validImage = preparedImage else {
            DispatchQueue.main.async {
                completion(nil, error)
            }
            return
        }
        
        self.getSimilarProducts(image: validImage,
                                position: position,
                                isSemanticSearch: isSemanticSearch,
                                isFirstStageOnly:isFirstStageOnly,
                                completion: completion)
    }
}
