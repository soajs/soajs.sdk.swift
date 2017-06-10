//
//  SoajsSdkTester.swift
//
//  Created by Etienne Daher on 5/22/17.
//  Copyright © 2017 SOAJS. All rights reserved.
//
import UIKit

class SoajsSdkTester: UIViewController {

    /*
     
     if :
     no host
     no port
     no controller
     or no service name
     Runtime Error ---> 'Exception', reason: 'Error: Invalid Controller Port'
     
     ------------------------
     if the controller is off
     ------------------------
      ---> Host unreachable ...
     
     -------------------------------------------------------------
     if the controller is ok and reachable, yet the service is off
     -------------------------------------------------------------
      ---> ["result": 0, "errors": {
     codes =     (
     133
     );
     details =     (
     {
     code = 133;
     message = "The service you are trying to reach is not reachable at this moment.";
     }
     );
     }]
     
     -------------------------------------------------------
     if the controller and the service are ok and responding
     -------------------------------------------------------
      ---> Welcome to the SOAJS SDK tester ...
     ["result": 1, "data": {
     returningTheDataSentInPut = "hp1 - hp2 - bp1 - bp2";
     }]
     ["result": 1, "data": {
     returningTheDataSentInPost = "hp1 - hp2 - bp1 - bp2";
     }]
     ["result": 1, "data": {
     returningTheDataSentInGet = "hp1 - hp2";
     }]
     ["result": 1, "data": {
     returningTheDataSentInDelete = "hp1 - hp2";
     }]
     
     
 */

    override func viewDidLoad() {
        super.viewDidLoad()

        print("Welcome to the SOAJS SDK tester ...")

        // You can initialize your soajs connection using the host and the direct port of the service
        //        let host = "192.168.5.108"
        //        let port = "4098"
        //        let cnx = SoajsConnection(secureProtocol: false, host: host, port: port")

        // or your can initialize it using the controller port and the service name
        let host = "10.0.0.14"
        let controllerPort = "4000"
        let serviceName = "soajstestsdkproject"

        let cnx = SoajsConnection(secureProtocol: false, host: host, controllerPort: controllerPort, serviceName: serviceName)
        let soajsSdk = SoajsSdk(soajsConnection: cnx)
        
        soajsSdk.login(username: "owner", paswword: "password"){ (userLoginResponse) -> () in
            // now soajs sdk is ready to send requests and to get responses
            print(userLoginResponse)
            
            // set your headers
            let headers = ["headerParam1": "hp1" as AnyObject,
                           "headerParam2": "hp2" as AnyObject]
            
            soajsSdk.get(path: "soajsTestSdkGet", headerParams: headers) { (result) -> () in
                self.viewOutput(result: result)
            }
            
            soajsSdk.delete(path: "soajsTestSdkDel", headerParams: headers) { (result) -> () in
                self.viewOutput(result: result)
            }
            
            // set your body
            let body = [
                "bodyParam1": "bp1" as AnyObject,
                "bodyParam2": "bp2" as AnyObject
            ]
            
            soajsSdk.post(path: "soajsTestSdkPost", headerParams: headers, body: body) { (result) -> () in
                self.viewOutput(result: result)
            }
            
            soajsSdk.put(path: "soajsTestSdkPut", headerParams: headers, body: body) { (result) -> () in
                self.viewOutput(result: result)
            }
            
//            soajsSdk.logout(){ (userLogoutResponse) -> () in
//                print(userLogoutResponse)
//            }
            
        }
    }

    func viewOutput(result: [String : AnyObject]) {
        if(result["error"] as! Bool) {
            print("Host unreachable ...") // u also have the error description in errorMessage
        } else {
            let apiResponse = result["apiResponse"] as? [String: Any]
            print(apiResponse!)
        }
    }
}


