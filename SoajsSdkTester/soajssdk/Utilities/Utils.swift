//
//  Utils.swift
//
//  Created by Etienne Daher on 5/22/17.
//  Copyright © 2017 SOAJS. All rights reserved.
//
import Foundation

class Utils {

    /// construct base url using controller
    /// ex: http://192.168.2.23:4000/soajsTestSdkDel/
    ///
    /// - Parameters:
    ///   - secureProtocol: <#secureProtocol description#>
    ///   - host: <#host description#>
    ///   - port: <#port description#>
    /// - Returns: <#return value description#>
    func getBaseUrl(secureProtocol: Bool, host: String, port: String) -> String {
        var baseUrl: String;

        if (host).isEmpty {
            NSException.raise(NSExceptionName(rawValue: "Exception"), format: "Error: %@", arguments: getVaList(["Invalid Host"]))
        }

        if (port).isEmpty {
            NSException.raise(NSExceptionName(rawValue: "Exception"), format: "Error: %@", arguments: getVaList(["Invalid Port"]))
        }

        if(secureProtocol) {
            baseUrl = "https://"
        } else {
            baseUrl = "http://"
        }

        baseUrl += host + ":" + port + "/"
        return baseUrl
    }

    /// construct base url without controller
    /// ex: http://192.168.2.23/4096/
    ///
    /// - Parameters:
    ///   - secureProtocol: <#secureProtocol description#>
    ///   - host: <#host description#>
    ///   - controllerPort: <#controllerPort description#>
    ///   - serviceName: <#serviceName description#>
    /// - Returns: <#return value description#>
    func getBaseUrlUsingController(secureProtocol: Bool, host: String, controllerPort: String, serviceName: String) -> String {
        var baseUrl: String;


        if (host).isEmpty {
            NSException.raise(NSExceptionName(rawValue: "Exception"), format: "Error: %@", arguments: getVaList(["Invalid Host"]))
        }

        if (controllerPort).isEmpty {
            NSException.raise(NSExceptionName(rawValue: "Exception"), format: "Error: %@", arguments: getVaList(["Invalid Controller Port"]))
        }

        if (serviceName).isEmpty {
            NSException.raise(NSExceptionName(rawValue: "Exception"), format: "Error: %@", arguments: getVaList(["Invalid Service Name"]))
        }

        if(secureProtocol) {
            baseUrl = "https://"
        } else {
            baseUrl = "http://"
        }

        baseUrl += host + ":" + controllerPort + "/" + serviceName + "/"

        return baseUrl
    }

    /// construct query header from an array of params
    ///
    /// - Parameter headerParams: <#headerParams description#>
    /// - Returns: <#return value description#>
    func constructHeader(headerParams: [String: AnyObject]) -> String {
        var header: String = ""
        
        if (headerParams).isEmpty {
            return header
        }

        // it has at least one
        var counter: Int = 0


        for (key, value) in headerParams {

            if(counter == 0) {
                header += "?" + key
            } else {
                header += "&" + key
            }

            header += "=" + String(describing: value)

            counter += 1
        }

        return header;
    }
}
