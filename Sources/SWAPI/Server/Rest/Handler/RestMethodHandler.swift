public class RestMethodHandler: RestHandler {

    private var method: (_ req: RestRequest, _ res: RestResponse) -> RestResponse

    required init(method: @escaping (_ req: RestRequest, _ res: RestResponse) -> RestResponse) {
        self.method = method
    }

    public func handle(req: RestRequest, res: RestResponse) -> RestResponse {
        return method(req, res)
    }

}