import Foundation
import opentracing


class OpentracingLibraryTester {
    
    class func addSpansFromAppUsingOpentracing() {
        
        let tracer = OTGlobal.sharedTracer()
        
        let span = tracer.startSpan("CustomSpanFromApp")
        sleep(1)
        _ = tracer.startSpan("Child Span from app", childOf: span.context())
        sleep(1)
        span.finish()
    }
}

