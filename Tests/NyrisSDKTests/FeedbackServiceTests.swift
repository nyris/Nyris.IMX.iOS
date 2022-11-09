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
        
        feedbackService.sendEvent(eventType: .click(positions: [10],
                                                    productIds: ["id1"]),
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
    
    func test_it_returns_error_if_invalid_timestamp() throws {
        let expectations = expectation(description: "Feedback API - Click")
        let feedbackService = FeedbackService()
        
        feedbackService.sendEvent(eventType: .click(positions: [10],
                                                    productIds: ["id1"]),
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
    
    
    func test_it_returns_no_error_on_successful_click_event() throws {
        guard let image = UIImage(named: "product_test_512.png", in: TestsHelper.bundle, compatibleWith: nil) else {
            fatalError("not found")
        }
        
        let expectations = expectation(description: "Feedback API - Click")
        let feedbackService = FeedbackService()
        let findService = ImageMatchingService()
        
        findService.match(image: image) { (offersResult, matchError) in
            XCTAssertNotNil(offersResult)
            XCTAssertNil(matchError)
            XCTAssertNotNil(offersResult!.sessionID)
            XCTAssertNotNil(offersResult!.requestID)
            XCTAssertFalse(offersResult!.sessionID!.isEmpty)
            XCTAssertFalse(offersResult!.requestID!.isEmpty)
        
            feedbackService.sendEvent(eventType: .click(positions: [0],
                                                        productIds: [offersResult!.products[0].oid]),
                                      requestID: offersResult!.requestID!,
                                      sessionID:offersResult!.sessionID!) { (result) in
                if case .error(let error,_) = result {
                    XCTFail("Request has an error \(error.localizedDescription)")
                }
                expectations.fulfill()
            }
        }
        wait(for: [expectations], timeout: 140)
    }
    
    func test_it_returns_no_error_on_successful_conversion_event() throws {
        guard let image = UIImage(named: "product_test_512.png", in: TestsHelper.bundle, compatibleWith: nil) else {
            fatalError("not found")
        }
        
        let expectations = expectation(description: "Feedback API - conversion")
        let feedbackService = FeedbackService()
        let findService = ImageMatchingService()
        
        findService.match(image: image) { (offersResult, matchError) in
            XCTAssertNotNil(offersResult)
            XCTAssertNil(matchError)
            XCTAssertNotNil(offersResult!.sessionID)
            XCTAssertNotNil(offersResult!.requestID)
            XCTAssertFalse(offersResult!.sessionID!.isEmpty)
            XCTAssertFalse(offersResult!.requestID!.isEmpty)
        
            feedbackService.sendEvent(eventType: .conversion(positions: [0],
                                                        productIds: [offersResult!.products[0].oid]),
                                      requestID: offersResult!.requestID!,
                                      sessionID:offersResult!.sessionID!) { (result) in
                if case .error(let error,_) = result {
                    XCTFail("Request has an error \(error.localizedDescription)")
                }
                expectations.fulfill()
            }
        }
        wait(for: [expectations], timeout: 140)
    }
    
    func test_it_returns_no_error_on_successful_user_feedback_event() throws {
        guard let image = UIImage(named: "product_test_512.png", in: TestsHelper.bundle, compatibleWith: nil) else {
            fatalError("not found")
        }
        
        let expectations = expectation(description: "Feedback API - conversion")
        let feedbackService = FeedbackService()
        let findService = ImageMatchingService()
        
        findService.match(image: image) { (offersResult, matchError) in
            XCTAssertNotNil(offersResult)
            XCTAssertNil(matchError)
            XCTAssertNotNil(offersResult!.sessionID)
            XCTAssertNotNil(offersResult!.requestID)
            XCTAssertFalse(offersResult!.sessionID!.isEmpty)
            XCTAssertFalse(offersResult!.requestID!.isEmpty)
        
            feedbackService.sendEvent(eventType: .feedback(success: true, comment: "it worked"),
                                      requestID: offersResult!.requestID!,
                                      sessionID:offersResult!.sessionID!) { (result) in
                if case .error(let error,_) = result {
                    XCTFail("Request has an error \(error.localizedDescription)")
                }
                expectations.fulfill()
            }
        }
        wait(for: [expectations], timeout: 140)
    }
    
    func test_it_returns_error_if_rect_is_not_normalized_region_event() throws {
        let expectations = expectation(description: "Feedback API - conversion")
        let feedbackService = FeedbackService()
        feedbackService.sendEvent(eventType: .region(rect: CGRect(x: 100, y: 0, width: 200, height: 1)),
                                  requestID: "id",
                                  sessionID: "id") { (result) in
            if case Result.error(let error, _) = result {
                XCTAssert(error is RequestError)
                guard case .invalidInput = (error as? RequestError) else {
                    XCTFail("Error was not invalidInut: \(error.localizedDescription)")
                    return
                }
                expectations.fulfill()
            } else {
                XCTFail("An InvalidInput error is expected")
                expectations.fulfill()
            }
        }
        
        wait(for: [expectations], timeout: 5)
    }
    
    func test_it_returns_no_error_on_successful_region_event() throws {
        guard let image = UIImage(named: "product_test_512.png", in: TestsHelper.bundle, compatibleWith: nil) else {
            fatalError("not found")
        }
        
        let expectations = expectation(description: "Feedback API - conversion")
        let feedbackService = FeedbackService()
        let findService = ImageMatchingService()
        
        findService.match(image: image) { (offersResult, matchError) in
            XCTAssertNotNil(offersResult)
            XCTAssertNil(matchError)
            XCTAssertNotNil(offersResult!.sessionID)
            XCTAssertNotNil(offersResult!.requestID)
            XCTAssertFalse(offersResult!.sessionID!.isEmpty)
            XCTAssertFalse(offersResult!.requestID!.isEmpty)
        
            feedbackService.sendEvent(eventType: .region(rect: CGRect.zero),
                                      requestID: offersResult!.requestID!,
                                      sessionID: offersResult!.sessionID!) { (result) in
                if case .error(let error,_) = result {
                    XCTFail("Request has an error \(error.localizedDescription)")
                }
                expectations.fulfill()
            }
        }
        wait(for: [expectations], timeout: 140)
    }
    
}
