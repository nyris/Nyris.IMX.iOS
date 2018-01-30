//
//  SearchServiceTests.swift
//  NyrisSDK
//
//  Created by MOSTEFAOUI Anas on 21/01/2018.
//  Copyright © 2018 nyris. All rights reserved.
//

import XCTest
import NyrisSDK

class SearchServiceTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        NyrisClient.instance.setup(clientID: APIKeys.clientID)
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func test_search_valid_query() {
        
        let expectations = expectation(description: "product")
        
        let service = SearchService()
        service.outputFormat = "application/offers.complete+json"
        service.search(query: "coca") { (offers, error) in
            print(offers, error)
            expectations.fulfill()
        }
        wait(for: [expectations], timeout: 40)
    }
    
}

