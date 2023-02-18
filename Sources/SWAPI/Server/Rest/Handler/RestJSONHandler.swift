import Foundation

public class RestJSONHandler : RestHandler {
    
    private var json: String = ""
    
    // json argument must be a dictionary or array
    public init(json: Any) {
        // Convert object to JSON string
        if let data = try? JSONSerialization.data(withJSONObject: json, options: []) {
            self.json = String(data: data, encoding: .utf8)!
        }
    }
    
    public func handle(req: RestRequest, res: RestResponse) -> RestResponse {
        res.setBody(body: json)
        res.setHeaders(headers: ["Content-Type": "application/json"])
        return res
    }
    
}