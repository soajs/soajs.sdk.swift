//
//  SoajsSdkProtocol.swift
//
//  Created by Etienne Daher on 5/22/17.
//  Copyright © 2017 SOAJS. All rights reserved.
//
import Foundation

protocol SoajsSdkProtocol {

    
    func login(username: String, paswword: String, completion: @escaping (_ result: [String : AnyObject]) -> ())
    func login(refreshToken: String, completion: @escaping (_ result: [String : AnyObject]) -> ())
    func logout(completion: @escaping (_ result: Bool) -> ())
    
    func get(path: String, headerParams: [String: AnyObject], completion: @escaping (_ result: [String : AnyObject]) -> ())
    func delete(path: String, headerParams: [String: AnyObject], completion: @escaping (_ result: [String : AnyObject]) -> ())
    func post(path: String, headerParams: [String: AnyObject], body: [String: AnyObject], completion: @escaping (_ result: [String : AnyObject]) -> ())
    func put(path: String, headerParams: [String: AnyObject], body: [String: AnyObject], completion: @escaping (_ result: [String : AnyObject]) -> ())

}
