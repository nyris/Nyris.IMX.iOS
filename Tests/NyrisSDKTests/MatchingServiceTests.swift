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
        
        service.match(image: image) { (product, error) in
            XCTAssertNotNil(error)
            XCTAssertNil(product)
            
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
        service.acceptLanguage = "*"
        service.match(image: image) { (offersResult, error) in
            XCTAssertNotNil(offersResult)
            XCTAssertFalse(offersResult!.products.isEmpty)
            XCTAssertNil(error)
            expectations.fulfill()
        }
        wait(for: [expectations], timeout: 40)
    }
    
    // XOPTION tests
    
    func test_it_can_use_default_search_mode_with_results() {
        guard let image = UIImage(named: "product_test_512.png", in: TestsHelper.bundle, compatibleWith: nil) else {
            fatalError("not found")
        }
        
        let expectations = expectation(description: "Expected 10 items")
        let service = ImageMatchingService()
        let limit = 20
        service.xOptions = "default"
        
        service.match(image: image) { (offersResult, error) in
            XCTAssertNotNil(offersResult)
            XCTAssertNil(error)
            XCTAssertLessThanOrEqual(offersResult!.products.count, limit)
            
            expectations.fulfill()
            
        }
        wait(for: [expectations], timeout: 40)
    }
    
    func test_it_can_limit_offers_to_10() {
        guard let image = UIImage(named: "product_test_512.png", in: TestsHelper.bundle, compatibleWith: nil) else {
            fatalError("not found")
        }

        let expectations = expectation(description: "Expected 10 items")
        let service = ImageMatchingService()
        let limit = 10
        service.xOptions = "exact +similarity +ocr limit=\(limit)"
        
        service.match(image: image) { (offersResult, error) in
            XCTAssertNotNil(offersResult)
            XCTAssertNil(error)
            XCTAssertLessThanOrEqual(offersResult!.products.count, limit)
            
            expectations.fulfill()
            
        }
        wait(for: [expectations], timeout: 40)
    }
    
    func test_it_can_use_exact_search_mode_with_no_offers() {
        guard let image = UIImage(named: "product_test_512.png", in: TestsHelper.bundle, compatibleWith: nil) else {
            fatalError("not found")
        }
        
        let expectations = expectation(description: "Expected no items")
        let service = ImageMatchingService()
        service.xOptions = "exact"
        
        service.match(image: image) { (offersResult, error) in
            XCTAssertNotNil(offersResult)
            XCTAssertNil(error)
            XCTAssertEqual(offersResult!.products.count, 0)
            
            expectations.fulfill()
            
        }
        wait(for: [expectations], timeout: 40)
    }
    
    func test_it_can_use_similarity_search_mode_limited_3_offers() {
        guard let image = UIImage(named: "product_test_512.png", in: TestsHelper.bundle, compatibleWith: nil) else {
            fatalError("not found")
        }
        
        let expectations = expectation(description: "Expected 3 items")
        let service = ImageMatchingService()
        let limit = 3
        service.xOptions = "similarity limit=\(limit)"
        
        service.match(image: image) { (offersResult, error) in
            XCTAssertNotNil(offersResult)
            XCTAssertNil(error)
            XCTAssertEqual(offersResult!.products.count, limit)
            
            expectations.fulfill()
            
        }
        wait(for: [expectations], timeout: 40)
    }
    
    
    func test_it_can_use_similarity_search_mode_limited_2_offers() {
        guard let image = UIImage(named: "product_test_512.png", in: TestsHelper.bundle, compatibleWith: nil) else {
            fatalError("not found")
        }
        
        let expectations = expectation(description: "Expected no items")
        let service = ImageMatchingService()
        let limit = 2
        service.xOptions = "similarity limit=\(limit)"
        
        service.match(image: image) { (offersResult, error) in
            XCTAssertNotNil(offersResult)
            XCTAssertNil(error)
            XCTAssertEqual(offersResult!.products.count, limit)
            
            expectations.fulfill()
            
        }
        wait(for: [expectations], timeout: 40)
    }
    
    
    func test_if_similarityThreshold_090_returns_1_offers() {
        guard let image = UIImage(named: "product_test_512.png", in: TestsHelper.bundle, compatibleWith: nil) else {
            fatalError("not found")
        }
        
        let expectations = expectation(description: "Expected no items")
        let service = ImageMatchingService()
        let similarityThreshold = 0.90
        let limit = 1
        
        service.xOptions = "similarity similarity.threshold=\(similarityThreshold)"
        
        service.match(image: image) { (offersResult, error) in
            XCTAssertNotNil(offersResult)
            XCTAssertNil(error)
            XCTAssertEqual(offersResult!.products.count, limit)
            
            expectations.fulfill()
            
        }
        wait(for: [expectations], timeout: 40)
    }
    
    func test_it_can_use_ocr_search_mode_with_no_offers() {
        guard let image = UIImage(named: "product_test_512.png", in: TestsHelper.bundle, compatibleWith: nil) else {
            fatalError("not found")
        }
        
        let expectations = expectation(description: "Expected no items")
        let service = ImageMatchingService()
        service.xOptions = "ocr"
        
        service.match(image: image) { (offersResult, error) in
            XCTAssertNotNil(offersResult)
            XCTAssertNil(error)
            XCTAssertEqual(offersResult!.products.count, 0)
            
            expectations.fulfill()
            
        }
        wait(for: [expectations], timeout: 40)
    }
    
    func test_it_can_add_session_id_to_query() {
        guard let image = UIImage(named: "product_test_512.png", in: TestsHelper.bundle, compatibleWith: nil) else {
            fatalError("not found")
        }
        
        let expectations = expectation(description: "Expected no items")
        let service = ImageMatchingService()
        service.match(image: image) { (offersResult, error) in
            XCTAssertNotNil(offersResult)
            XCTAssertNil(error)
            XCTAssertNotNil(offersResult!.sessionID)
            
            expectations.fulfill()
            
        }
        wait(for: [expectations], timeout: 40)
        
    }
    
    func test_it_can_use_filters() {
        guard let image = UIImage(named: "product_test_512.png", in: TestsHelper.bundle, compatibleWith: nil) else {
            fatalError("not found")
        }
        
        let expectations = expectation(description: "Expected no items")
        let service = ImageMatchingService()
        service.filters = [
            NyrisSearchFilter(type: "color", values: ["red", "blue", "brown"]),
//            NyrisSearchFilter(type: "size", values: ["small", "large"]),
        ]
        service.match(image: image) { (offersResult, error) in
            XCTAssertNotNil(offersResult)
            XCTAssertNil(error)
            XCTAssertEqual(offersResult!.products.count, 0)
            
            expectations.fulfill()
            
        }
        wait(for: [expectations], timeout: 40)
        
    }
}
