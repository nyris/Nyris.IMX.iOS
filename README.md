
Nyris Image Matching SDK for iOS
=======


Introduction
------

Nyris Image Matching SDK for iOS (NyrisSDK)  allows the usage of ImageMatching service that provides a list of products from a given image.

For more information please see [nyris.io](https://nyris.io]/)

Features
-----
* Built in camera manager class.
* Provides 100% matching for taken pictures products.
* Provides textual search.
* Provides Bounding box extraction from a picture.
* Image helper to manipulate raw camera images.


Minimal requirements
-----
* Xcode 9
* Swift 4
* Minimum deployment target is iOS 9.

**Note**: for swift 3.2 please use 'feature/swift3.2' branch


Installation
-----

#### Cocoapods

Nyris Image Matching SDK (NyrisSDK) is available through CocoaPods. To install it, simply add the following line to your Podfile:

`pod "NyrisSDK"`

For swift 3.2

`  pod 'NyrisSDK', :git => 'https://github.com/nyris/Nyris.IMX.iOS.git', :branch => 'feature/swift3.2'`

#### Carthage
Write the following on your Cartfile:
`github "nyris/Nyris.IMX.iOS"`


#### Swift package manager
To do


#### Manually
Copy *.swift files to your project.


Setup
-----
Start by setting up your NyrisClient shared instance:

```swift
NyrisClient.instance.setup(clientID: YOUR-CLIENT-ID)
```

ImageMatching
----------
#### Usage
`ImageMatchingService` service allows you to get a list of offers that matches a product in a picture.

A very simple example:

```swift
let service = ImageMatchingService()
let image = ... // YOUR UIImage (at least 512 width or height)

service.getSimilarProducts(image: image) { (offerList, error) in
// you are on the main thread
}
```

It will return a list of offers that matches the objects in the given image.


If you don't want to deal with image scaling/rotating, you can use the match method, it will prepare the given image for you, e.g :
```swift
let service = ImageMatchingService()
let image = ... // YOUR UIImage (e.g: 1024x1024)

// The match method will create a scaled down (512x512) image copy
service.match(image: image) { (offerList, error) in
// you are on the main thread
}
```

In case you are taking a picture from camera, you can use the match method to correctly rotate and scale the image by enabling useDeviceOrientation parameter, e.g:
```swift
let service = ImageMatchingService()
let image = ... // UIImage coming from camera

// The image will be rotated to portrait mode and scaled down
service.match(image: image, useDeviceOrientation:true) { (offerList, error) in
// you are on the main thread
}
```

If you are using UIImageView, an extension method is available:
```swift
imageView.match { (offers, error) in
    // you are on the main thread
}
```
**Note**: Make sure you set your SDK client before calling any UIImageView extension methods.

#### Search type
Both `getSimilarProducts` and `match` method allow different type of search through their parameters:
* isSemanticSearch: enable MESS search only
* isFirstStageOnly: enable exact match

#### Offers format
The default output format is set to **"application/offers.complete+json"**, you can change it by using:
```swift
service.outputFormat = "Your output format"
```

#### Additional Header Attributes
There are additional header attributes you can use to change the results.

```swift
service.xOptions = "default"
```
 You can find all the additional header attributes [here](https://docs.nyris.io/#additional-header-attributes).


#### Result language
By default, the service will look for offers for all available languages. You can override this behaviour by setting:
```swift
service.acceptLanguage = "EN" //"DE", "FR" ...
```

To set it to the device language :
```swift
service.acceptLanguage = (Locale.current as NSLocale).object(forKey: .languageCode) as? String ?? "*"
```

**Important note:** the provided image must have width or height at equal to least 512, e.g : 512x400, 200x512. See **ImageHelper section** for more info.

Textual search
----------
#### Usage
`SearchService` service allows you to get a list of offers that matches a textual query.

Example:

```swift
let service = SearchService()
service.search(query: "water") { (offers, error) in
}
```

This example will return a list of offers that matches the query.

#### Offers format
The default output format is set to **"application/offers.complete+json"**, you can change it by using:
```swift
service.outputFormat = "Your output format"
```

#### Additional Header Attributes
There are additional header attributes you can use to change the results.

```swift
service.xOptions = "default"
```
 You can find all the additional header attributes [here](https://docs.nyris.io/#additional-header-attributes).

#### Result language
By default, the service will look for offers for all available languages. You can override this behaviour by setting:
```swift
service.acceptLanguage = "EN" //"DE", "FR" ...
```

To set it to the device language :
```swift
service.acceptLanguage = (Locale.current as NSLocale).object(forKey: .languageCode) as? String ?? "*"
```

Bounding Boxes Extraction
----------
#### Usage
`ProductExtractionService` service allows you to extract objects bounding boxes for a given image. It will identify objects in the picture.

Basic example:

```swift
let service = ProductExtractionService()
let image = ... // Your UIImage (at least 512 width or height)
let displayFrame = displayView.frame

service.extractObjects(from image:image, displayFrame:displayFrame) { (boxes, error) in
// Main thread
}
```
This  will return a list of `ExtractedObject` extracted from the given image, and already projected to the displayFrame. It can be directly displayed on screen without any further manipulation.



If you are using UIImageView, an extension method is available:
```swift
imageView.extractProducts { (objects, error) in
    // you are on the main thread
}
```
The method support all contentMode value that does not modify the image aspect ratio, e.g:
* `.scaleAspectFit`
* `.scaleAspectFill`
* `.center`

Notice that in case of `.center` or `.scaleAspectFill`, you may have boxes with out of screen origin.

#### Cropping
To crop an image region based on `ExtractedObject`, use :
```swift
let croppedImage = ImageHelper.crop(from: self.imageView,
                                        extractedObject: box)
```
You can then send this croppedImage image to the matching service.

**Important !**
The imageView.image must be the same image used to extract the boxes without any size modification.
The box should be already projected to the screen. if you want to crop boxes that were not projected (original API result) please see ImageHelper cropping section.

#### Flexible usage
If you don't want any modifications (projections) to the result from the server, use `getExtractObjects`:

```swift
let service = ProductExtractionService()
let image = ... // YOUR UIImage (at least 512 width or height)

service.getExtractObjects(from: image) { (objects, error) in
// Main thread
}
```

This example will return a list of `ExtractedObject` extracted from the given image. These cannot be displayed on the screen without projecting the regions from the image frame (0,0,image.width, image.height) to the desired display frame.

You can project an `ExtractedObject` to a display frame using :
```swift
let box:ExtractedObject = // Your extracted object
let extractionFrame = CGRect(origin: CGPoint.zero, size: imageSource.size)
let displayFrame:CGRect = // e.g: UIImageView frame
let projectedObject = box.projectOn(projectionFrame: displayFrame,
                                    from: extractionFrame)
```

**Important notes:**

The provided image must have width or height at equal to least 512, e.g : 512x400, 200x512.

See **ImageHelper section** for more info on how to project `ExtractedObject` region to a different frame.


Camera Usage
----
NyrisSDK has a built in Camera class that provide image capturing functionality. You can also use your own camera implementation.

Use the following code to create CameraManager instance

#### Setup Camera Manager
```swift
lazy var cameraManager: CameraManager = {
    let configuration = CameraConfiguration(metadata: [],
    captureMode: .none, sessionPresent: SessionPreset.high)

    return CameraManager(configuration: configuration)
}()
```

#### Request usage permission
Then, request the Camera usage permission, and display the camera view when permission is granted:

```swift
if cameraManager.permission != .authorized {
    cameraManager.updatePermission()
} else {
    cameraManager.setup()
    cameraManager.display(on: self.cameraView)
}

```

#### Subscribe to device rotation
If you want the video preview and the image to be rotated when device rotation change, set the camera manager optional `useDeviceRotation` to true

```swift
if cameraManager.permission != .authorized {
    /// ...
} else {
    cameraManager.setup(useDeviceRotation: true)
    /// ...
}

```

#### Start a session
To start the camera session, call the following method:

```swift
cameraManager.start()
```

#### Capture image

Finally, take a picture by calling the following method:

```swift
cameraManager.takePicture { [weak self] image in
    // handle the picture
}
```

#### Stop a session
When you are not using the camera any more, or if the app is in background mode, call stop method:

```swift
self.cameraManager.stop()
```

#### Permission update
The camera usage permission can be changed by the user at any time, to handle this, you need to conform to `CameraAuthorizationDelegate` protocol.

```swift

class CameraController  {

    override func viewDidAppear(_ animated: Bool) {
        /// code
        self.cameraManager.authorizationDelegate  = self
    }
}

extension CameraController : CameraAuthorizationDelegate {

    func didChangeAuthorization(cameraManager: CameraManager, authorization: SessionSetupResult) {
        switch authorization {
        case .authorized:
            if self.cameraManager.isRunning == false {
                self.cameraManager.setup()
            }
            self.cameraManager.display(on: self.cameraView)
        default:
            ///showError(message: "Please authorize camera access to use this app"
        }
    }
}
```

**Important note:** Make sur to add NSCameraUsageDescription Or  Privacy - Camera usage description to your plist file. Otherwise your app will crash if you try to access the camera on iOS 10 or above.


**Important Note:** If you are using `CameraManager`, you don't need to worry about the next section.


Image Helper
-----
The API require an image with at least one size equal to 512, e.g : 512x200, 400x512.

The pictures taken with `CameraManager` class are automatically scaled and properly oriented, so if you are using that class, you don't have to worry about image size and rotation.

If you are using your own Camera logic, or another third party camera library, NyrisSDK provide a `ImageHelper` class that provide methods to scale and rotate image.

**Important note:** Image taken from the iPhone Camera, are in landscape by default, `ImageHelper` provide a way to correct the orientation.

#### Prepare Image
The prepare method abstract the resizing and rotating of an camera image, you can use it as follow:
```swift
let (preparedImage, error) = ImageHelper.(image:cameraImage,  useDeviceOrientation:true)

```
This will return a tuple containing the prepared image and an error, both nullable. so make sure that the method didn't fail.
The prepared image will be scaled and rotated.

If you want more flexibility, you can read the following sections.

#### Rotate Image
Since the default rotation is landscape, you should rotate the image to your current orientation, to do so, call:


```swift
/// imageData is type of Data
/// useDeviceOrientation, to rotate the image based on device orientation
let image = ImageHelper.correctOrientation(imageData, useDeviceOrientation:true)

```
This will return, a rotation corrected image.

#### Resize Image
To scale an image, please call the following method:

```swift
// this class will scale down the image to 512x512, it will keep the aspect ratio of the image. and guarantee that one side is 512.
ImageHelper.resizeWithRatio(image: image, size: CGSize(width: 512, height: 512))

```

the `ImageHelper.resizeWithRatio` method, will try to scale the image to the provided size, while keeping the aspect ratio. If the aspect ratio can't be respected, it will recalculate the height value, to keep the aspect ratio.

#### Bounding boxes projection
If you send `ProductExtractionService` an 512x900 image, the service will return `ExtractedObject` that identify object in the image dimension (512x900), let's suppose that we got a bounding box :
 - x : 30
 - y: 40
 - width: 100
 - height: 140

This value will not be correct if projected on device screen, to correctly display this boxes on the device screen we need to project the bounding box to screen dimension using:

```swift
let scaledRectangle = ImageHelper.applyRectProjection(
            on: self, // 1
            from: baseFrame, // 2
            to: projectionFrame, // 3
            padding: 0, // 4
            navigationHeaderHeight: 0) //5
```
 1. The rectangle we want to project on a different frame.
 2. The frame that we want to project from : e.g : (0,0, image.width, image.height)
 3. The frame that we want to project to : a UIImageView frame
 4. Padding if needed.
 5. Navigation header if needed to avoid unnecessary Y offset.

This will return a bounding box ready to be displayed on the device screen.

#### Bounding boxes cropping

If you have an `ExtractedObject` projected on an UIImageView (or any other view), you can crop using :

```swift
let crop = ImageHelper.crop(from: self.imageView,
                                        extractedObject: box)
```

If you did request `ExtractedObject` using `getExtractObjects` method, and you want to crop without any projection use :

```swift
let rect = box.region.toCGRect()
let crop =  ImageHelper.crop(image: image, croppingRect: rect)
```
