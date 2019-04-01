//
//  DemoSwiftTests.swift
//  DemoSwiftTests
//
//  Created by Fernando Mayo Fernandez on 10/14/18.
//  Copyright © 2018 Fernando Mayo Fernandez. All rights reserved.
//

import XCTest
import os.log
import ScopeAgentClient
import ScopeAgent
import Alamofire

@testable import DemoSwift

class DemoSwiftTests: XCTestCase {
    func testPass() {
        XCTAssert(true);
    }
    
    func testFail() {
        XCTAssert(false);
    }
    
    func testNSLog() {
        NSLog("Hello %@", "world!");
    }
    
    func testCrash() {
        [][0];
    }
    
    func testException() {
        NSException.init(name: NSExceptionName.init("Name"), reason: "Reason", userInfo: ["Key": "Value"]).raise();
    }
    
    func testLogging() {
        NSLog("Hello %@", "world!");
        os_log("Hello %@", "world!");
    }
    
    func testNetwork() {
        
        let url = URL(string: "http://httpbin.org/get")!
        let expec = expectation(description: "GET \(url)")

        let task = URLSession.shared.dataTask(with: url) { _,_,_  in
            expec.fulfill()
        }
        task.resume()
        
        waitForExpectations(timeout: 30) { error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
            }
            task.cancel()
        }
    }

    func testAlamofire() {

        let url = URL(string: "http://httpbin.org/get")!
        let expec = expectation(description: "GET \(url)")
        Alamofire.request(url, parameters: ["foo": "bar"])
            .response { response in
                expec.fulfill()
        }

        waitForExpectations(timeout: 30) { error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
            }
        }

    }

    func testCustomLog() {
        ScopeAgentClient.SALogger.log("HELLO FROM TEST", .debug)
        
    }
    
    func testCustomAppLogWithScopeAgent() {
        ScopeAgentTester.testScopeAgentLog()
    }
    
    func testCustomNetworkAndLogWithScopeAgent() {
        
        let expec = expectation(description: "testCustomNetworkAndLog")
        
        ScopeAgentTester.customNetworkAndLog {
            expec.fulfill()
        }
        
        waitForExpectations(timeout: 30) { error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
            }
        }
    }
    
    func testCustomAppLogWithScopeAgentClient() {
        ScopeAgentClientTester.testScopeAgentLog()
    }
    
    func testCustomNetworkAndLogWithScopeAgentClient() {
        
        let expec = expectation(description: "testCustomNetworkAndLog")

        ScopeAgentClientTester.customNetworkAndLog {
            expec.fulfill()
        }
        
        waitForExpectations(timeout: 30) { error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
            }
        }
    }
    
    func testAddSpansFromAppUsingOpentracing() {
        OpentracingLibraryTester.addSpansFromAppUsingOpentracing()
    }
    
    func testCustomNetworkCrashOnResponse() {
        
        let expec = expectation(description: "testCustomNetworkAndLog")
        
        ScopeAgentTester.customNetworkAndLog {
            expec.fulfill()
            let a = NSMutableArray()
            a.removeObjects(in: NSRange(location: NSNotFound, length: 0-NSNotFound))
            
        }
        
        waitForExpectations(timeout: 30) { error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
            }
        }
    }
    
    func testCustomLogAndNetworkCrashInTheFuture() {
        
        ScopeAgent.SALogger.log("This test should fail in the future", .info)

        ScopeAgentTester.customNetworkAndLog {
            let a = NSMutableArray()
            a.removeObjects(in: NSRange(location: NSNotFound, length: 0-NSNotFound))
        }
    }
}
