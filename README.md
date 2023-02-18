# SWAPI

SWAPI is a Swift library that provides a client and server implementation for a RESTful API. It is designed to be easy to use and extend, making it a great choice for building APIs for your Swift-based applications.
Features

- **Client and Server:** SWAPI provides a client and server implementation for a RESTful API, making it easy to build and consume APIs using Swift.
- **Easy to Use:** SWAPI is designed to be easy to use, with a simple and intuitive API that makes it easy to get started.
- **Fast:** Client built on top of URLSession, Server built on top of Swifter.
- **All Platforms:** SWAPI is compatible with all platforms that support Swift 5.0 and above.
- **All in one:** SWAPI is a single library that provides both a client and server implementation, making it easy to get started.

## Compatibility

SWAPI is compatible with Swift 5.0 and above.
At the time, SWAPI is only confirmed to be compatible with **macOS** and **Linux**.
However, it should be compatible with any platform that supports Swift ***5.0*** and above.

## Support

For now SWAPI only supports RESTful APIs.
Support for SOAP and GraphQL is planned for the future.

### Supported API paradigms:
- [x] **RESTful**
- [ ] **SOAP**
- [ ] **GraphQL**

### Supported HTTP methods:
- **GET**
- **POST**
- **PUT**
- **PATCH**
- **DELETE**
- **HEAD**

## Installation

### Swift Package Manager

To install SWAPI using Swift Package Manager, add the following line to your Package.swift file:

```swift
dependencies: [
    .package(url: "https://github.com/DariuszGulbicki/SWAPI", from: "1.0.0")
]
```

Then run swift package update to install the library.

## Usage

### Import

To use SWAPI, import the module in your source file:

```swift
import SWAPI
```

### Client

There are two ways to query an API using SWAPI. The first is to use RestAPI static methods, which provide a simple interface for making requests to an API. The second is to create a Quarry which is a reusable object that can be used to make requests to an API. Quarry is useful when you need to make multiple requests to the same API.

#### RestAPI

You can simply call the static methods on RestAPI to make requests to an API.
This method is designed to be simple and easy to use, but it is not reusable.
You can pass up to 4 parameters to the query method: **method**, **url**, ***body***, and ***timeout***.

```swift
let response = RestAPI.RestAPI.query(method: .GET, url: "https:shibe.online/api/shibes?count=1&urls=true&httpsUrls=true")
print("status code: \(response.getStatus())")
print("body: \(response.getBody())")
```

#### Quarry

To create a Quarry, create a new instance of RestQuarry and pass the **baseURL** and ***baseURI*** to the constructor. You can then use the Quarry to make requests to the API.
Quarry has a query method that takes a RestQuarryRequest object as a parameter. You can use the RestQuarryRequest object to set the method, uri, parameters, headers, and body of the request.
Then, if the request is successful, the query method will return a RestQuarryResponse object or nil if the request has timed out.

```swift
// Create a new instance of RestQuarry
let quarry = RestQuarry(baseURL: "http://shibe.online", baseURI: "/api")
// Create a new instance of RestQuarryRequest
let request = RestQuarryRequest()
// Set the method, uri, parameters, and headers of the request
request.setMethod(method: "GET")
request.setUri(uri: "shibes")
request.setParameters(parameters: ["count": "1", "urls": "true", "httpsUrls": "true"])
request.setHeaders(headers: ["Accept": "application/json", "Browser": "WebWrench"])
// Query the API
let response = quarry.query(request: request)
// Print the response
print("status code: \(response.getStatus())")
print("body: \(response.getBody())")
```

### Server

Server works in a similar way to next.js. You can create a new instance of RestServer and pass the **port number** to the constructor and optionally ***path***. Then, you can use the server to create routes and handle requests.

Lets create a simple server that with one endpoint on **/api/hello**.
Our endpoint will return *"Hello, world!"* in raw text.

```swift
// Create a new instance of RestServer
let server = RestServer()
// Add a handler that will handle a get request to /hello
server.get(uri: "/test", handler: RestTextHandler(text: "Hello, World!"))
// Start the server on port 8080
server.start(port: 8080, path: "/api")
// Make sure to keep the server running
RunLoop.main.run()
```

Now lets use another endpoint that will return a JSON object.

```swift
// Create an endpoint that will automatically return a JSON object
sever.get(uri: "/json", handler: RestJsonHandler(json: ["hello": "world"]))
```

You can also create a custom handler that will handle the request and return a response.
We will use another method to demonstrate this.

```swift
// Create a custom handler that will handle the request and return a response
server.get(uri: "/bodytest", handler: RestMethodHandler(method: { req, res in 
    // Get the body of the request
    let body = req.getBody()
    // Get the parameters of the request
    let params = req.getParameters()
    // Create a string that will contain the parameters
    var paramsString = ""
    for (key, value) in params {
        paramsString += "\(key): \(value) "
    }
    // Set the headers, body, and status code of the response
    res.setHeaders(headers: ["Content-Type": "text/html", "Server": "SWAPIExample"])
    res.setBody(body: "body: \(body)<br/>params: \(paramsString)")
    res.setStatusCode(statusCode: 200)
    // Send response to the client
    return res
}))
```

## Contributing

Contributions are welcome! If you have an idea for a new feature or a bug fix, please create a new issue or pull request.

## Example usage

```swift
import SWAPI

// User class to store data
public class User: Decodable, Encodable {

    public init(username: String, password: String) {
        self.username = username
        self.password = password
    }

    public init() {
        self.username = ""
        self.password = ""
    }

    public var username: String
    public var password: String

}

@main
public struct Example {

    public static func main() {
        // Create a list of users
        var users: [User] = []
        // Create a new instance of RestServer
        let server = RestServer()
        // Add a handler that will handle a get request to /users and return a list of users
        server.get(uri: "/users", handler: RestJSONHandler(json: users))
        // Add a handler that will handle a post request to /user and add a new user
        server.post(uri: "/user", handler: RestMethodHandler(method: { req, res in
            let body = req.getBody()
            let user = try! JSONDecoder().decode(User.self, from: body.data(using: .utf8)!)
            users.append(user)
            res.setBody(body: "Added user with username: \(user.username)")
            res.setStatusCode(statusCode: 200)
            return res
        }))
        // Add a handler that will handle a delete request to /user that will delete a user by username
        // Username is passed as a parameter
        server.delete(uri: "/user", handler: RestMethodHandler(method: { req, res in
            let params: [(String, String)] = req.getParameters()
            var username = ""
            for param in params {
                if param.0 == "username" {
                    username = param.1
                }
            }
            if (username == "") {
                res.setBody(body: "No username or wrong username provided")
                res.setStatusCode(statusCode: 400)
                res.setHeaders(headers: ["Content-Type": "text/plain", "User-Agent": "WebWrench/1.0 (Swift API client)"])
                return res
            }
            users.removeAll(where: { $0.username == username })
            res.setBody(body: "Deleted user with username: \(username)")
            res.setStatusCode(statusCode: 200)
            return res
        }))
        // Start the server on port 8080 with path /api
        server.start(port: 8080, path: "/api")
        // Make sure to keep the server running
        RunLoop.main.run()
    }

}
```

## License

SWAPI is released under the MIT license. See LICENSE for details.