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
        NyrisClient.instance.setup(clientID: APIKeys.clientID)
    }
    
    func test_it_returns_error_if_no_request_id_or_session_id() throws {
        let expectations = expectation(description: "Feedback API - Click")
        let feedbackService = FeedbackService()
        
        feedbackService.sendEvent(eventType: .click(position: [10],
                                                    productIds: ["id1"]),
                                  timestamp: "2022-11-09T15:53:25.511Z",
                                  requestID: "",
                                  sessionID: ""){ (result) in
            if case Result.error(let error,_) = result {
                
                XCTAssert(error is RequestError)
                guard case .invalidInput = (error as? RequestError) else {
                    XCTFail("Error was not invalidInut: \(error.localizedDescription)")
                    return
                }
                expectations.fulfill()
            } else {
                XCTFail("An RequestError.invalidInput error is expected")
            }
        }
        
        wait(for: [expectations], timeout: 5)
    }
    
    func test_it_returns_error_if_empty_timestamp() throws {
        let expectations = expectation(description: "Feedback API - Click")
        let feedbackService = FeedbackService()
        
        feedbackService.sendEvent(eventType: .click(position: [10],
                                                    productIds: ["id1"]),
                                  timestamp: "",
                                  requestID: "2",
                                  sessionID: "2"){ (result) in
            if case Result.error(let error, _) = result {
                
                XCTAssert(error is RequestError)
                guard case .invalidInput = (error as? RequestError) else {
                    XCTFail("Error was not invalidInut: \(error.localizedDescription)")
                    return
                }
                expectations.fulfill()
            } else {
                XCTFail("An RequestError.invalidInput error is expected")
            }
        }
        
        wait(for: [expectations], timeout: 5)
    }
    
    func test_it_returns_error_if_invalid_timestamp() throws {
        let expectations = expectation(description: "Feedback API - Click")
        let feedbackService = FeedbackService()
        
        feedbackService.sendEvent(eventType: .click(position: [10],
                                                    productIds: ["id1"]),
                                  timestamp: "X",
                                  requestID: "2",
                                  sessionID: "2"){ (result) in
            if case Result.error(let error, _) = result {
                
                XCTAssert(error is RequestError)
                guard case .invalidInput = (error as? RequestError) else {
                    XCTFail("Error was not invalidInut: \(error.localizedDescription)")
                    return
                }
                expectations.fulfill()
            } else {
                XCTFail("An InvalidInput error is expected")
            }
        }
        
        wait(for: [expectations], timeout: 5)
    }
    
    func test_it_returns_400_without_valid_content_type() throws {
    }
    
    
    func test_it_returns_no_error_on_successful_request() throws {
        guard let image = UIImage(named: "product_test_512.png", in: TestsHelper.bundle, compatibleWith: nil) else {
            fatalError("not found")
        }
        
        let expectations = expectation(description: "Feedback API - Click")
        let feedbackService = FeedbackService()
        let findService = ImageMatchingService()
        
        findService.match(image: image) { (offersResult, error) in
            XCTAssertNotNil(offersResult)
            XCTAssertNil(error)
            XCTAssertNotNil(offersResult!.sessionID)
            XCTAssertNotNil(offersResult!.requestID)
            XCTAssertFalse(offersResult!.sessionID!.isEmpty)
            XCTAssertFalse(offersResult!.requestID!.isEmpty)
            
            feedbackService.sendEvent(eventType: .click(position: [10],
                                                        productIds: ["id1"]),
                                      timestamp: "2022-11-09T15:53:25.511Z",
                                      requestID: offersResult!.requestID!,
                                      sessionID:offersResult!.sessionID!) { (result) in
                expectations.fulfill()
            }
            
        }
        
        wait(for: [expectations], timeout: 40)
    }
    
    
}
