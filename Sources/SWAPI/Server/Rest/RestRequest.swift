import Foundation

public class RestRequest {
    
    private var method: String = "GET"
    private var uri: String = "/"
    private var parameters: [(String, String)] = []
    private var headers: [String: String] = [:]
    private var body: String = ""
    
    public init() {
        
    }
    
    public func getBody() -> String {
        return body
    }
    
    public func getHeaders() -> [String: String] {
        return headers
    }
    
    public func getMethod() -> String {
        return method
    }
    
    public func getParameters() -> [(String, String)] {
        return parameters
    }
    
    public func getUri() -> String {
        return uri
    }
    
    public func setBody(body: String) {
        self.body = body
    }
    
    public func setHeaders(headers: [String: String]) {
        self.headers = headers
    }
    
    public func setMethod(method: String) {
        self.method = method
    }
    
    public func setParameters(parameters: [(String, String)]) {
        self.parameters = parameters
    }
    
    public func setUri(uri: String) {
        self.uri = uri
    }

    public func getParameterByKey(key: String) -> String? {
        for (k, v) in parameters {
            if k == key {
                return v
            }
        }
        return nil
    }

    public func bodyAsJson() -> [String: Any] {
        let data = body.data(using: .utf8)!
        let json = try! JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
        return json
    }
    
}