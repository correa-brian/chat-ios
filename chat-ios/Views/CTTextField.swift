//
//  CTTextField.swift
//  chat-ios
//
//  Created by Brian Correa on 6/16/16.
//  Copyright © 2016 Velocity 360. All rights reserved.
//

import UIKit

class CTTextField: UITextField {

    required init?(coder aDecoder: NSCoder){
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        let height = frame.size.height
        let width = frame.size.width
        
        self.font = UIFont(name: "Heiti SC", size: 18)
        self.autocorrectionType = .No
        
        let line = UIView(frame: CGRect(x: 0, y: height-1, width: width, height: 1))
        line.backgroundColor = .whiteColor()
        self.addSubview(line)
    }
    
}
