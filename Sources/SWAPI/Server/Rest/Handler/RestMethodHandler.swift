public class RestMethodHandler: RestHandler {

    private var method: (_ req: RestRequest, _ res: RestResponse) -> RestResponse

    required init(method: @escaping (_ req: RestRequest, _ res: RestResponse) -> RestResponse) {
        self.method = method
    }

    public func handle(req: RestRequest, res: RestResponse) -> RestResponse {
        let res = method(req, res)
        if (!res.getHeaders().keys.contains("Server")) {
            var headers = res.getHeaders()
            headers["Server"] = "SWAPI 1.0"
            res.setHeaders(headers: headers)
        }
        return method(req, res)
    }

}