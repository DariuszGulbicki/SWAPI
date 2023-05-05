import Foundation

public class RestQuarryResponse {

    private var status: Int = 400;
    private var headers: [String: String] = [:];
    private var body: String = "";
    private var error: Error? = nil;

    // Getters and Setters

    public func setStatus(status: Int) {
        self.status = status;
    }

    public func getStatus() -> Int {
        return self.status;
    }

    public func setHeaders(headers: [String: String]) {
        self.headers = headers;
    }

    public func getHeaders() -> [String: String] {
        return self.headers;
    }

    public func setBody(body: String) {
        self.body = body;
    }

    public func getBody() -> String {
        return self.body;
    }

    public func setError(error: Error) {
        self.error = error;
    }

    public func getError() -> Error? {
        return self.error;
    }

    // Constructors

    public init() {

    }

    public init(status: Int, headers: [String: String], body: String, error: Error?) {
        self.status = status;
        self.headers = headers;
        self.body = body;
        self.error = error;
    }

    // Public Methods

    public func decodeToJSON<T: Decodable>() -> T? {
        if let data: Data = self.body.data(using: .utf8) {
            do {
                return try JSONDecoder().decode(T.self, from: data)
            } catch {
                print(error)
            }
        }
        return nil
    }

}