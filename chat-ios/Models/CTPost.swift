//
//  CTPost.swift
//  chat-ios
//
//  Created by Brian Correa on 6/22/16.
//  Copyright © 2016 Velocity 360. All rights reserved.
//

import UIKit

class CTPost: NSObject {
    
    var id: String!
    var message: String!
    var place: String!
    var from: String!
    var timestamp: NSDate!

    func populate(postInfo: Dictionary<String, AnyObject!>){
        let keys = ["message", "place", "from"]
        for key in keys {
            self.setValue(postInfo[key], forKey: key)
        }
        
        if let _timestamp = postInfo["timestamp"] as? String {
            //print("TIMESTAMP: \(_timestamp)")
            
            let ts = NSTimeInterval(_timestamp)
            self.timestamp = NSDate(timeIntervalSince1970: ts!)
            print("DATE: \(self.timestamp)")
        }
    }
    
}
