public protocol RestHandler {

    func handle(req: RestRequest, res: RestResponse) -> RestResponse

}