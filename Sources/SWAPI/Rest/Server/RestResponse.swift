public class RestResponse {
    
    private var body: String = ""
    private var headers: [String: String] = [:]
    private var statusCode: Int = 200
    
    public init() {
        
    }
    
    public func getBody() -> String {
        return body
    }
    
    public func getHeaders() -> [String: String] {
        return headers
    }
    
    public func getStatusCode() -> Int {
        return statusCode
    }
    
    public func setBody(body: String) {
        self.body = body
    }
    
    public func setHeaders(headers: [String: String]) {
        self.headers = headers
    }

    public func setHeader(header: String, value: String) {
        self.headers[header] = value
    }
    
    public func setStatusCode(statusCode: Int) {
        self.statusCode = statusCode
    }
    
}