//
//  SoajsSdk.swift
//
//  Created by Etienne Daher on 5/22/17.
//  Copyright © 2017 SOAJS. All rights reserved.
//
import Foundation

class SoajsSdk: SoajsSdkProtocol {

    var soajsConnection = SoajsConnection()
    var utils = Utils()

    /// constructor
    ///
    /// - Parameter soajsConnection: <#soajsConnection description#>
    init(soajsConnection: SoajsConnection) {
        self.soajsConnection = soajsConnection
    }

    init() {
    }

    /// GET api
    ///
    /// - Parameters:
    ///   - path: <#path description#>
    ///   - headerParams: <#headerParams description#>
    ///   - completion: <#completion description#>
    func get(path: String, headerParams: [String: AnyObject], completion: @escaping (_ result: NSMutableDictionary) -> ()) {
        getOrDelete(path: path, headerParams: headerParams, requestMethod: "GET") { (result) -> () in
            completion(result)
        }
    }

    /// DELETE api
    ///
    /// - Parameters:
    ///   - path: <#path description#>
    ///   - headerParams: <#headerParams description#>
    ///   - completion: <#completion description#>
    func delete(path: String, headerParams: [String: AnyObject], completion: @escaping (_ result: NSMutableDictionary) -> ()) {
        getOrDelete(path: path, headerParams: headerParams, requestMethod: "DELETE") { (result) -> () in
            completion(result)
        }
    }

    /// POST api
    ///
    /// - Parameters:
    ///   - path: <#path description#>
    ///   - headerParams: <#headerParams description#>
    ///   - body: <#body description#>
    ///   - completion: <#completion description#>
    func post(path: String, headerParams: [String: AnyObject], body: [String: AnyObject], completion: @escaping (_ result: NSMutableDictionary) -> ()) {
        postOrPut(path: path, headerParams: headerParams, body: body, requestMethod: "POST") { (result) -> () in
            completion(result)
        }
    }

    /// PUT api
    ///
    /// - Parameters:
    ///   - path: <#path description#>
    ///   - headerParams: <#headerParams description#>
    ///   - body: <#body description#>
    ///   - completion: <#completion description#>
    func put(path: String, headerParams: [String: AnyObject], body: [String: AnyObject], completion: @escaping (_ result: NSMutableDictionary) -> ()) {
        postOrPut(path: path, headerParams: headerParams, body: body, requestMethod: "PUT") { (result) -> () in
            completion(result)
        }
    }

    /// post or put common function
    /// send http request, and returns response in a NSMutableDictionary which will have an error flag and an errorMessage or an apiResponse
    /// connection timeout set by user and defaulted to 5 seconds in connection
    ///
    /// - Parameters:
    ///   - path: <#path description#>
    ///   - headerParams: <#headerParams description#>
    ///   - body: <#body description#>
    ///   - requestMethod: <#requestMethod description#>
    ///   - completion: <#completion description#>
    func postOrPut(path: String, headerParams: [String: AnyObject], body: [String: AnyObject], requestMethod: String, completion: @escaping (_ result: NSMutableDictionary) -> ()) {
        let header = utils.constructHeader(headerParams: headerParams)
        let url: URL = URL(string: soajsConnection.getBaseUrl() + path + header)!
        let session = URLSession.shared

        var request = URLRequest(url: url)
        request.httpMethod = requestMethod
        request.cachePolicy = NSURLRequest.CachePolicy.reloadIgnoringCacheData

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body, options: .prettyPrinted) // pass dictionary to nsdata object and set it as request body

        } catch let error {
            print(error.localizedDescription)
        }

        request.timeoutInterval = (soajsConnection.getConnectTimeout() / 1000)

        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")

        let task = session.dataTask(with: request as URLRequest) {
            (data, response, error) in

            guard let data = data, let _: URLResponse = response, error == nil else {
                let output: NSMutableDictionary = NSMutableDictionary()
                output.setValue(true, forKey: "error")
                output.setValue(error, forKey: "errorMessage")
                completion(output)
                return
            }

            let jsonData = try? JSONSerialization.jsonObject(with: data, options: [])

            let output: NSMutableDictionary = NSMutableDictionary()
            output.setValue(false, forKey: "error")
            output.setValue(jsonData, forKey: "apiResponse")

            completion(output)

        }

        task.resume()
    }


    /// get or delete common function
    /// send http request, and returns response in a NSMutableDictionary which will have an error flag and an errorMessage or an apiResponse
    /// connection timeout set by user and defaulted to 5 seconds in connection
    ///
    /// - Parameters:
    ///   - path: <#path description#>
    ///   - headerParams: <#headerParams description#>
    ///   - requestMethod: <#requestMethod description#>
    ///   - completion: <#completion description#>
    func getOrDelete(path: String, headerParams: [String: AnyObject], requestMethod: String, completion: @escaping (_ result: NSMutableDictionary) -> ()) {
        let header = utils.constructHeader(headerParams: headerParams)
        let url: URL = URL(string: soajsConnection.getBaseUrl() + path + header)!
        let session = URLSession.shared

        var request = URLRequest(url: url)
        request.httpMethod = requestMethod
        request.cachePolicy = NSURLRequest.CachePolicy.reloadIgnoringCacheData

        request.timeoutInterval = (soajsConnection.getConnectTimeout() / 1000)

        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")

        let task = session.dataTask(with: request as URLRequest) {
            (data, response, error) in

            guard let data = data, let _: URLResponse = response, error == nil else {

                let output: NSMutableDictionary = NSMutableDictionary()
                output.setValue(true, forKey: "error")
                output.setValue(error, forKey: "errorMessage")
                completion(output)
                return
            }

            //            let dataString =  String(data: data, encoding: String.Encoding.utf8)
            let jsonData = try? JSONSerialization.jsonObject(with: data, options: [])

            let output: NSMutableDictionary = NSMutableDictionary()
            output.setValue(false, forKey: "error")
            output.setValue(jsonData, forKey: "apiResponse")

            completion(output)

        }

        task.resume()
    }

}
