# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/en/1.0.0/)
and this project adheres to [Semantic Versioning](http://semver.org/spec/v2.0.0.html).

## 0.7.1
- Explicitly set the image content mode to `scaleAspectFill` in CameraManager's method`takeScreenshoot`.
- Ensure capturing session start and stop will run on a background queue.
- Add normalization method to `Rectangle` structure  .

## 0.7.0
- Added Filtering API.

## 0.6.0
- Added Feedback API
- Services that used to returns an array of Offer will now return OfferResult (ImageMatchingService, SearchService).
- OfferResult now contains requestID and sessionID to be used with Feedback API and ImageMatchingService.
- Fix a bug in deserialization of Offer when customIds contains a property with null as a value.  
- Add the ability to use different endpoints.
- Add HeaderMapper protocol to allow mapping of headers entries if the SDK is used with a proxy.
- Remove unused code from URLBuilder.
- Expose default endpoints via NyrisDefaultEndpoints.
- Rename Endpoints structure to NyrisDefaultEndpoints.
- Rename LiveEndpoints to NyrisLiveEndpoints.
- Remove EnvironmentMode enum and it's usage.
- Rely on NyrisClient singleton to provide EndpointsProvider to services.
- Remove NyrisLiveEndpoints structure.
## 0.5.0 - 08.09.2022
- Migrate region API to V2.
- Change deprecated AVVideoCodecJPEG to use AVVideoCodecType.jpeg instead.
- Add swiftlint support for M1 architecture in build phases.
- Set minimum deployment target to be iOS 12.
- Delete internal SDK target.

## 0.4.6 - 20.06.2022
### Added
- Add support for Swift package manager.
### Modified
- Change class to AnyObject in Protocole conformance.

## 0.4.5.1 - 13.12.2020
### Modified
- Use 1024x1024 as default resizing size on resizeWithRatio.

## 0.4.5 - 31.10.2020
### Modified
- Convert the SDK to Swift 5.x
- Use area based resize algorithm to resize images to a server-valid dimension.
- Enforced explicit access Control Level
- Add class and method comments

## 0.4.4 - 14.03.2019
### Added
- Add `useDeviceRotation` as default parameter to Camera manager setup method to subscribe to device orientation.

### Modified
- Fix typo in CaptureMode enum case : from `continus` to `continuous`
- Fix typo in CameraConfiguration.swift : from `func codebarScanConfiguration` to `func barcodeScanConfiguration`.
- Fix typo in BaseAPIRequest.swift : from `var accepteLanguage` to `var acceptLanguage`
- Fix typo in EnvironmentMode.swift : from `case developement` to `case development`
- Fix typo in URLBuilder.swift : from `func appendQueryParametre` to `func appendQueryParameter`
- Fix typo in URLBuilder.swift : from `func appendQueriesParametres` to `func appendQueriesParameters`
- Rename `CodebarScannerDelegate.swift` file to `BarcodeScannerDelegate.swift`
- Rename `ProductExtrationService.swift` file to `ProductExtractionService.swift`
- Rename protocol `protocol CodebarScannerDelegate` to `protocol BarcodeScannerDelegate` in `BarcodeScannerDelegate.swift` file
- Rename class `class CodebarScanner` to `class BarcodeScanner` in `BarcodeScannerDelegate.swift` file
- Rename class `class CodebarScanner` to `class BarcodeScanner` in `BarcodeScannerDelegate.swift` file
- Fix typo in `ProductExtractionService.swift` : from `func parseExtractionRespone` to `func parseExtractionResponse`
