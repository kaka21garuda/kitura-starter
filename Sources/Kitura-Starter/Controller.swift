/**
* Copyright IBM Corporation 2016
*
* Licensed under the Apache License, Version 2.0 (the "License");
* you may not use this file except in compliance with the License.
* You may obtain a copy of the License at
*
* http://www.apache.org/licenses/LICENSE-2.0
*
* Unless required by applicable law or agreed to in writing, software
* distributed under the License is distributed on an "AS IS" BASIS,
* WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
* See the License for the specific language governing permissions and
* limitations under the License.
**/

import Kitura
import SwiftyJSON
import LoggerAPI
import CloudFoundryEnv

public class Controller {

  let router: Router
  let appEnv: AppEnv

  var port: Int {
    get { return appEnv.port }
  }

  var url: String {
    get { return appEnv.url }
  }

  init() throws {
    appEnv = try CloudFoundryEnv.getAppEnv()

    // All web apps need a Router instance to define routes
    router = Router()

    // Serve static content from "public"
    router.all("/", middleware: StaticFileServer())

    // Basic GET request
    router.get("/hello", handler: getHello)

    // Basic POST request
    router.post("/hello", handler: postHello)

    // JSON Get request
    router.get("/json", handler: getJSON)
    
    //GET request with name
    router.get("/name/:name", handler: getName)
    
    router.post("/name", handler: postStringPosts)
    
    router.all("/name", allowPartialMatch: true, middleware: BodyParser())
  }
    
    //Parsing URL Encoded parameters
    //    /name/Bob
    public func getName(request: RouterRequest, response: RouterResponse, next: @escaping () -> Void) throws {
        Log.debug("GET - /name/:name")
        response.headers["Content-Type"] = "text/plain; charset=utf-8"
        let name = request.parameters["name"] ?? ""
        try response.send("Hello \(name)").end()
    }
    
    //Parsing Query parameters
    //    /name?name=Dan
    public func getNameQuery(request: RouterRequest, response: RouterResponse, next: @escaping () -> Void) throws {
        Log.debug("GET - /name")
        response.headers["Content-Type"] = "text/plain; charset=utf-8"
        let name = request.queryParameters["name"]
        try! response.send("Hello \(name!), welcome to Kitura!").end()
    }
    
    //StringPosts
    public func postStringPosts(request: RouterRequest, response: RouterResponse, next: @escaping () -> Void) throws {
        Log.debug("GET - /name")
        response.headers["Content-Type"] = "text/plain; charset=utf-8"
        let name = try! request.readString()
        try! response.send("Hello \(name), this is readstring").end()
    }
    
    public func jsonPostsrequest(request: RouterRequest, response: RouterResponse, next: @escaping () -> Void) throws {
        guard let parseBody = request.body else {
            next()
            return
        }
        switch parseBody {
        case .json(let jsonBody):
            let name = jsonBody["name"].string
            try! response.send("Hello \(name)").end()
        default:
            break
        }
        next()
    }
    
    public func getHello(request: RouterRequest, response: RouterResponse, next: @escaping () -> Void) throws {
        Log.debug("GET - /hello route handler...")
        response.headers["Content-Type"] = "text/plain; charset=utf-8"
        try response.status(.OK).send("Hello from Kitura-Starter!").end()
    }
    
    public func postHello(request: RouterRequest, response: RouterResponse, next: @escaping () -> Void) throws {
        Log.debug("POST - /hello route handler...")
        response.headers["Content-Type"] = "text/plain; charset=utf-8"
        if let name = try request.readString() {
            try response.status(.OK).send("Hello \(name), from Kitura-Starter!").end()
        } else {
            try response.status(.OK).send("Kitura-Starter received a POST request!").end()
        }
    }
    
    public func getJSON(request: RouterRequest, response: RouterResponse, next: @escaping () -> Void) throws {
        Log.debug("GET - /json route handler...")
        response.headers["Content-Type"] = "application/json; charset=utf-8"
        var jsonResponse = JSON([:])
        jsonResponse["framework"].stringValue = "Kitura"
        jsonResponse["applicationName"].stringValue = "Kitura-Starter"
        jsonResponse["company"].stringValue = "IBM"
        jsonResponse["organization"].stringValue = "Swift @ IBM"
        jsonResponse["location"].stringValue = "Austin, Texas"
        try response.status(.OK).send(json: jsonResponse).end()
    }
    
}
