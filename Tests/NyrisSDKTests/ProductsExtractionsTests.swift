//
//  ProductsExtractionsTests.swift
//  NyrisSDKTests
//
//  Created by MOSTEFAOUI Anas on 09/01/2018.
//  Copyright © 2018 nyris. All rights reserved.
//

import XCTest
import NyrisSDK

class ProductsExtractionsTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        NyrisClient.instance.setup(clientID: APIKeys.clientID)
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func test_bounding_box_extraction() {
        
        guard let image = UIImage(named: "product_test_512", in: TestsHelper.bundle, compatibleWith: nil) else {
            fatalError("not found")
        }
        
        let expectations = expectation(description: "product")
        
        let service = ProductExtractionService()
        service.extractObjects(from: image) { (objects, error) in
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
