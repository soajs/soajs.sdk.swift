//
//  SoajsConnection.swift
//
//  Created by Etienne Daher on 5/22/17.
//  Copyright © 2017 SOAJS. All rights reserved.
//
import Foundation

class SoajsConnection {
    private var connectTimeout: Double = 5000 // connection timeout in milliseconds
    private var secureProtocol: Bool = false // http or https
    private var host: String = "" // host ip
    private var port: String = "" // service direct port
    private var controllerPort: String = "" // controller's port
    private var serviceName: String = "" // service name
    private var baseUrl: String = "" // base URL fetched


    /// Constructor: initialize the connection through controller
    ///
    /// - Parameters:
    ///   - secureProtocol: <#secureProtocol description#>
    ///   - host: <#host description#>
    ///   - controllerPort: <#controllerPort description#>
    ///   - serviceName: <#serviceName description#>
    init(secureProtocol: Bool, host: String, controllerPort: String, serviceName: String) {
        let utils = Utils()

        self.secureProtocol = secureProtocol
        self.host = host
        self.controllerPort = controllerPort
        self.serviceName = serviceName

        self.baseUrl = utils.getBaseUrlUsingController(secureProtocol: secureProtocol, host: host, controllerPort: controllerPort, serviceName: serviceName)
    }


    /// Constructor: initialize the connection directly
    ///
    /// - Parameters:
    ///   - secureProtocol: <#secureProtocol description#>
    ///   - host: <#host description#>
    ///   - port: <#port description#>
    init(secureProtocol: Bool, host: String, port: String) {
        let utils = Utils()

        self.secureProtocol = secureProtocol
        self.host = host
        self.port = port

        self.baseUrl = utils.getBaseUrl(secureProtocol: secureProtocol, host: host, port: port)
    }

    init() { }

    /**
     * SETTORS AND GETTORS
     */

    func getConnectTimeout() -> (Double) {
        return connectTimeout
    }

    func setConnectTimeout(connectTimeout: Double) {
        self.connectTimeout = connectTimeout
    }

    func getSecureProtocol() -> (Bool) {
        return secureProtocol
    }

    func setSecureProtocol(secureProtocol: Bool) {
        self.secureProtocol = secureProtocol
    }

    func getHost() -> (String) {
        return host
    }

    func setHost(host: String) {
        self.host = host
    }

    func getPort() -> (String) {
        return port
    }

    func setPort(port: String) {
        self.port = port
    }

    func getControllerPort() -> (String) {
        return controllerPort
    }

    func setControllerPort(controllerPort: String) {
        self.controllerPort = controllerPort
    }

    func getServiceName() -> (String) {
        return serviceName
    }

    func setServiceName(serviceName: String) {
        self.serviceName = serviceName
    }

    func getBaseUrl() -> (String) {
        return baseUrl
    }

    func setBaseUrl(baseUrl: String) {
        self.baseUrl = baseUrl
    }
}

