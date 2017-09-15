//
//  ImageHelper.swift
//  NyrisSDK
//
//  Created by MOSTEFAOUI Anas on 24/07/2017.
//  Copyright © 2017 nyris. All rights reserved.
//
import UIKit

/// this class is a modified subset of toucan utilities class
/// link : https://github.com/gavinbunney/Toucan/
final class ImageHelper {
    
    /// correct image orientation
    ///
    /// - Parameters:
    ///   - transform: transform that will recieve the correction
    ///   - image: image to re oriente
    private static func correctOrientation( transform: inout CGAffineTransform, image:UIImage) {
        switch image.imageOrientation {
        case UIImageOrientation.right, UIImageOrientation.rightMirrored:
            transform = transform.translatedBy(x: 0, y: image.size.height)
            transform = transform.rotated(by: CGFloat(-1.0 * Double.pi * 0.5))
            break
        case UIImageOrientation.left, UIImageOrientation.leftMirrored:
            transform = transform.translatedBy(x: image.size.width, y: 0)
            transform = transform.rotated(by: CGFloat(Double.pi * 0.5 ))
            break
        case UIImageOrientation.down, UIImageOrientation.downMirrored:
            transform = transform.translatedBy(x: image.size.width, y: image.size.height)
            transform = transform.rotated(by: CGFloat(Double.pi))
            break
        default:
            break
        }
        
        switch (image.imageOrientation) {
        case UIImageOrientation.rightMirrored, UIImageOrientation.leftMirrored:
            transform = transform.translatedBy(x: image.size.height, y: 0)
            transform = transform.scaledBy(x: -1, y: 1)
            break
        case UIImageOrientation.downMirrored, UIImageOrientation.upMirrored:
            transform = transform.translatedBy(x: image.size.width, y: 0)
            transform = transform.scaledBy(x: -1, y: 1)
            break
        default:
            break
        }
    }
    
    /// Get the CGImage of the image with the orientation fixed up based on EXF data.
    /// This helps to normalise input images to always be the correct orientation when performing
    /// other core graphics tasks on the image.
    ///
    /// - parameter image: Image to create CGImageRef for
    ///
    /// - returns: CGImageRef with rotated/transformed image context
    static func CGImageWithCorrectOrientation(_ image : UIImage) -> CGImage? {
        
        guard let cgImage = image.cgImage else {
            return nil
        }
        
        if (image.imageOrientation == UIImageOrientation.up) {
            return cgImage
        }
        
        var transform : CGAffineTransform = CGAffineTransform.identity
        
        self.correctOrientation(transform: &transform, image: image)
        
        let contextWidth : Int
        let contextHeight : Int
        
        switch (image.imageOrientation) {
        case UIImageOrientation.left, UIImageOrientation.leftMirrored,
             UIImageOrientation.right, UIImageOrientation.rightMirrored:
            contextWidth = cgImage.height
            contextHeight = cgImage.width
            break
        default:
            contextWidth = cgImage.width
            contextHeight = cgImage.height
            break
        }
        
        let context = CGContext(data: nil, width: contextWidth,
                                height: contextHeight,
                                bitsPerComponent: cgImage.bitsPerComponent,
                                bytesPerRow: cgImage.bytesPerRow,
                                space: cgImage.colorSpace!,
                                bitmapInfo: cgImage.bitmapInfo.rawValue)
        
        guard let validContext = context else {
            return nil
        }
        
        validContext.concatenate(transform)
        validContext.draw(image.cgImage!, in: CGRect(x: 0,
                                                     y: 0,
                                                     width: CGFloat(contextWidth),
                                                     height: CGFloat(contextHeight)))
        
        guard let finalCGImage = validContext.makeImage() else {
            return nil
        }
        return finalCGImage
    }
    
    /// resize an image based on the size parametres
    /// this method respect aspect ratio, even if the passed size is a square.
    /// the method will pick up the longest original image size, and resize it to the size.width or size.height
    /// e.g : if an image is  540x960, and we want to resize it to 512x512, the result will be 512x910.
    ///
    /// - Parameters:
    ///   - image: image to be resized
    ///   - size: the new desired size (or one of it component)
    /// - Returns: resized image or nil
    static func resizeWithRatio(image: UIImage, size: CGSize) -> UIImage? {
        
        guard let imgRef = self.CGImageWithCorrectOrientation(image) else {
            return nil
        }
        
        // the app is portrait mode only, but can report if the device is rotated in landscape mode
        // isFlat is invalid orientation because it can occure in both landscape or portrait, while denying them (both are false
        let isLandscape = UIDevice.current.orientation.isLandscape && UIDevice.current.orientation.isValidInterfaceOrientation
        // if the user took a picture, in landscape mode, we need to handle the fixed portrait mode, as landscape
        // to do, we swap, width and height for the original image, and for the destination image
        // example :
        //      if an image is 300x200 in app portrait mode
        //      In landscape, the imgRef, will report : width : 200, height : 300
        //      so we need to swape width,height on the original image, then resize it
        let originalWidth  = isLandscape ? CGFloat(imgRef.height) : CGFloat(imgRef.width)
        let originalHeight = isLandscape ? CGFloat(imgRef.width) : CGFloat(imgRef.height)
        let widthRatio =  size.width /  originalWidth
        let heightRatio = size.height / originalHeight
        
        let scaleRatio = widthRatio > heightRatio  ? widthRatio : heightRatio
        /// swape the destination size based on landscape mode
        let destinationWidth = isLandscape ? round(originalHeight * scaleRatio) : round(originalWidth * scaleRatio)
        let destinationHeight = isLandscape ? round(originalWidth * scaleRatio) : round(originalHeight * scaleRatio)
        let resizedImageBounds = CGRect(x: 0, y: 0, width: destinationWidth, height: destinationHeight)
        
        UIGraphicsBeginImageContextWithOptions(resizedImageBounds.size, false, 1)
        image.draw(in: resizedImageBounds)
        let resizedImage : UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return resizedImage
    }
    
    // source: SwiftyCam: SwiftyCamViewController.swift
    // link : https://github.com/Awalz/SwiftyCam
    /**
     Returns a UIImage from Image Data.
     
     - Parameter imageData: Image Data returned from capturing photo from the capture session.
     
     - Returns: UIImage from the image data, adjusted for proper orientation.
     */
    static public func corretOrientation(_ imageData: Data, useDeviceOrientation:Bool) -> UIImage {
        let dataProvider = CGDataProvider(data: imageData as CFData)
        let cgImageRef = CGImage(jpegDataProviderSource: dataProvider!, decode: nil, shouldInterpolate: true, intent: CGColorRenderingIntent.defaultIntent)
        
        // Set proper orientation for photo
        let image = UIImage(cgImage: cgImageRef!, scale: 1.0, orientation: ImageHelper.getImageOrientation(useDeviceOrientation: true))
        return image
    }
    
    /// get image orientation based on the device orientation, since the image is always taken in landscape.
    static public func getImageOrientation(useDeviceOrientation:Bool) -> UIImageOrientation {
        guard useDeviceOrientation == true else {
            return UIImageOrientation.right
        }
        
        var imageOrientation : UIImageOrientation = UIImageOrientation.right
        
        switch UIDevice.current.orientation {
            
        case UIDeviceOrientation.portraitUpsideDown:
            imageOrientation = UIImageOrientation.left
        case UIDeviceOrientation.landscapeRight:
            imageOrientation = UIImageOrientation.down
        case UIDeviceOrientation.landscapeLeft:
            imageOrientation = UIImageOrientation.up
        case UIDeviceOrientation.portrait:
            imageOrientation = UIImageOrientation.right
        default:
            imageOrientation = UIImageOrientation.right
        }
        return imageOrientation
    }
}
