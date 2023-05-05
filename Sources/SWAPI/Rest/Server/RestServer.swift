import Foundation
import FoundationNetworking
import LoggingCamp
import Swifter

precedencegroup SecondaryTernaryPrecedence {
    associativity: right
    higherThan: TernaryPrecedence
    lowerThan: LogicalDisjunctionPrecedence
}


infix operator +: AdditionPrecedence
infix operator +=: AdditionPrecedence
infix operator <=: AdditionPrecedence
infix operator *: AdditionPrecedence

postfix operator *

infix operator <: SecondaryTernaryPrecedence
infix operator ><: TernaryPrecedence

public class RestServer {
    
    private var server: HttpServer = HttpServer()

    private var logger: Logger?
    private var requestLogger: Logger?

    private var serverHeader: String? = "SWAPI/1.0.0 (SWAPI API Server)"

    private var getHandlers: [String: RestHandler] = [:]
    private var postHandlers: [String: RestHandler] = [:]
    private var putHandlers: [String: RestHandler] = [:]
    private var deleteHandlers: [String: RestHandler] = [:]
    private var patchHandlers: [String: RestHandler] = [:]
    private var headHandlers: [String: RestHandler] = [:]

    private var notFoundHandler: RestHandler = RestMethodHandler(method: { (req, res) -> RestResponse in
        res.setStatusCode(statusCode: 404)
        res.setBody(body: "Not Found - \(req.getUri())")
        return res
    })

    private var methodNotAllowedHandler: RestHandler = RestMethodHandler(method: { (req, res) -> RestResponse in
        res.setStatusCode(statusCode: 405)
        res.setBody(body: "Method Not Allowed - \(req.getMethod())")
        return res
    })

    private var internalServerErrorHandler: RestHandler = RestMethodHandler(method: { (req, res) -> RestResponse in
        res.setStatusCode(statusCode: 500)
        res.setBody(body: "Internal Server Error")
        return res
    })
    
    public init(logger: Logger? = Logger("Rest Server"), requestLogger: Logger? = Logger("Rest Request"), requestLogString: String = "[@method] @uri/@query_params -> @ip", serverHeader: String? = nil) {
        self.serverHeader = serverHeader
        self.logger = logger
        self.requestLogger = requestLogger
        logger?.debug("Initializing Rest Server")
        if (self.requestLogger != nil) {
            server.middleware.append { request in
                // [@method] @uri/@query_params -> @ip (@headers) {@body}'
                requestLogger?.info(requestLogString
                .replacingOccurrences(of: "@method", with: request.method)
                .replacingOccurrences(of: "@uri", with: request.path)
                .replacingOccurrences(of: "@query_params", with: request.queryParams.reduce("", { (result, param) -> String in
                    return "\(result)\(param.0)=\(param.1)&"
                }).dropLast())
                .replacingOccurrences(of: "@ip", with: request.address ?? "unknown")
                .replacingOccurrences(of: "@headers", with: request.headers.reduce("", { (result, header) -> String in
                    return "\(result)\(header.0)=\(header.1)&"
                }).dropLast())
                .replacingOccurrences(of: "@body", with: String(describing: request.body))
                )
                return nil
            }
        }
        server.middleware.append { request in
            var headers = request.headers
            if (self.serverHeader != nil) {
                headers["Server"] = self.serverHeader
            }
            let req = self.convertHTTPReqToRestReq(req: request)
            let res = RestResponse()
            logger?.debug("Handling \(request.method) request for \(req.getUri())")
            switch req.getMethod() {
                case "GET":
                    if let handler = self.getHandlers[req.getUri()] {
                        return self.convertRestResToHTTPRes(res: handler.handle(req: req, res: res))
                    } else if let handler = self.getHandlers[String(req.getUri().dropFirst())] {
                        return self.convertRestResToHTTPRes(res: handler.handle(req: req, res: res))
                    } else {
                        return self.convertRestResToHTTPRes(res: self.notFoundHandler.handle(req: req, res: res))
                    }
                case "POST":
                    if let handler = self.postHandlers[req.getUri()] {
                        return self.convertRestResToHTTPRes(res: handler.handle(req: req, res: res))
                    } else if let handler = self.postHandlers[String(req.getUri().dropFirst())] {
                        return self.convertRestResToHTTPRes(res: handler.handle(req: req, res: res))
                    } else {
                        return self.convertRestResToHTTPRes(res: self.notFoundHandler.handle(req: req, res: res))
                    }
                case "PUT":
                    if let handler = self.putHandlers[req.getUri()] {
                        return self.convertRestResToHTTPRes(res: handler.handle(req: req, res: res))
                    } else if let handler = self.putHandlers[String(req.getUri().dropFirst())] {
                        return self.convertRestResToHTTPRes(res: handler.handle(req: req, res: res))
                    } else {
                        return self.convertRestResToHTTPRes(res: self.notFoundHandler.handle(req: req, res: res))
                    }
                case "DELETE":
                    if let handler = self.deleteHandlers[req.getUri()] {
                        return self.convertRestResToHTTPRes(res: handler.handle(req: req, res: res))
                    } else if let handler = self.deleteHandlers[String(req.getUri().dropFirst())] {
                        return self.convertRestResToHTTPRes(res: handler.handle(req: req, res: res))
                    } else {
                        return self.convertRestResToHTTPRes(res: self.notFoundHandler.handle(req: req, res: res))
                    }
                case "PATCH":
                    if let handler = self.patchHandlers[req.getUri()] {
                        return self.convertRestResToHTTPRes(res: handler.handle(req: req, res: res))
                    } else if let handler = self.patchHandlers[String(req.getUri().dropFirst())] {
                        return self.convertRestResToHTTPRes(res: handler.handle(req: req, res: res))
                    } else {
                        return self.convertRestResToHTTPRes(res: self.notFoundHandler.handle(req: req, res: res))
                    }
                case "HEAD":
                    if let handler = self.headHandlers[req.getUri()] {
                        return self.convertRestResToHTTPRes(res: handler.handle(req: req, res: res))
                    } else if let handler = self.headHandlers[String(req.getUri().dropFirst())] {
                        return self.convertRestResToHTTPRes(res: handler.handle(req: req, res: res))
                    } else {
                        return self.convertRestResToHTTPRes(res: self.notFoundHandler.handle(req: req, res: res))
                    }
                default:
                    requestLogger?.warn("Method \(req.getMethod()) that is not allowed was used by remote")
                    return self.convertRestResToHTTPRes(res: self.methodNotAllowedHandler.handle(req: req, res: res))
            }
        }
        logger?.debug("Rest Server initialized")
    }

    public func getLogger() -> Logger? {
        return requestLogger
    }

    public func setLogger(logger: Logger) {
        requestLogger = logger
    }

    public func getRequestLogger() -> Logger? {
        return requestLogger
    }

    public func setRequestLogger(logger: Logger) {
        requestLogger = logger
    }

    public func getServerHeader() -> String? {
        return serverHeader
    }

    public func setServerHeader(serverHeader: String) {
        self.serverHeader = serverHeader
    }

    public func get(uri: String, handler: RestHandler) {
        getHandlers[uri] = handler
    }

    public func post(uri: String, handler: RestHandler) {
        postHandlers[uri] = handler
    }

    public func put(uri: String, handler: RestHandler) {
        putHandlers[uri] = handler
    }

    public func delete(uri: String, handler: RestHandler) {
        deleteHandlers[uri] = handler
    }

    public func patch(uri: String, handler: RestHandler) {
        patchHandlers[uri] = handler
    }

    public func head(uri: String, handler: RestHandler) {
        headHandlers[uri] = handler
    }

    public func add(_ class: RestEndpoints, suppressNoMethodWarning: Bool = false) {
        logger?.debug("Adding \(String(describing: `class`)) to Rest Server")
        let defaultMethod = `class`.defaultMethod()
        logger?.debug("[CLASS] Default method is \(defaultMethod ?? "not provided")")
        let defaultPath = `class`.defaultPath()
        logger?.debug("[CLASS] Default path is \(defaultPath ?? "not provided")")
        let mirror = Mirror(reflecting: `class`)
        for child in mirror.children {
            logger?.debug("[CLASS] Found constant \(child.label!)")
            if let property = child.value as? RestHandler {
                logger?.debug("[CLASS] Adding \(child.label!) to Rest Server")
                if let method = getMethodFromVarName(child.label!, defaultMethod, defaultPath ?? "") {
                    logger?.debug("[CLASS] Determined method \(method.0) and path \(method.1)")
                    switch method.0 {
                        case "get":
                            logger?.debug("[CLASS] Adding GET handler...")
                            get(uri: method.1, handler: property)
                        case "post":
                            logger?.debug("[CLASS] Adding POST handler...")
                            post(uri: method.1, handler: property)
                        case "put":
                            logger?.debug("[CLASS] Adding PUT handler...")
                            put(uri: method.1, handler: property)
                        case "delete":
                            logger?.debug("[CLASS] Adding DELETE handler...")
                            delete(uri: method.1, handler: property)
                        case "patch":
                            logger?.debug("[CLASS] Adding PATCH handler...")
                            patch(uri: method.1, handler: property)
                        case "head":
                            logger?.debug("[CLASS] Adding HEAD handler...")
                            head(uri: method.1, handler: property)
                        default:
                            continue
                    }
                } else {
                    if !suppressNoMethodWarning {
                        logger?.warn("For constant \(child.label!) in \(String(describing: `class`)) no default method was provided nor method was specified in variable name. Skipping...")
                    }
                }
            }
        }
    }

    // Special return handlers setters

    public func setNotFoundHandler(handler: RestHandler) {
        notFoundHandler = handler
    }

    public func setMethodNotAllowedHandler(handler: RestHandler) {
        methodNotAllowedHandler = handler
    }

    public func setInternalServerErrorHandler(handler: RestHandler) {
        internalServerErrorHandler = handler
    }
    
    public func start(_ port: UInt16, path: String = "") {
        logger?.debug("Starting Rest Server on port \(port)")
        try! server.start(port, forceIPv4: true)
        logger?.debug("Rest Server started. Running loop...")
        RunLoop.current.run()
    }

    public func stop() {
        logger?.debug("Stopping Rest Server")
        server.stop()
        logger?.debug("Rest Server stopped")
    }

    private func getMethodFromVarName(_ varName: String, _ defaultMethod: String?, _ defaultPath: String) -> (String, String)? {
        let methodsToCheck = ["get", "post", "put", "delete", "patch", "head"]
        for method in methodsToCheck {
            let regex = try! Regex(method).ignoresCase()
            if varName.starts(with: regex) {
                var name = varName
                name.removeFirst(method.count)
                return (method, defaultPath + pathFromVarName(name))
            }
        }
        if defaultMethod == nil {
            return nil
        }
        return (defaultMethod!, checkPath(path: defaultPath + pathFromVarName(varName)))
    }

    private func pathFromVarName(_ varName: String) -> String {
        if varName == "" {
            return "/"
        }
        var path = ""
        for char in varName {
            if char.isUppercase {
                path += "/"
            }
            path += char.lowercased()
        }
        return path
    }

    private func checkPath(path: String) -> String {
        var newPath = path
        if newPath.last == "/" && newPath != "/" {
            newPath.removeLast()
        }
        if newPath.first != "/" {
            newPath = "/" + newPath
        }
        while newPath.contains("//") {
            newPath = newPath.replacingOccurrences(of: "//", with: "/")
        }
        logger?.debug("Path \(path) converted to \(newPath)")
        return newPath
    }


    private func convertHTTPReqToRestReq(req: HttpRequest) -> RestRequest {
        logger?.debug("Converting HTTP request for path \(req.path) into RestRequest")
        let method = req.method
        let headers = req.headers
        let body = req.body
        let stringBody = String(bytes: body, encoding: .utf8)
        let parameters = req.queryParams
        let restReq = RestRequest()
        restReq.setBody(body: stringBody ?? "")
        restReq.setHeaders(headers: headers)
        restReq.setMethod(method: method)
        restReq.setParameters(parameters: parameters)
        restReq.setUri(uri: req.path)
        logger?.debug("Converted HTTP request into RestRequest")
        return restReq
    }

    private func convertRestResToHTTPRes(res: RestResponse) -> HttpResponse {
        logger?.debug("Converting RestResponse with code \(res.getStatusCode()) into HTTPResponse")
        let body = res.getBody()
        let statusCode = res.getStatusCode()
        let headers = res.getHeaders()
        logger?.debug("Converted RestResponse into HTTPResponse. Server will attempt write...")
        return .raw(statusCode, body, headers, { writer in
            try writer.write(Array(body.utf8))
        })
    }

    // Operators

    
    
}