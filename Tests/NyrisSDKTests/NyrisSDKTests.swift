//
//  NyrisSDKTests.swift
//  NyrisSDKTests
//
//  Created by MOSTEFAOUI Anas on 15/09/2017.
//  Copyright © 2017 nyris. All rights reserved.
//

import XCTest
import NyrisSDK

class NyrisSDKTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        NyrisClient.instance.setup(clientID: APIKeys.clientID)
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func test_image_matching_cola() {
        
        guard let image = UIImage(named: "product_test_512", in: TestsHelper.bundle, compatibleWith: nil) else {
            fatalError("not found")
        }
        
        let expectations = expectation(description: "product")
        
        let service = ImageMatchingService()
        service.outputFormat = "application/offers.complete+json"
        service.getSimilarProducts(image: image, position: nil, isSemanticSearch: true) { (offers, error) in
            print(offers, error)
            expectations.fulfill()
        }
        wait(for: [expectations], timeout: 40)
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}

