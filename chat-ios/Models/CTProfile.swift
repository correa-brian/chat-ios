//
//  CTProfile.swift
//  chat-ios
//
//  Created by Brian Correa on 6/9/16.
//  Copyright © 2016 Velocity 360. All rights reserved.
//

import UIKit

class CTProfile: NSObject {
    
    var id: String?
    var username: String!
    var email: String!
    var image: Dictionary<String, AnyObject>!
    
    func populate(profileInfo: Dictionary<String, AnyObject>) {
        
        let keys = ["id", "username", "email", "image"]
        for key in keys {
            let value = profileInfo[key]
            self.setValue(value, forKey: key)
        }
    }
}
