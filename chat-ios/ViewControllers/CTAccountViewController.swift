//
//  CTAccountViewController.swift
//  chat-ios
//
//  Created by Brian Correa on 6/7/16.
//  Copyright © 2016 Velocity 360. All rights reserved.
//

import UIKit

class CTAccountViewController: CTViewController {

    override func loadView() {
        let frame = UIScreen.mainScreen().bounds
        let view = UIView(frame: frame)
        view.backgroundColor = UIColor.redColor()
        
        self.view = view
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
}
