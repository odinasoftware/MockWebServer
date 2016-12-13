//
//  TestMockServer.swift
//  MockWebServer
//
//  Created by Jae Han on 12/10/16.
//  Copyright © 2016 jaehan. All rights reserved.
//

import XCTest
import MockWebServer

class TestMockServer: XCTestCase {
    
    var mockWebServer: MockWebServer = MockWebServer()
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        mockWebServer.start()
        
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        mockWebServer.start()
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
