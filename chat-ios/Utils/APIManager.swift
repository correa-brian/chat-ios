//
//  APIManager.swift
//  chat-ios
//
//  Created by Brian Correa on 6/7/16.
//  Copyright © 2016 Velocity 360. All rights reserved.
//

import UIKit
import Alamofire

class APIManager: NSObject {
    
    static func getRequest(path: String, params:Dictionary<String, AnyObject>?, completion:((results: Dictionary<String, AnyObject>) -> Void)?) {
        
        let url = Constants.baseUrl+path
        
        Alamofire.request(.GET, url, parameters: params).responseJSON { response in
        
            if let json = response.result.value as? Dictionary<String, AnyObject>{
             
                if (completion != nil){
                    completion!(results: json)
                }
            }
        }
        
    }
    
    static func postRequest(path: String, params:Dictionary<String, AnyObject>?, completion:((results: Dictionary<String, AnyObject>) -> Void)?) {
        
        let url = Constants.baseUrl+path
        
        Alamofire.request(.POST, url, parameters: params).responseJSON { response in
            
            if let json = response.result.value as? Dictionary<String, AnyObject>{
                
                if (completion != nil){
                    completion!(results: json)
                }
            }
        }
        
    }

}
