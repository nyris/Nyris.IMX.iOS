//
//  UIImageViewExtension.swift
//  NyrisSDK
//
//  Created by MOSTEFAOUI Anas on 02/02/2018.
//  Copyright © 2018 nyris. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation

// extract bounding boxes
extension UIImageView {
    public var extractionService:ProductExtractionService {
        return ProductExtractionService()
    }
    
    public func extractProducts(completion:@escaping ExtractedObjectCompletion) {
        guard let validImage = self.image else {
            let message = "image is nil"
            let error = ImageError.invalidImageData(message: message)
            completion(nil, error)
            return
        }
        self.extractionService.extractObjects(from: validImage,
                                       displayFrame: self.imageFrame,
                                       completion: completion)
    }
}

// matching images extension
extension UIImageView {
    public var matchingService:ImageMatchingService {
        return ImageMatchingService()
    }
    
    /// Request offers that matches objects in the image
    /// The image must be at least 512 on one side.
    /// - Parameters:
    ///   - position: user position
    ///   - isSemanticSearch: enable MESS search only
    ///   - isFirstStageOnly: enable exact match
    ///   - completion: OfferCompletion
    public func match(position:CLLocation? = nil, isSemanticSearch:Bool = false, isFirstStageOnly:Bool = false, completion:@escaping OfferCompletion) {
        guard let validImage = self.image else {
            let message = "image is nil"
            let error = ImageError.invalidImageData(message: message)
            completion(nil, error)
            return
        }
        matchingService.match(
            image: validImage,
            position: position,
            isSemanticSearch: isSemanticSearch,
            isFirstStageOnly: isFirstStageOnly,
            useDeviceOrientation: false,
            completion: completion)

    }
}

// nested image extension
extension UIImageView {
    
    public func imageScales(boundingRect:CGRect, contentMode:UIViewContentMode) -> CGPoint {
       
        guard let validImage = self.image else {
            return CGPoint.zero
        }
        
        let imageSize = validImage.size
        let scale = CGPoint(x: boundingRect.size.width / imageSize.width,
                            y: boundingRect.size.height / imageSize.height)
        
        var resultScales = CGPoint.zero
        
        switch contentMode {
        case .scaleAspectFit:
            let minScale = min(scale.x, scale.y)
            resultScales = CGPoint(x: minScale, y: minScale)
        case .scaleAspectFill:
            let maxScale = max(scale.x, scale.y)
            resultScales = CGPoint(x: maxScale, y: maxScale)
        case .scaleToFill:
            resultScales = scale
        default:
             resultScales = CGPoint(x: 1.0, y: 1.0)
        }
        
        if imageSize.width == 0 {
            resultScales.x = 1
        }
        
        if imageSize.height == 0 {
            resultScales.y = 1
        }
        return resultScales
    }
    
    public func imageFrame(boundingRect:CGRect, contentMode:UIViewContentMode) -> CGRect {
        guard let validImage = self.image else {
            return CGRect.zero
        }
        
        var imageFrame = CGRect.zero
        let imageSize = validImage.size
        let scales = self.imageScales(boundingRect: boundingRect, contentMode: contentMode)
        
        imageFrame.size.width = imageSize.width * scales.x
        imageFrame.size.height = imageSize.height * scales.y
        
        var center = CGPoint.zero
        center.x = (boundingRect.size.width - imageFrame.size.width) * 0.5
        center.y = (boundingRect.size.height  - imageFrame.size.height) * 0.5
        
        // offset the center by imageview position
        center.x += self.frame.origin.x
        center.y += self.frame.origin.y

        imageFrame = self.getImageFrame(imageFrame:imageFrame,
                                        center:center,
                                        boundingRect:boundingRect)
        
        return imageFrame
    }
    
    private func getImageFrame(imageFrame:CGRect, center:CGPoint, boundingRect:CGRect) -> CGRect {
        var imageFrame = imageFrame
        let top:CGFloat = self.frame.origin.y
        let left:CGFloat = self.frame.origin.x
        let right:CGFloat = boundingRect.size.width - imageFrame.size.width
        let bottom:CGFloat = boundingRect.size.height - imageFrame.size.height
        
        switch contentMode {
        case .redraw, .center, .scaleAspectFill, .scaleAspectFit, .scaleToFill:
            imageFrame.origin = center
        case .top:
            imageFrame.origin.y = 0
            imageFrame.origin.x = center.x
        case .topLeft:
            imageFrame.origin.y = top
            imageFrame.origin.x = left
        case .topRight:
            imageFrame.origin.y = top
            imageFrame.origin.x = right
        case .bottom:
            imageFrame.origin.y = bottom
            imageFrame.origin.x = center.x
        case .bottomLeft:
            imageFrame.origin.y = bottom
            imageFrame.origin.x = left
        case .bottomRight:
            imageFrame.origin.y = bottom
            imageFrame.origin.x = right
            
        case .left:
            imageFrame.origin.y = center.y
            imageFrame.origin.x = left
        case .right:
            imageFrame.origin.y = center.y
            imageFrame.origin.x = right
        }
        return imageFrame
    }
    
    public var imageFrame: CGRect {
        let frame = self.imageFrame(boundingRect: self.bounds, contentMode: self.contentMode)
        return frame
    }
    
    public var imageScales: CGPoint {
        let frame = self.imageScales(boundingRect: self.bounds, contentMode: self.contentMode)
        return frame
    }
    
}

extension UIImageView {
    
    /// Find the size of the image, once the parent imageView has been given a contentMode of .scaleAspectFit
    /// Querying the image.size returns the non-scaled size. This helper property is needed for accurate results.
    public var aspectFitSize: CGSize {
        guard let image = image else { return CGSize.zero }
        
        var aspectFitSize = CGSize(width: frame.size.width, height: frame.size.height)
        let newWidth: CGFloat = frame.size.width / image.size.width
        let newHeight: CGFloat = frame.size.height / image.size.height
        
        if newHeight < newWidth {
            aspectFitSize.width = newHeight * image.size.width
        } else if newWidth < newHeight {
            aspectFitSize.height = newWidth * image.size.height
        }
        
        return aspectFitSize
    }
    
    /// Find the size of the image, once the parent imageView has been given a contentMode of .scaleAspectFill
    /// Querying the image.size returns the non-scaled, vastly too large size. This helper property is needed for accurate results.
    public var aspectFillSize: CGSize {
        guard let image = image else { return CGSize.zero }
        
        var aspectFillSize = CGSize(width: frame.size.width, height: frame.size.height)
        let newWidth: CGFloat = frame.size.width / image.size.width
        let newHeight: CGFloat = frame.size.height / image.size.height
        
        if newHeight > newWidth {
            aspectFillSize.width = newHeight * image.size.width
        } else if newWidth > newHeight {
            aspectFillSize.height = newWidth * image.size.height
        }
        
        return aspectFillSize
    }
    
}
