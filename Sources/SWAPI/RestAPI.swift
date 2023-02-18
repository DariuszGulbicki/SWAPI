import Foundation
import FoundationNetworking

public class RestAPI {

    public enum Method {
        case GET
        case POST
        case PUT
        case DELETE
        case PATCH
        case HEAD
    }

    private static func getMethod(method: Method) -> String {
        switch method {
            case .GET:
                return "GET"
            case .POST:
                return "POST"
            case .PUT:
                return "PUT"
            case .DELETE:
                return "DELETE"
            case .PATCH:
                return "PATCH"
            case .HEAD:
                return "HEAD"
        }
    }

    public static func query(method: Method, url: String, body: String = "", timeout: TimeInterval = 10) -> RestQuarryResponse {
        let response: RestQuarryResponse = RestQuarryResponse();
        let urll: URL = URL(string: url)!
        var urlRequest: URLRequest = URLRequest(url: urll)
        urlRequest.timeoutInterval = timeout
        urlRequest.httpMethod = getMethod(method: method)
        urlRequest.httpBody = body.data(using: .utf8)
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
        task.resume()
        semaphore.wait()
        return response;
    }

}