//
//  BoundingBoxesScalingTests.swift
//  NyrisSDKTests
//
//  Created by MOSTEFAOUI Anas on 02/02/2018.
//  Copyright © 2018 nyris. All rights reserved.
//

import XCTest
import NyrisSDK
import AVFoundation

class BoundingBoxesScalingTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        guard let image = UIImage(named: "product_test_512", in: TestsHelper.bundle, compatibleWith: nil) else {
            fatalError("not found")
        }
        
        let frame = CGRect(x: 0, y: 0, width: 600, height: 600)
        print(image.size)
        
        let imageView = UIImageView(frame: frame)
        imageView.image = image
        imageView.contentMode = .scaleToFill
        print(imageView.image?.size)
        
        imageView.contentMode = .scaleAspectFit
        print(image.size)
        
        XCTAssert(true)
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
