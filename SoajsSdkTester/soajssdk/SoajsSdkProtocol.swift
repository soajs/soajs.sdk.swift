//
//  SoajsSdkProtocol.swift
//
//  Created by Etienne Daher on 5/22/17.
//  Copyright © 2017 SOAJS. All rights reserved.
//
import Foundation

protocol SoajsSdkProtocol {

    func get(path: String, headerParams: [String: AnyObject], completion: @escaping (_ result: NSMutableDictionary) -> ())
    func delete(path: String, headerParams: [String: AnyObject], completion: @escaping (_ result: NSMutableDictionary) -> ())
    func post(path: String, headerParams: [String: AnyObject], body: [String: AnyObject], completion: @escaping (_ result: NSMutableDictionary) -> ())
    func put(path: String, headerParams: [String: AnyObject], body: [String: AnyObject], completion: @escaping (_ result: NSMutableDictionary) -> ())

}
