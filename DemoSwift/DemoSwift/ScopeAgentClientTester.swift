//
//  ScopeAgentClientTester.swift
//  DemoSwift
//
//  Created by Ignacio Bonafonte on 15/03/2019.
//  Copyright © 2019 Fernando Mayo Fernandez. All rights reserved.
//

import Foundation
import ScopeAgentClient

class ScopeAgentClientTester {
    
    class func testScopeAgentLog() {
        SALogger.log("HELLO FROM APP USING SCOPEAGENTCLIENT", .debug)
    }
    
    class func customNetworkAndLog(callback:@escaping ()->Void) {
        
        let url = URL(string: "http://httpbin.org/ip")!
        let task = URLSession.shared.dataTask(with: url) { data,response,error  in
            if let data = data {
                let string = String(data: data, encoding: .utf8)
                SALogger.log(string, .debug)
            }
            callback()
        }
        task.resume()
        
    }
}
