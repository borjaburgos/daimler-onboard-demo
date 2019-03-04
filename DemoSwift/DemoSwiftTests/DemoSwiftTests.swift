//
//  DemoSwiftTests.swift
//  DemoSwiftTests
//
//  Created by Fernando Mayo Fernandez on 10/14/18.
//  Copyright © 2018 Fernando Mayo Fernandez. All rights reserved.
//

import XCTest
import os.log

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

}
