//
//  FeedbackServiceTests.swift
//  NyrisSDKTests
//
//  Created by MOSTEFAOUIM on 08/11/2022.
//  Copyright © 2022 nyris. All rights reserved.
//

import XCTest
import NyrisSDK

final class FeedbackServiceTests: XCTestCase {

    override func setUpWithError() throws {
        NyrisClient.instance.setup(clientID: APIKeys.clientID)
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func test_bounding_box_extraction() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        // Any test you write for XCTest can be annotated as throws and async.
        // Mark your test throws to produce an unexpected failure when your test encounters an uncaught error.
        // Mark your test async to allow awaiting for asynchronous code to complete. Check the results with assertions afterwards.
        guard let image = UIImage(named: "product_test_512", in: TestsHelper.bundle, compatibleWith: nil) else {
            fatalError("not found")
        }
        
        let expectations = expectation(description: "product")
        
        let service = ProductExtractionService()
        service.getExtractObjects(from: image) { (objects, error) in
            expectations.fulfill()
        }
        wait(for: [expectations], timeout: 40)
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
