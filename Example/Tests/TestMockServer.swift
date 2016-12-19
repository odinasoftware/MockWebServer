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
        mockWebServer.stop()
    }
    
    func testResponse() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        let dispatchMap: DispatchMap = DispatchMap()
        let dispatch: Dispatch = Dispatch()
        
        dispatch.requestContain("test")
            .setResponseCode(200)
            .responseString("test")
            .responseHeaders(["Accept-encoding": "*.*"])
        dispatchMap.add(dispatch)
        mockWebServer.setDispatch(dispatchMap)
        
        let url = NSURL(string: "http://127.0.0.1:9000/test")
        
        let testCondition: TestConditionWait = TestConditionWait()
        
        let task = URLSession.shared.dataTask(with: url! as URL) {
            (data, response, error) in
            debugPrint("response data=", data)
            debugPrint("response headers=", response)
            testCondition.wakeup()
        }
        
        task.resume()
        testCondition.wait()
    }
    
}
