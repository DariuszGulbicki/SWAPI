public class RestQuarryMiner {

    private var compiledUri: String = "";
    private var completedHeaders: [String: String] = [:]
    private var completedBody: String = ""
    private var defaultNamedPlaceholders: [String: String] = [:]
    private var defaultUnnamedPlaceholders: [String] = []

    private let method: String

    public init(_ request: RestQuarryRequest, clearEmptySlashes: Bool = true, defaultNamedPlaceholders: [String: String] = [:], defaultUnnamedPlaceholders: [String] = []) {
        self.method = request.getMethod()
        self.completedHeaders = self.buildHeaders(request: request)
        self.compiledUri = self.buildUri(request: request, clearEmptySlashes: clearEmptySlashes)
        self.completedBody = request.getBody()
        self.defaultNamedPlaceholders = defaultNamedPlaceholders
        self.defaultUnnamedPlaceholders = defaultUnnamedPlaceholders
    }

    public init(method: String, uri: String, headers: [String: String] = [:], body: String = "", clearEmptySlashes: Bool = true, defaultNamedPlaceholders: [String: String] = [:], defaultUnnamedPlaceholders: [String] = []) {
        self.completedHeaders = headers
        self.compiledUri = uri
        self.completedBody = body
        self.method = method
        self.defaultNamedPlaceholders = defaultNamedPlaceholders
        self.defaultUnnamedPlaceholders = defaultUnnamedPlaceholders
    }

    private func replacePlaceholders(text: String, unnamedValues: [String]?, namedValues: [String: String]?) -> String {
        var temp = text
        // Named placeholders
        if (namedValues != nil) {
            for (key, value) in namedValues! {
                temp = temp.replacingOccurrences(of: "@{" + key + "}", with: value)
            }
        }
        // Unnamed placeholders
        if (unnamedValues != nil) {
            for (index, value) in unnamedValues!.enumerated() {
                temp = temp.replacingOccurrences(of: "${" + String(index + 1) + "}", with: value)
            }
        }
        // Default named placeholders
        for (key, value) in self.defaultNamedPlaceholders {
            temp = temp.replacingOccurrences(of: "@{" + key + "}", with: value)
        }
        // Default unnamed placeholders
        for (index, value) in self.defaultUnnamedPlaceholders.enumerated() {
            temp = temp.replacingOccurrences(of: "${" + String(index + 1) + "}", with: value)
        }
        return temp
    }

    private func buildHeaders(request: RestQuarryRequest) -> [String: String] {
        var headers: [String: String] = [:]
        for (key, value) in request.getHeaders() {
            headers[key] = value
        }
        return headers
    }

    private func buildUri(request: RestQuarryRequest, clearEmptySlashes: Bool) -> String {
        var uri = ensureTrailingSlash(text: request.getUri())
        if uri.count > 0 && uri.last == "/" {
            uri = String(uri.dropLast())
        }
        uri += self.buildQuery(request: request)
        return clearEmptySlashes ? clearAllEmptySlashes(uri) : uri
    }

    private func buildQuery(request: RestQuarryRequest) -> String {
        var query: String = ""
        for (key, value) in request.getParameters() {
            query += key + "=" + value + "&"
        }
        if query.count > 0 {
            query = "?" + query.dropLast()
        }
        return query
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
            return text
        }
        while urlWithoutProtocol.contains("//") {
            urlWithoutProtocol = urlWithoutProtocol.replacingOccurrences(of: "//", with: "/")
        }
        return protocolSlashes + urlWithoutProtocol
    }

    public func getHeaders(namedPlaceholders: [String:String]? = nil, unnamedPlaceholders: [String]? = nil) -> [String: String] {
        var temp = self.completedHeaders
        for (key, value) in namedPlaceholders ?? [:] {
            temp[key] = replacePlaceholders(text: value, unnamedValues: unnamedPlaceholders, namedValues: namedPlaceholders)
        }
        return temp
    }

    public func getHeaders(_ namedPlaceholders: (String, String)...) -> [String: String] {
        return getHeaders(namedPlaceholders: Dictionary(uniqueKeysWithValues: namedPlaceholders))
    }

    public func getHeaders(_ unnamedPlaceholders: String...) -> [String: String] {
        return getHeaders(unnamedPlaceholders: unnamedPlaceholders)
    }

    public func getUri(namedPlaceholders: [String:String]? = nil, unnamedPlaceholders: [String]? = nil) -> String {
        return replacePlaceholders(text: self.compiledUri, unnamedValues: unnamedPlaceholders, namedValues: namedPlaceholders)
    }

    public func getUri(_ namedPlaceholders: (String, String)...) -> String {
        return getUri(namedPlaceholders: Dictionary(uniqueKeysWithValues: namedPlaceholders))
    }

    public func getUri(_ unnamedPlaceholders: String...) -> String {
        return getUri(unnamedPlaceholders: unnamedPlaceholders)
    }

    public func getBody(namedPlaceholders: [String:String]? = nil, unnamedPlaceholders: [String]? = nil) -> String {
        return replacePlaceholders(text: self.completedBody, unnamedValues: unnamedPlaceholders, namedValues: namedPlaceholders)
    }

    public func getBody(_ namedPlaceholders: (String, String)...) -> String {
        return getBody(namedPlaceholders: Dictionary(uniqueKeysWithValues: namedPlaceholders))
    }

    public func getBody(_ unnamedPlaceholders: String...) -> String {
        return getBody(unnamedPlaceholders: unnamedPlaceholders)
    }

    public func toRequest(namedPlaceholders: [String:String]? = nil, unnamedPlaceholders: [String]? = nil) -> RestQuarryRequest {
        return RestQuarryRequest(
            method: "GET",
            uri: getUri(namedPlaceholders: namedPlaceholders, unnamedPlaceholders: unnamedPlaceholders),
            headers: getHeaders(namedPlaceholders: namedPlaceholders, unnamedPlaceholders: unnamedPlaceholders),
            body: getBody(namedPlaceholders: namedPlaceholders, unnamedPlaceholders: unnamedPlaceholders)
        )
    }

    public func toRequest(_ namedPlaceholders: (String, String)...) -> RestQuarryRequest {
        return toRequest(namedPlaceholders: Dictionary(uniqueKeysWithValues: namedPlaceholders))
    }

    public func toRequest(_ unnamedPlaceholders: String...) -> RestQuarryRequest {
        return toRequest(unnamedPlaceholders: unnamedPlaceholders)
    }

}