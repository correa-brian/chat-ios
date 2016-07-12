//
//  CTButton.swift
//  chat-ios
//
//  Created by Brian Correa on 6/14/16.
//  Copyright © 2016 Velocity 360. All rights reserved.
//

import UIKit

class CTButton: UIButton {
    
    required init?(coder aDecoder: NSCoder){
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)

        self.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.65)
        self.layer.borderColor = UIColor.whiteColor().CGColor
        self.layer.borderWidth = 2
        self.layer.cornerRadius = 0.5*frame.size.height
        self.titleLabel?.font = UIFont(name: "Arial", size: 16)
    }

}
