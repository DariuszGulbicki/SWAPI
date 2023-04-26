public class RestQuarryMiner {

    private var compiled: String;

    public init(_ request: RestQuarryRequest) {
        self.compiled = "";
    }

    private func compile(_ request: RestQuarryRequest) -> String {
        return request.getBody()
    }

}