import Foundation
import FoundationNetworking

public class RestQuarry {
    
    private var baseURL: String
    private var baseURI: String = ""
    private var baseHeaders: [String: String] = [:]

    // Getters and Setters

    public func setBaseURL(baseURL: String) {
        self.baseURL = baseURL
    }

    public func getBaseURL() -> String {
        return self.baseURL
    }

    public func setBaseURI(baseURI: String) {
        self.baseURI = baseURI
    }

    public func getBaseURI() -> String {
        return self.baseURI
    }

    public func setBaseHeaders(baseHeaders: [String: String]) {
        self.baseHeaders = baseHeaders
    }

    public func getBaseHeaders() -> [String: String] {
        return self.baseHeaders
    }

    // Constructors
    
    init(baseURL: String) {
        self.baseURL = baseURL
    }

    init(baseURL: String, baseURI: String) {
        self.baseURL = baseURL
        self.baseURI = baseURI
    }

    init(baseURL: String, baseURI: String, baseHeaders: [String: String]) {
        self.baseURL = baseURL
        self.baseURI = baseURI
        self.baseHeaders = baseHeaders
    }

    // Public Methods
    
    public func query(request: RestQuarryRequest, timeout: TimeInterval = 10) -> RestQuarryResponse {
        let response: RestQuarryResponse = RestQuarryResponse();
        let url: URL = URL(string: self.getURL(request: request))!
        var urlRequest: URLRequest = URLRequest(url: url)
        urlRequest.timeoutInterval = timeout
        urlRequest.httpMethod = request.getMethod()
        urlRequest.allHTTPHeaderFields = self.getHeaders(request: request)
        urlRequest.httpBody = request.getBody().data(using: .utf8)
        let semaphore: DispatchSemaphore = DispatchSemaphore(value: 0)
        let task: URLSessionDataTask = URLSession.shared.dataTask(with: urlRequest) { data, urlResponse, error in
            if let error: Error = error {
                response.setError(error: error)
            }
            if let httpResponse: HTTPURLResponse = urlResponse as? HTTPURLResponse {
                response.setStatus(status: httpResponse.statusCode)
            }
            if let data: Data = data {
                response.setBody(body: String(data: data, encoding: .utf8)!)
            }
            if let httpResponse: HTTPURLResponse = urlResponse as? HTTPURLResponse {
                response.setHeaders(headers: httpResponse.allHeaderFields as! [String : String])
            }
            semaphore.signal()
        }
        task.resume()
        semaphore.wait()
        return response;
    }

    public func printURL(request: RestQuarryRequest) {
        print(self.getURL(request: request))
    }

    public func printHeaders(request: RestQuarryRequest) {
        print(self.getHeaders(request: request))
    }

    // Private Methods

    private func getHeaders(request: RestQuarryRequest) -> [String: String] {
        var headers: [String: String] = [:]
        for (key, value) in self.baseHeaders {
            headers[key] = value
        }
        for (key, value) in request.getHeaders() {
            headers[key] = value
        }
        return headers
    }

    private func getUri(request: RestQuarryRequest) -> String {
        var uri = ensureTrailingSlash(text: self.baseURI) + ensureTrailingSlash(text: request.getUri())
        if uri.count > 0 && uri.last == "/" {
            uri = String(uri.dropLast())
        }
        return uri + self.getQuery(request: request)
    }

    private func getQuery(request: RestQuarryRequest) -> String {
        var query: String = ""
        for (key, value) in request.getParameters() {
            query += key + "=" + value + "&"
        }
        if query.count > 0 {
            query = "?" + query.dropLast()
        }
        return query
    }

    private func getURL(request: RestQuarryRequest) -> String {
        return ensureTrailingSlash(text: self.baseURL) + self.getUri(request: request)
    }

    private func ensureTrailingSlash(text: String) -> String {
        if text.last == "/" {
            return ensureOneTrailingSlash(text: text)
        }
        return ensureOneTrailingSlash(text: text + "/")
    }

    private func ensureOneTrailingSlash(text: String) -> String {
        var temp = text
        while temp.last == "/" && temp.dropLast().last == "/" {
            temp = String(text.dropLast())
        }
        return temp
    }

}