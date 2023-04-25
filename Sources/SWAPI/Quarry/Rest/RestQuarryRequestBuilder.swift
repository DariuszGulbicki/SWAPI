public class RestQuarryRequestBuilder {

    private var method: String = "GET"
    private var uri: String = ""
    private var parameters: [String:String] = [:]
    private var headers: [String:String] = [:]
    private var body: String = ""

    public init() {

    }

    public func method(_ method: String) -> RestQuarryRequestBuilder {
        self.method = method
        return self
    }

    public func uri(_ uri: String) -> RestQuarryRequestBuilder {
        self.uri = uri
        return self
    }

    public func parameters(_ parameters: [String:String]) -> RestQuarryRequestBuilder {
        self.parameters = parameters
        return self
    }

    public func addParameter(_ key: String, _ value: String) -> RestQuarryRequestBuilder {
        self.parameters[key] = value
        return self
    }

    public func headers(_ headers: [String: String]) -> RestQuarryRequestBuilder {
        self.headers = headers
        return self
    }

    public func addHeader(_ key: String, _ value: String) -> RestQuarryRequestBuilder {
        self.headers[key] = value
        return self
    }

    public func body(_ body: String) -> RestQuarryRequestBuilder {
        self.body = body
        return self
    }

    public func build() -> RestQuarryRequest {
        let request = RestQuarryRequest()
        request.setMethod(method: method)
        request.setUri(uri: uri)
        request.setParameters(parameters: parameters)
        request.setHeaders(headers: headers)
        request.setBody(body: body)
        return request
    }

}