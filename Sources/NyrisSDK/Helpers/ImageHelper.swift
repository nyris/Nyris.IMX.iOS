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
final public class ImageHelper {
    
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
        case UIImageOrientation.left, UIImageOrientation.leftMirrored:
            transform = transform.translatedBy(x: image.size.width, y: 0)
            transform = transform.rotated(by: CGFloat(Double.pi * 0.5 ))
        case UIImageOrientation.down, UIImageOrientation.downMirrored:
            transform = transform.translatedBy(x: image.size.width, y: image.size.height)
            transform = transform.rotated(by: CGFloat(Double.pi))
        default:
            break
        }
        
        switch image.imageOrientation {
        case UIImageOrientation.rightMirrored, UIImageOrientation.leftMirrored:
            transform = transform.translatedBy(x: image.size.height, y: 0)
            transform = transform.scaledBy(x: -1, y: 1)
        case UIImageOrientation.downMirrored, UIImageOrientation.upMirrored:
            transform = transform.translatedBy(x: image.size.width, y: 0)
            transform = transform.scaledBy(x: -1, y: 1)
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
    static public func CGImageWithCorrectOrientation(_ image : UIImage) -> CGImage? {
        
        guard let cgImage = image.cgImage, let colorSpace = cgImage.colorSpace else {
            return nil
        }
        
        if image.imageOrientation == UIImageOrientation.up {
            return cgImage
        }
        
        var transform : CGAffineTransform = CGAffineTransform.identity
        
        self.correctOrientation(transform: &transform, image: image)
        
        let contextWidth : Int
        let contextHeight : Int
        
        switch image.imageOrientation {
        case UIImageOrientation.left, UIImageOrientation.leftMirrored,
             UIImageOrientation.right, UIImageOrientation.rightMirrored:
            contextWidth = cgImage.height
            contextHeight = cgImage.width
        default:
            contextWidth = cgImage.width
            contextHeight = cgImage.height
        }

        let context = CGContext(data: nil, width: contextWidth,
                                height: contextHeight,
                                bitsPerComponent: cgImage.bitsPerComponent,
                                bytesPerRow: cgImage.bytesPerRow,
                                space: colorSpace,
                                bitmapInfo: cgImage.bitmapInfo.rawValue)
        
        guard let validContext = context else {
            return nil
        }
        
        validContext.concatenate(transform)
        validContext.draw(cgImage, in: CGRect(x: 0,
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
    static public func resizeWithRatio(image:UIImage, size: CGSize) -> UIImage? {
        
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
        
        // scale the closest side to 512
        let scaleRatio = widthRatio > heightRatio  ? widthRatio : heightRatio
        /// swape the destination size based on landscape mode
        let destinationWidth = isLandscape ? round(originalHeight * scaleRatio) : round(originalWidth * scaleRatio)
        let destinationHeight = isLandscape ? round(originalWidth * scaleRatio) : round(originalHeight * scaleRatio)
        let resizedImageBounds = CGRect(x: 0, y: 0, width: destinationWidth, height: destinationHeight)
        
        UIGraphicsBeginImageContextWithOptions(resizedImageBounds.size, false, 1)
        image.draw(in: resizedImageBounds)
        let resizedImage : UIImage? = UIGraphicsGetImageFromCurrentImageContext()
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
    
    /// Returns a deviced oriented UIImage from Image Data, if useDeviceOrientation is true
    /// else return a UIImage oriented to the right
    /// based on the code of SwiftyCam: SwiftyCamViewController.swift
    /// link : https://github.com/Awalz/SwiftyCam
    /// - Parameters:
    ///   - imageData: Data
    ///   - useDeviceOrientation: Enable/Disable orientation based on device orientation
    /// - Returns: oriented UIImage
    static public func correctOrientation(_ imageData: Data, useDeviceOrientation:Bool) -> UIImage? {
        
        guard let dataProvider = CGDataProvider(data: imageData as CFData) else {
            return nil
        }
        
        let cgImageRef = CGImage(jpegDataProviderSource: dataProvider, decode: nil, shouldInterpolate: true, intent: CGColorRenderingIntent.defaultIntent)
        
        guard let imageRef = cgImageRef else {
            return nil
        }
    
        // Set proper orientation for photo
        let image = UIImage(cgImage: imageRef, scale: 1.0, orientation: ImageHelper.getImageOrientation(useDeviceOrientation: useDeviceOrientation))
        return image
    }
    
    /// get image orientation based on the device orientation, since the image is always taken in landscape.
    static public func getImageOrientation(useDeviceOrientation:Bool) -> UIImageOrientation {
        guard useDeviceOrientation == true else {
            return UIImageOrientation.up
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
    
    /// Prepare the image for SDK usage
    /// Rotate and resize the given image if needed
    /// This method will check if the given image is valid for processing
    /// if the image come from unprocessed device camera picture, useDeviceOrientation should be true
    ///
    /// - Parameters:
    ///   - image: Image
    ///   - useDeviceOrientation: Enable/Disable device orientation.
    ///     usefull when taking pictures from one of the device camera.
    ///     If the image is already in the correct rotation, ignore this param
    /// - Returns: (preparedImage, error)
    public static func prepareImage(image:UIImage, useDeviceOrientation:Bool = false) -> (UIImage?, Error?) {
        
        // abort if the image is too small.
        let imageSize = image.size
        
        if imageSize.width < 512 && imageSize.height < 512 {
            let message = "Image too small, width and height are less than 512"
            let error = ImageError.invalidSize(message:message)
            return (nil, error)
        }
        
        // if useDeviceOrientation is set to false
        // the user is responsible for sending a correctly rotated image.
        var correctedImage:UIImage = image
        
        if useDeviceOrientation == true {
            guard let imageData = UIImageJPEGRepresentation(image, 0.5) else {
                let error = ImageError.invalidImageData(message: "invalid image data")
                return (nil, error)
            }
            
            let orientedImage = ImageHelper.correctOrientation(imageData, useDeviceOrientation: true)
            guard let validCorrectedImage = orientedImage else {
                let message = "Correct image rotation failed."
                let error = ImageError.rotatingFailed(message: message)
                return (nil, error)
            }
            correctedImage = validCorrectedImage
        }
        
        // don't resize if one side is already 512
        if imageSize.width == 512 || imageSize.height == 512 {
            return (image, nil)
        }
        
        let finalImage = ImageHelper.resizeWithRatio(image: correctedImage,
                                                     size: CGSize(width: 512, height: 512))
        guard let resizedImage = finalImage else {
            let message = "image resizing Failed."
            let error = ImageError.resizingFailed(message: message)
            return (nil, error)
        }
        return (resizedImage, nil)
    }
    
    /// Scale the given crop rectangle which is based on basecanvasSizeFrame size/coordinate, to the Image size/coordinat
    /// it will act like if the crop rectangle was directly drawn on the given image
    /// - Parameters:
    ///   - imageSize: Size of the Image displayed on the screen, The one to scale to.
    ///   - canvasSize : the base referance size. The one to scale from
    ///   - cropOverlay: croping bounding box (rectangle)
    ///   - outterGap: outtergap, if we pad the croping rectangle for visual reasons
    ///   - navigationHeaderHeight: the navigation header size, if the image is displayed on a view that is under navigation bar
    /// - Returns: scaled rectangle
    static public func applyRectProjection(
        on box:CGRect,
        from originalFrame:CGRect,
        to destinationFrame:CGRect,
        padding:CGFloat,
        navigationHeaderHeight:CGFloat = 44.0) -> CGRect {
        
        // the croping views rect displayed on the screen
        let cropRect = CGRect(x: box.origin.x + padding,
                              y: box.origin.y + (navigationHeaderHeight + padding),
                              width: box.size.width - (2 * padding),
                              height: box.size.height - (2 * padding) )
        
        let baseFrameWidth = originalFrame.width
        let baseFrameHeight = originalFrame.height
        
        let destinationWidth = destinationFrame.width
        let destinationHeight = destinationFrame.height
        
        let aspectWidth = destinationWidth / baseFrameWidth
        let aspectHeight = destinationHeight / baseFrameHeight
        
        let normalizedWidth = cropRect.size.width * aspectWidth
        let normalizedHeight = cropRect.size.height * aspectHeight
        
        let xPositionAspect = (destinationWidth * cropRect.origin.x) / baseFrameWidth
        let yPositionAspect = (destinationHeight * cropRect.origin.y) / baseFrameHeight
        
        let result = CGRect(x: xPositionAspect,
                            y: yPositionAspect,
                            width: normalizedWidth,
                            height: normalizedHeight)
        return result
    }
    
    /// Crop the given image by the given bounding box
    ///
    /// - Parameters:
    ///   - image: Image to crop
    ///   - boundingBox: crop zone
    ///   - outterGap: padding if applies
    ///   - navigationHeaderHeight: navigation header height  if the image is displayed on a view that is under navigation bar
    /// - Returns: cropede image or nil
    static public func crop(
        image:UIImage,
        croppingRect:CGRect) -> UIImage? {

        if let newImage =  image.cgImage?.cropping(to: croppingRect) {
            let cropedImage = UIImage(cgImage: newImage)
            return cropedImage
        }
        return nil
    }
    
    static public func crop(from imageView:UIImageView, extractedObject:ExtractedObject) -> UIImage? {
        guard let extractionFrame = extractedObject.extractionFromFrame else {
            print("ExtractedObject has no extraction frame, projection failed")
            return nil
        }
        
        guard let image = imageView.image else {
            print("ImageView has no image")
            return nil
        }
        
        let imageFrame = CGRect(origin: CGPoint.zero, size: image.size)
        var cropRect = extractedObject.region.toCGRect()
        
        // remove the imageView offset
        // not needed to crop (only to correctly position the box in the screen)
        cropRect.origin = CGPoint(x: cropRect.origin.x - imageView.imageFrame.origin.x,
                                  y: cropRect.origin.y - imageView.imageFrame.origin.y)
        
        // the extracted object is projected on the imageView frame
        // project it to the image frame
        let projected = cropRect.projectOn(projectionFrame:imageFrame,
                                       from: extractionFrame)
        
        // the box is ready, now crop
        let croppedImage = ImageHelper.crop(image: image, croppingRect: projected)
        return croppedImage
    }
}
