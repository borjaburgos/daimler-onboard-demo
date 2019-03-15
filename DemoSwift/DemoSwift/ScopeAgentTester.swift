
import Foundation
import ScopeAgent

class ScopeAgentTester {
    class func testScopeAgentLog() {
        SALogger.log(.debug, "HELLO FROM APP USING SCOPEAGENTCLIENT")
    }
    
    class func customNetworkAndLog(callback:@escaping ()->Void) {
        
        let url = URL(string: "http://httpbin.org/ip")!
        let task = URLSession.shared.dataTask(with: url) { data,response,error  in
            if let data = data {
                let string = String(data: data, encoding: .utf8)
                SALogger.log(.debug, string)
            }
            callback()
        }
        task.resume()
        
    }
}
