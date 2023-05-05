public class RestMethodHandler: RestHandler {

    private var method: (_ req: RestRequest, _ res: RestResponse) -> RestResponse

    required public init(method: @escaping (_ req: RestRequest, _ res: RestResponse) -> RestResponse) {
        self.method = method
    }

    public func handle(req: RestRequest, res: RestResponse) -> RestResponse {
        let res = method(req, res)
        if (!res.getHeaders().keys.contains("Server")) {
            res.setHeader(header: "Server", value: "SWAPI/1.0.0 (SWAPI API Server)")
        }
        return method(req, res)
    }

}