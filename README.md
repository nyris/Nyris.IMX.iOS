
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


Instalation
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


#### Manualy
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

Example:

```swift
let service = ImageMatchingService()
let image = ... // YOUR UIImage 
let position = ... // Device location (nullable)
let isSemanticSearch = ... // looks for similar products if true, else trigger image matching

service.getSimilarProducts(image: image, position: position, isSemanticSearch: false) { (offerList, error) in
}
```

It will return a list of offers that matches the object in the given image.
**isSemanticSearch** looks for similar products if true, else trigger image matching.

#### Offers format
The default output format is set to **"application/offers.complete+json"**, you can change it by using:
```swift
service.outputFormat = "Your output format"
```
#### Result language
By default, the service will look for offers based on your device language. You can override this behaviour by setting:
```swift
service.accepteLanguage = "EN" //"DE", "FR" ...
```

**Important note:** the provided image must have one size side equal to 512, e.g : 512x400, 200x512. See **ImageHelper section** for more info.

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
#### Result language
By default, the service will look for offers based on your device language. You can override this behaviour by setting:
```swift
service.accepteLanguage = "EN" //"DE", "FR" ...
```

Bounding Boxes Extraction
----------
#### Usage
`ProductExtrationService` service allows you to extract objects bounding boxes for a given image. It will identify objects in the picture.

Example:

```swift
let service = ProductExtractionService()
let image = ... // YOUR UIImage 

service.extractObjects(from: image) { (objects, error) in
}
```

This example will return a list of `ExtractedObject`.

**Important note:** 

 - The provided image must have one size side equal to 512, e.g : 512x400, 200x512. See **ImageHelper section** for more info.
 - The extracted objects are set to image coordinate and not to the screen coordinate. to display boxes on the screen you should scale the boxes to the screen dimension using ImageHelper.


the provided image must have one size side equal to 512, e.g : 512x400, 200x512. See **ImageHelper section** for more info.


Camera Usage
----
NyrisSDK has a built in Camera class that provide image capturing functionalities. You can also use your own camera implementation.

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

#### Start a session
To start the camera session, call the following method:

```swift
cameraManager.start()
```

#### Capture image

Finaly, take a picture by calling the following method:

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


**Importante Note:** If you are using `CameraManager`, you don't need to worry about the next section.


Image Helper
-----
The API require an image with at least one size equal to 512, e.g : 512x200, 400x512.

The pictures taken with `CameraManager` class are automaticly scaled and properly oriented, so if you are using that class, you don't have to worry about image size and rotation.

If you are using your own Camera logic, or another third party camera library, NyrisSDK provide a `ImageHelper` class that provide methods to scale and rotate image.

**Importante note:** Image taken from the iPhone Camera, are in landscape by default, `ImageHelper` provide a way to correct the orientation.

#### Rotate Image
Since the default rotation is landscape, you should rotate the image to your current orientation, to do so, call:


```swift
/// imageData is type of Data
/// useDeviceOrientation, to rotate the image based on device orientation
let image = ImageHelper.corretOrientation(imageData, useDeviceOrientation:true)

```
This will return, a rotatation corrected image.

#### Resize Image
To scale an image, please call the following method:

```swift
// this class will scal down the image to 512x512, it will keep the aspect ratio of the image.
// If the aspect ratio size can not the same as the provided sizethe height value will be re calculated.
ImageHelper.resizeWithRatio(image: image, size: CGSize(width: 512, height: 512))

```

the `ImageHelper.resizeWithRatio` method, will try to scale the image to the provided size, while keeping the aspect ratio. If the aspect ratio can't be respected, it will recalculate the height value, to keep the aspect ratio.

#### Scale bounding boxes
