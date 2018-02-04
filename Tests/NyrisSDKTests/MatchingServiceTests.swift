//
//  MatchingServiceTests.swift
//  NyrisSDKTests
//
//  Created by MOSTEFAOUI Anas on 02/02/2018.
//  Copyright © 2018 nyris. All rights reserved.
//

import XCTest
import NyrisSDK

class MatchingServiceTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        NyrisClient.instance.setup(clientID: APIKeys.clientID)
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func test_image_too_small_size_should_fail() {
        guard let image = UIImage(named: "product_test_510", in: TestsHelper.bundle, compatibleWith: nil) else {
            fatalError("not found")
        }
        
        let expectations = expectation(description: "invalid size: size too small")
        let service = ImageMatchingService()
        
        service.match(image: image) { (offers, error) in
            XCTAssertNotNil(error)
            XCTAssertNil(offers)
            
            switch error! {
            case ImageError.invalidSize(let message):
                XCTAssertTrue(true, message)
            default:
                XCTFail()
            }
            expectations.fulfill()
            
        }
        wait(for: [expectations], timeout: 40)
    }
    
    func test_image_one_side_512_should_succeed() {
        guard let image = UIImage(named: "product_test_512.png", in: TestsHelper.bundle, compatibleWith: nil) else {
            fatalError("not found")
        }
        
        let expectations = expectation(description: "Image matching returns products")
        
        let service = ImageMatchingService()
        // any language is fine here
        service.accepteLanguage = "*"
        service.match(image: image) { (offers, error) in
            XCTAssertNotNil(offers)
            XCTAssertFalse(offers!.isEmpty)
            XCTAssertNil(error)
            expectations.fulfill()
        }
        wait(for: [expectations], timeout: 40)
    }
}
