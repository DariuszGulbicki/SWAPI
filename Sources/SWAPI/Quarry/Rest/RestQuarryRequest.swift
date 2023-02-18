public class RestQuarryRequest {

    private var method: String = "GET"
    private var uri: String = "/"
    private var headers: [String: String] = [:]
    private var body: String = ""
    private var parameters: [String: String] = [:]

    public init() {

    }

    public func setMethod(method: String) {
        self.method = method
    }

    public func getMethod() -> String {
        return self.method
    }

    public func setUri(uri: String) {
        self.uri = uri
    }

    public func getUri() -> String {
        return self.uri
    }

    public func setHeaders(headers: [String: String]) {
        self.headers = headers
    }

    public func getHeaders() -> [String: String] {
        return self.headers
    }

    public func setBody(body: String) {
        self.body = body
    }

    public func getBody() -> String {
        return self.body
    }

    public func setParameters(parameters: [String: String]) {
        self.parameters = parameters
    }

    public func getParameters() -> [String: String] {
        return self.parameters
    }

}