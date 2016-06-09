//
//  CTViewController.swift
//  chat-ios
//
//  Created by Brian Correa on 6/7/16.
//  Copyright © 2016 Velocity 360. All rights reserved.
//

import UIKit

class CTViewController: UIViewController {
    
    var currentUser: CTProfile?
    
    required init?(coder aDecoder: NSCoder){
        super.init(coder: aDecoder)
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?){
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
        let notificationCenter = NSNotificationCenter.defaultCenter()
        notificationCenter.addObserver(self,
                                       selector: #selector(CTViewController.userLoggedIn(_:)),
                                       name: Constants.kUserLoggedInNotification,
                                       object: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if(self.currentUser == nil){
            return
        }
        
        print("CurrentUser: \(self.currentUser?.username)")
    }
    
    func userLoggedIn(notification: NSNotification){
        print("userLoggedIn: \(notification.userInfo)")
        
        let user = notification.userInfo!["user"] as? CTProfile
        self.currentUser = user
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()

    }

}
