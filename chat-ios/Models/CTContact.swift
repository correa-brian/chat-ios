//
//  CTContact.swift
//  chat-ios
//
//  Created by Brian Correa on 7/13/16.
//  Copyright © 2016 Velocity 360. All rights reserved.
//

import UIKit

class CTContact: NSObject {

    var firstName: String?
    var lastName: String?
    var phone: String?
    
    func populate(contactInfo: Dictionary<String, AnyObject>){
        if let _firstName = contactInfo["firstName"] as? String {
            self.firstName = _firstName
        }
        
        if let _lastName = contactInfo["lastName"] as? String {
            self.lastName = _lastName
        }
        
        if let _phone = contactInfo["phone"] as? String {
            self.phone = _phone
        }
    }
    
}
