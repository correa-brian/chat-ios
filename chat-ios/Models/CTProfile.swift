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
    var image: String!
    
    func populate(profileInfo: Dictionary<String, AnyObject>) {

//        if let _id = profileInfo["id"] as? String{
//            self.id = _id
//        }
//        
//        if let _username = profileInfo["username"] as? String{
//            self.username = _username
//        }
//        
//        if let _email = profileInfo["email"] as? String{
//        self.email = _email
//        }
//        
//        if let _image = profileInfo["image"] as? String{
//        self.image = _image
//        }
        
        let keys = ["id", "username", "email", "image"]
        for key in keys {
            let value = profileInfo[key]
            self.setValue(value, forKey: key)
        }
    }

}
