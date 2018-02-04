//
//  ImageHelperTests.swift
//  NyrisSDKTests
//
//  Created by MOSTEFAOUI Anas on 02/02/2018.
//  Copyright © 2018 nyris. All rights reserved.
//

import XCTest
import NyrisSDK

class ImageHelperTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func test_prepare_less_than_512_width_image_fails() {
        guard let image = UIImage(named: "product_test_510", in: TestsHelper.bundle, compatibleWith: nil) else {
            fatalError("not found")
        }
        
        let (preparedImage, error) = ImageHelper.prepareImage(image: image, useDeviceOrientation: false)
        XCTAssertNotNil(error)
        XCTAssertNil(preparedImage)
        switch error! {
        case ImageError.invalidSize(let message):
            XCTAssertTrue(true, message)
        default:
            XCTFail()
        }
    }
    
    func test_prepare_512_width_image_succeed() {
        guard let image = UIImage(named: "product_test_512", in: TestsHelper.bundle, compatibleWith: nil) else {
            fatalError("not found")
        }
        
        let (preparedImage, error) = ImageHelper.prepareImage(image: image)
        XCTAssertNotNil(preparedImage)
        XCTAssertNil(error)
    }
    
    func test_prepare_512_width_image_dont_scale_succeed() {
        guard let image = UIImage(named: "product_test_512", in: TestsHelper.bundle, compatibleWith: nil) else {
            fatalError("not found")
        }
        
        let (preparedImage, error) = ImageHelper.prepareImage(image: image)
        XCTAssertNotNil(preparedImage)
        XCTAssertNil(error)
        let sameWidth = preparedImage!.size.width == image.size.width
        let sameHeight = preparedImage!.size.height == image.size.height
        XCTAssertTrue(sameWidth, "The image has the same width")
        XCTAssertTrue(sameHeight, "The image has the same height")
    }
    
    func test_prepare_612_width_image_scale_succeed() {
        guard let image = UIImage(named: "product_test_612", in: TestsHelper.bundle, compatibleWith: nil) else {
            fatalError("not found")
        }
        
        // image size : 612x1085
        // expected size: 512x908
        
        let (preparedImage, error) = ImageHelper.prepareImage(image: image)
        XCTAssertNotNil(preparedImage)
        XCTAssertNil(error)
        XCTAssertTrue(preparedImage!.size.width == 512, "The image has width = 512")
        XCTAssertTrue(preparedImage!.size.height == 908, "The image has width = 512")
        
        let smallerWidth = preparedImage!.size.width < image.size.width
        let smallHeight = preparedImage!.size.height < image.size.height
        XCTAssertTrue(smallerWidth, "The image has smaller width")
        XCTAssertTrue(smallHeight, "The image has smaller height")
    }
    
}
