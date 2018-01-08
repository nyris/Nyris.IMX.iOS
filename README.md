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
* Image helper to manipulate raw camera images


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

for swift 3.2

`  pod 'NyrisSDK', :git => 'https://github.com/nyris/Nyris.IMX.iOS.git', :branch => 'feature/swift3.2'`

#### Carthage
Write the following on your Cartfile:
`github "nyris/Nyris.IMX.iOS"`


#### Swift package manager
To do


#### Manualy
Copy *.swift files to your project.


Usage
-----
Start by setting up your NyrisClient shared instance:

```swift
NyrisClient.instance.setup(clientID: YOUR-CLIENT-ID, clientSecret: YOUR-CLIENT-SECRET)
```

#### ImageMatching

You can use the `ImageMatchingService` class to request products that matches a product in a picture.

Example:

```swift

let service = ImageMatchingService()
let image = ... // YOUR UIImage

service.getSimilarProducts(image: image, position: position, isSemanticSearch: false) { [weak self] (offerList, error) in

}
```

It will return a list of products that matches the provided image.

isSemanticSearch looks for similar products if true, else trigger image matching.

The default output format is set to ***"application/offers.complete+json"***, you can change it by using:
```swift
let service = ImageMatchingService()
service.outputFormat = "Your output format")
```

**Important note:** the provided image must have one size side equal to 512, e.g : 512x400, 200x512. See **ImageHelper section** for more info.


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
