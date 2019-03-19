import Foundation
import opentracing


class OpentracingLibraryTester {
    
    class func addSpansFromAppUsingOpentracing() {
        
        let tracer = OTGlobal.sharedTracer()
        
        let span = tracer.startSpan("CustomSpanFromApp")
        sleep(1)
        let childSpan = tracer.startSpan("Child Span from app", childOf: span.context())
        sleep(1)
        childSpan.finish()
        span.finish()
    }
}

