//
//  DemoSwiftTests.swift
//  DemoSwiftTests
//
//  Created by Fernando Mayo Fernandez on 10/14/18.
//  Copyright © 2018 Fernando Mayo Fernandez. All rights reserved.
//

import XCTest
import os.log
import CocoaLumberjack

let ddloglevel = DDLogLevel.debug;

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
        DDLogDebug("Hello world!");
        NSLog("Hello %@", "world!");
        os_log("Hello %@", "world!");
    }

}
