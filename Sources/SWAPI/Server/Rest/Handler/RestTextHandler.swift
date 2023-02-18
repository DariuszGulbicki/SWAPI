public class RestTextHandler: RestHandler {
    
    private var text: String = ""
    
    public init(text: String) {
        self.text = text
    }
    
    public func handle(req: RestRequest, res: RestResponse) -> RestResponse {
        res.setHeaders(headers: ["Content-Type": "text/plain"])
        res.setStatusCode(statusCode: 200)
        res.setBody(body: text)
        return res
    }
    
}