import Foundation
import FoundationNetworking
import Swifter

public class RestServer {
    
    private var server: HttpServer = HttpServer()

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
    
    public init() {
        
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
    
    public func start(port: UInt16, path: String) {
        server[path + "/:path"] = { request in
            let req = self.convertHTTPReqToRestReq(req: request)
            let res = RestResponse()
            let suri = req.getUri().replacingOccurrences(of: path, with: "")
            switch req.getMethod() {
                case "GET":
                    if let handler = self.getHandlers[suri] {
                        return self.convertRestResToHTTPRes(res: handler.handle(req: req, res: res))
                    } else {
                        return self.convertRestResToHTTPRes(res: self.notFoundHandler.handle(req: req, res: res))
                    }
                case "POST":
                    if let handler = self.postHandlers[suri] {
                        return self.convertRestResToHTTPRes(res: handler.handle(req: req, res: res))
                    } else {
                        return self.convertRestResToHTTPRes(res: self.notFoundHandler.handle(req: req, res: res))
                    }
                 case "PUT":
                    if let handler = self.putHandlers[suri] {
                       return self.convertRestResToHTTPRes(res: handler.handle(req: req, res: res))
                    } else {
                        return self.convertRestResToHTTPRes(res: self.notFoundHandler.handle(req: req, res: res))
                    }
                case "DELETE":
                    if let handler = self.deleteHandlers[suri] {
                        return self.convertRestResToHTTPRes(res: handler.handle(req: req, res: res))
                    } else {
                        return self.convertRestResToHTTPRes(res: self.notFoundHandler.handle(req: req, res: res))
                    }
                case "PATCH":
                    if let handler = self.patchHandlers[suri] {
                        return self.convertRestResToHTTPRes(res: handler.handle(req: req, res: res))
                    } else {
                        return self.convertRestResToHTTPRes(res: self.notFoundHandler.handle(req: req, res: res))
                    }
                case "HEAD":
                    if let handler = self.headHandlers[suri] {
                        return self.convertRestResToHTTPRes(res: handler.handle(req: req, res: res))
                    } else {
                        return self.convertRestResToHTTPRes(res: self.notFoundHandler.handle(req: req, res: res))
                    }
                default:
                    return self.convertRestResToHTTPRes(res: self.methodNotAllowedHandler.handle(req: req, res: res))
            }
        }
        do {
            try server.start(port) 
        } catch {
            print("Error starting server: \(error)")
        }
    }

    public func stop() {
        server.stop()
    }

    private func convertHTTPReqToRestReq(req: HttpRequest) -> RestRequest {
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
        return restReq
    }

    private func convertRestResToHTTPRes(res: RestResponse) -> HttpResponse {
        let body = res.getBody()
        let statusCode = res.getStatusCode()
        let headers = res.getHeaders()
        return .raw(statusCode, body, headers, { writer in
            try writer.write(Array(body.utf8))
        })
    }
    
}