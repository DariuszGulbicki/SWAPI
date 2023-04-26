import Foundation
import FoundationNetworking
import LoggingCamp

public class RestQuarry {
    
    private var logger: Logger?

    private var baseURL: String
    private var baseURI: String = ""
    private var baseHeaders: [String: String] = [:]

    private let clearEmptySlashes: Bool

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

    public func setLogger(logger: Logger?) {
        self.logger = logger
    }

    public func getLogger() -> Logger? {
        return self.logger
    }

    // Constructors

    public init(baseURL: String, clearEmptySlashes: Bool = true, baseURI: String = "", baseHeaders: [String: String] = [:], logger: Logger = Logger("Rest Quarry")) {
        self.baseURL = baseURL
        self.baseURI = baseURI
        self.baseHeaders = baseHeaders
        self.logger = logger
        self.clearEmptySlashes = clearEmptySlashes
    }

    // Public Methods
    
    public func query(request: RestQuarryRequest, timeout: TimeInterval = 10) -> RestQuarryResponse {
        let requestUrl: String
        if clearEmptySlashes {
            requestUrl = clearAllEmptySlashes(self.getURL(request: request))
        } else {
            requestUrl = self.getURL(request: request)
        }
        logger?.debug("Querying \(requestUrl):")
        logger?.debug("[QUERY] Initializning response object")
        let response: RestQuarryResponse = RestQuarryResponse();
        logger?.debug("[QUERY] Initializing URL request")
        let url: URL = URL(string: requestUrl)!
        var urlRequest: URLRequest = URLRequest(url: url)
        logger?.debug("[QUERY] Setting request parameters")
        urlRequest.timeoutInterval = timeout
        urlRequest.httpMethod = request.getMethod()
        urlRequest.allHTTPHeaderFields = self.getHeaders(request: request)
        urlRequest.httpBody = request.getBody().data(using: .utf8)
        logger?.debug("[QUERY] Creating semaphore and task")
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
        logger?.debug("[QUERY] Sending request")
        task.resume()
        semaphore.wait()
        let responseStatus: Int = response.getStatus()
        if responseStatus >= 400 && responseStatus < 500 {
            logger?.warn("[QUERY] Remote responded with user error \(responseStatus). Make sure that provided URI, body, parameters and/or authentication is correct")
        } else if responseStatus >= 500 {
            logger?.warn("[QUERY] Remote responded with server error \(responseStatus). Make sure that your request is correct and that the remote server is up and running")
        } else {
            logger?.debug("[QUERY] Request completed. Remote returned \(responseStatus)")
        }
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
        return text + "/"
    }

    private func ensureOneTrailingSlash(text: String) -> String {
        var temp = text
        while temp.last == "/" && temp.dropLast().last == "/" {
            temp = String(text.dropLast())
        }
        return temp
    }

    private func clearAllEmptySlashes(_ text: String) -> String {
        var protocolSlashes = ""
        var urlWithoutProtocol = ""
        let splitUrl = text.split(separator: "://")
        if splitUrl.count == 2 {
            protocolSlashes = String(splitUrl[0]) + "://"
            urlWithoutProtocol = String(splitUrl[1])
        } else if (splitUrl.count == 1) {
            urlWithoutProtocol = String(splitUrl[0])
        } else {
            logger?.error("URL contains more than one protocol slashes. Check Quarry and QuarryRequest for malformed URLs")
            return text
        }
        while urlWithoutProtocol.contains("//") {
            urlWithoutProtocol = urlWithoutProtocol.replacingOccurrences(of: "//", with: "/")
        }
        return protocolSlashes + urlWithoutProtocol
    }

}