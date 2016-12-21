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
            debugPrint("response data=", data ?? "response null", "\n")
            debugPrint("response headers=", response ?? "no response header", "\n")
            testCondition.wakeup()
        }
        
        task.resume()
        testCondition.wait(for: 1)
    }
    
    func testMultipleResponse() {
        let dispatchMap: DispatchMap = DispatchMap()
        let dispatch: Dispatch = Dispatch()
        
        dispatch.requestContain("test1")
            .setResponseCode(200)
            .responseString("test")
            .responseHeaders(["Accept-encoding": "*.*"])
        dispatchMap.add(dispatch)
        
        let dispatch1: Dispatch = Dispatch()
        dispatch1.requestContain("test2")
            .setResponseCode(200)
            .responseBody(for: Bundle(for: object_getClass(self)), fromFile: "response.json")
            .responseHeaders(["Accept-encoding": "*.*"])
        dispatchMap.add(dispatch1)
        
        mockWebServer.setDispatch(dispatchMap)
        
        let url = NSURL(string: "http://127.0.0.1:9000/test1")
        let url2 = NSURL(string: "http://127.0.0.1:9000/test2")
        
        let testCondition: TestConditionWait = TestConditionWait.instance()
        
        let task = URLSession.shared.dataTask(with: url! as URL) {
            (data, response, error) in
            debugPrint("response data=", data ?? "response null")
            debugPrint("response headers=", response ?? "no response header")
            testCondition.wakeup()
        }
        
        task.resume()
        
        let task2 = URLSession.shared.dataTask(with: url2! as URL) {
            (data, response, error) in
            debugPrint("response data=", data ?? "response null", "\n")
            debugPrint("response headers=", response ?? "no response header", "\n")
            testCondition.wakeup()
        }
        task2.resume()
        
        testCondition.wait(for: 2)
    }
    
}
