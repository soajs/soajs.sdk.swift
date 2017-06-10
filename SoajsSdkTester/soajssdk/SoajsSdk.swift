//
//  SoajsSdk.swift
//
//  Created by Etienne Daher on 5/22/17.
//  Copyright © 2017 SOAJS. All rights reserved.
//
import Foundation

class SoajsSdk: SoajsSdkProtocol {

    var utils = Utils()

    var soajsConnection = SoajsConnection()
    var oauthConnection = SoajsConnection()

    let extKey: String = "d44dfaaf1a3ba93adc6b3368816188f96134dfedec7072542eb3d84ec3e3d260f639954b8c0bc51e742c1dff3f80710e3e728edb004dce78d82d7ecd5e17e88c39fef78aa29aa2ed19ed0ca9011d75d9fc441a3c59845ebcf11f9393d5962549"
    var authorization: String = ""

    var access_token: String = ""
    var refresh_token: String = ""

    /// constructor
    ///
    /// - Parameter soajsConnection: <#soajsConnection description#>
    init(soajsConnection: SoajsConnection) {
        self.soajsConnection = soajsConnection

        // TODO handle direct service call
        self.oauthConnection = SoajsConnection(secureProtocol: false, host: soajsConnection.getHost(), controllerPort: soajsConnection.getControllerPort(), serviceName: "oauth")
    }

    init() {
    }

    func login(username: String, paswword: String, completion: @escaping (_ result: [String : AnyObject]) -> ()) {
        setAuthorization() {
            (setAuthorizationResponse) in
            if(setAuthorizationResponse["error"] as! Bool) {
                completion(setAuthorizationResponse)
            } else {
                self.setTokens(username: username, password: paswword, refreshToken: "") {
                    (setTokensSuccess) in
                    //                // expired token test
                    //                self.access_token = "ad69234bb0e4e5598d262a507ebd4544a9c20a7a"
                    //                self.refresh_token = "2888b49d12abdc70f1a7f008791cecffe3b4326b"
                    completion(setTokensSuccess)
                }
            }

        }
    }
    
    func logout(completion: @escaping (_ result: Bool) -> ()) {
        getOrDelete(path: "accessToken/"+self.access_token, headerParams: [:], requestMethod: "DELETE", connection: self.oauthConnection, internalMode: true) {
            (deleteAccessTokenResponse) in
            
            if(deleteAccessTokenResponse["error"] as! Bool) {
                print("Error while logging out (couldnt delete access token)")
                completion(false)
            } else {
                print("Access token deleted successfully")
                self.getOrDelete(path: "refreshToken/"+self.refresh_token, headerParams: [:], requestMethod: "DELETE", connection: self.oauthConnection, internalMode: true) {
                    (deleteRefreshTokenResponse) in
                    
                    if(deleteRefreshTokenResponse["error"] as! Bool) {
                        print("Error while logging out (couldnt delete refresh token)")
                        completion(false)
                    } else {
                        print("Refresh token deleted successfully")
                        completion(true)
                    }
                }
            }
        }
    }

    func login(refreshToken: String, completion: @escaping (_ result: [String : AnyObject]) -> ()) {
        setAuthorization() {
            (setAuthorizationResponse) in
            if(setAuthorizationResponse["error"] as! Bool) {
                completion(setAuthorizationResponse)
            } else {
                self.setTokens(username: "", password: "", refreshToken: refreshToken) {
                    (setTokensResponse) in
                    completion(setTokensResponse)
                }
            }

        }
    }

    func setAuthorization(completion: @escaping (_ result: [String : AnyObject]) -> ()) {
        getOrDelete(path: "authorization", headerParams: [:], requestMethod: "GET", connection: self.oauthConnection, internalMode: true) {
            (authorizationResponse) in

            if(authorizationResponse["error"] as! Bool) {
                print("Couldn't set authorization")
            } else {
                let dictionary = authorizationResponse["apiResponse"] as? [String: Any]
                let data = dictionary?["data"] as? String
                self.authorization = data!
            }
            completion(authorizationResponse)
        }
    }

    func setTokens(username: String, password: String, refreshToken: String, completion: @escaping (_ result: [String : AnyObject]) -> ()) {

        var body: [String: AnyObject]
        if(refreshToken.isEmpty) {
            body = [
                "username": username as AnyObject,
                "password": password as AnyObject,
                "grant_type": "password" as AnyObject
            ]
        } else {
            body = [
                "refresh_token": refreshToken as AnyObject,
                "grant_type": "refresh_token" as AnyObject
            ]
        }

        postOrPut(path: "token", headerParams: [:], body: body, requestMethod: "POST", connection: self.oauthConnection, internalMode: true) { (tokenResponse) -> () in

            if(tokenResponse["error"] as! Bool) {
                print("Couldn't set Tokens")
            } else {
                let dictionary = tokenResponse["apiResponse"] as? [String: Any]
                self.access_token = (dictionary?["access_token"])! as! String
                self.refresh_token = dictionary?["refresh_token"] as! String
            }
            
            completion(tokenResponse)

        }
    }


    /// GET api
    ///
    /// - Parameters:
    ///   - path: <#path description#>
    ///   - headerParams: <#headerParams description#>
    ///   - completion: <#completion description#>
    func get(path: String, headerParams: [String: AnyObject], completion: @escaping (_ result: [String: AnyObject]) -> ()) {
        getOrDelete(path: path, headerParams: headerParams, requestMethod: "GET", connection: self.soajsConnection, internalMode: false) { (response) -> () in

            if(self.isAccessTokenExpired(response: response)) {
                self.login(refreshToken: self.refresh_token) { (result) -> () in
                    self.getOrDelete(path: path, headerParams: headerParams, requestMethod: "GET", connection: self.soajsConnection, internalMode: false) { (response) -> () in
                        completion(response)
                    }
                }
            } else {
                completion(response)
            }
        }
    }

    func isAccessTokenExpired(response: [String: AnyObject]) -> Bool {
        let error = response["error"] as! Bool
        if(error) {
            let errorCode = response["errorCode"] as! Int
            if(errorCode == 401) {
                return true
            }
        }
        return false
    }

//    func filterResponse(response: NSMutableDictionary) -> NSMutableDictionary {
//        let output: NSMutableDictionary = NSMutableDictionary()
//        output.setValue(true, forKey: "error")
//        output.setValue("nada", forKey: "errorMessage")
//
//        print(response)
//
//        if(response.index(ofAccessibilityElement: "error") == nil){ // error on controller level
//            print("111")
//        }else{
//            print("2222")
//        }
//
//        return output
//    }

    /// DELETE api
    ///
    /// - Parameters:
    ///   - path: <#path description#>
    ///   - headerParams: <#headerParams description#>
    ///   - completion: <#completion description#>
    func delete(path: String, headerParams: [String: AnyObject], completion: @escaping (_ result: [String: AnyObject]) -> ()) {
        getOrDelete(path: path, headerParams: headerParams, requestMethod: "DELETE", connection: self.soajsConnection, internalMode: false) { (response) -> () in

            if(self.isAccessTokenExpired(response: response)) {
                self.login(refreshToken: self.refresh_token) { (result) -> () in
                    self.getOrDelete(path: path, headerParams: headerParams, requestMethod: "DELETE", connection: self.soajsConnection, internalMode: false) { (response) -> () in
                        completion(response)
                    }
                }
            } else {
                completion(response)
            }

        }
    }

    /// POST api
    ///
    /// - Parameters:
    ///   - path: <#path description#>
    ///   - headerParams: <#headerParams description#>
    ///   - body: <#body description#>
    ///   - completion: <#completion description#>
    func post(path: String, headerParams: [String: AnyObject], body: [String: AnyObject], completion: @escaping (_ result: [String: AnyObject]) -> ()) {
        postOrPut(path: path, headerParams: headerParams, body: body, requestMethod: "POST", connection: self.soajsConnection, internalMode: false) { (response) -> () in

            if(self.isAccessTokenExpired(response: response)) {
                self.login(refreshToken: self.refresh_token) { (result) -> () in
                    self.postOrPut(path: path, headerParams: headerParams, body: body, requestMethod: "POST", connection: self.soajsConnection, internalMode: false) { (response) -> () in
                        completion(response)
                    }
                }
            } else {
                completion(response)
            }

        }
    }

    /// PUT api
    ///
    /// - Parameters:
    ///   - path: <#path description#>
    ///   - headerParams: <#headerParams description#>
    ///   - body: <#body description#>
    ///   - completion: <#completion description#>
    func put(path: String, headerParams: [String: AnyObject], body: [String: AnyObject], completion: @escaping (_ result: [String: AnyObject]) -> ()) {
        postOrPut(path: path, headerParams: headerParams, body: body, requestMethod: "PUT", connection: self.soajsConnection, internalMode: false) { (response) -> () in
            if(self.isAccessTokenExpired(response: response)) {
                self.login(refreshToken: self.refresh_token) { (result) -> () in
                    self.postOrPut(path: path, headerParams: headerParams, body: body, requestMethod: "PUT", connection: self.soajsConnection, internalMode: false) { (response) -> () in
                        completion(response)
                    }
                }
            } else {
                completion(response)
            }
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
    func postOrPut(path: String, headerParams: [String: AnyObject], body: [String: AnyObject], requestMethod: String, connection: SoajsConnection, internalMode: Bool, completion: @escaping (_ result: [String: AnyObject]) -> ()) {

        var headerParamsCloned = headerParams

        if(!internalMode) {
            headerParamsCloned.updateValue(self.access_token as AnyObject, forKey: "access_token")
        }

        var header = utils.constructHeader(headerParams: headerParamsCloned)
        header = header.replacingOccurrences(of: " ", with: "+", options: .literal, range: nil)
        
        let url: URL = URL(string: connection.getBaseUrl() + path + header)!
        let session = URLSession.shared
        
        var request = URLRequest(url: url)
        request.httpMethod = requestMethod
        request.cachePolicy = NSURLRequest.CachePolicy.reloadIgnoringCacheData

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body, options: .prettyPrinted) // pass dictionary to nsdata object and set it as request body

        } catch let error {
            print(error.localizedDescription)
        }

        request.timeoutInterval = (connection.getConnectTimeout() / 1000)

        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue(extKey, forHTTPHeaderField: "key")

        if(internalMode) {
            request.setValue(self.authorization, forHTTPHeaderField: "Authorization")
        }

        let task = session.dataTask(with: request as URLRequest) {
            (data, response, error) in

            guard let data = data, let _: URLResponse = response, error == nil else {
                var output: [String: AnyObject] = [:]
                output["error"] = true as AnyObject
                output["errorMessage"] = String(describing: error) as AnyObject

                completion(output)
                return
            }

            let jsonData = try? JSONSerialization.jsonObject(with: data, options: [])

            var output: [String: AnyObject] = [:]
            output["error"] = false as AnyObject
            output["apiResponse"] = jsonData as AnyObject

            // filter api response in case of error
            var response = jsonData as! [String: AnyObject]

            if(response["errors"] != nil) {
                var errors = response["errors"] as! [String: AnyObject]
                var details = errors["details"] as! [AnyObject]
                let code = details[0]["code"] as! Int
                let message = details[0]["message"] as! String

                output["error"] = true as AnyObject
                output["errorCode"] = code as AnyObject
                output["errorMessage"] = message as AnyObject
                // and u will still have your apiResponse

            }

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
    func getOrDelete(path: String, headerParams: [String: AnyObject], requestMethod: String, connection: SoajsConnection, internalMode: Bool, completion: @escaping (_ result: [String: AnyObject]) -> ()) {

        var headerParamsCloned = headerParams

        if(!internalMode) {
            headerParamsCloned.updateValue(self.access_token as AnyObject, forKey: "access_token")
        }

        var header = utils.constructHeader(headerParams: headerParamsCloned)
        header = header.replacingOccurrences(of: " ", with: "+", options: .literal, range: nil)
        
        let url: URL = URL(string: connection.getBaseUrl() + path + header)!
        let session = URLSession.shared

        var request = URLRequest(url: url)
        request.httpMethod = requestMethod
        request.cachePolicy = NSURLRequest.CachePolicy.reloadIgnoringCacheData

        request.timeoutInterval = (connection.getConnectTimeout() / 1000)

        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue(extKey, forHTTPHeaderField: "key")

        let task = session.dataTask(with: request as URLRequest) {
            (data, response, error) in

            guard let data = data, let _: URLResponse = response, error == nil else {

                var output: [String: AnyObject] = [:]

                output["error"] = true as AnyObject
                output["errorCode"] = "666" as AnyObject // first level error // controllers level
                output["errorMessage"] = String(describing: error) as AnyObject
                completion(output)
                return
            }

            let jsonData = try? JSONSerialization.jsonObject(with: data, options: [])

            var output: [String: AnyObject] = [:]
            output["error"] = false as AnyObject
            output["apiResponse"] = jsonData as AnyObject

            // filter api response in case of error
            var response = jsonData as! [String: AnyObject]

            if(response["errors"] != nil) {
                var errors = response["errors"] as! [String: AnyObject]

                let details = errors["details"] as! [AnyObject]
                let code = details[0]["code"] as! Int
                let message = details[0]["message"] as! String

                output["error"] = true as AnyObject
                output["errorCode"] = code as AnyObject
                output["errorMessage"] = message as AnyObject
                // and u will still have your apiResponse

            }

            completion(output)

        }

        task.resume()
    }

}
