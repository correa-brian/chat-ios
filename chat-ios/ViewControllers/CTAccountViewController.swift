//
//  CTAccountViewController.swift
//  chat-ios
//
//  Created by Brian Correa on 6/7/16.
//  Copyright © 2016 Velocity 360. All rights reserved.
//

import UIKit

class CTAccountViewController: CTViewController {
    
    required init?(coder aDecoder: NSCoder){
        super.init(coder: aDecoder)
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?){
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        self.title = "Account"
        self.tabBarItem.image = UIImage(named: "profile-icon.png")
    }

    override func loadView() {
        let frame = UIScreen.mainScreen().bounds
        let view = UIView(frame: frame)
        view.backgroundColor = UIColor.redColor()
        
        let padding = CGFloat(20)
        let width = frame.size.width-2*padding
        let height = CGFloat(44)
        let bgColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.65)
        let whiteColor = UIColor.whiteColor()
        let font = UIFont(name: "Heiti SC", size: 18)
        var y = CGFloat(120)

        let buttonTitles = ["Sign Up", "Login"]
        for btnTitle in buttonTitles {
            let btn = UIButton(type: .Custom)
            btn.frame = CGRect(x: padding, y: y, width: width, height: height)
            btn.backgroundColor = bgColor
            btn.layer.cornerRadius = 0.5*height
            btn.layer.borderWidth = 2
            btn.layer.borderColor = whiteColor.CGColor
            btn.setTitle(btnTitle, forState: .Normal)
            btn.setTitleColor(whiteColor, forState: .Normal)
            btn.titleLabel?.font = font
            btn.addTarget(self, action: #selector(CTAccountViewController.buttonTapped(_:)), forControlEvents: .TouchUpInside)
            view.addSubview(btn)
            y += height + padding
        }
        
//        let btnSignUp = UIButton(type: .Custom)
//        btnSignUp.frame = CGRect(x: padding, y: 0, width: width, height: 44)
//        btnSignUp.center = CGPointMake(0.5*frame.size.width, 0.4*frame.size.height)
//        btnSignUp.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.65)
//        btnSignUp.layer.cornerRadius = 22
//        btnSignUp.layer.borderWidth = 2
//        btnSignUp.layer.borderColor = UIColor.whiteColor().CGColor
//        btnSignUp.setTitle("Sign Up", forState: .Normal)
//        btnSignUp.setTitleColor(.whiteColor(), forState: .Normal)
//        btnSignUp.titleLabel?.font = UIFont(name: "Heiti SC", size: 18)
//        view.addSubview(btnSignUp)
//        
//        let btnLogin = UIButton(type: .Custom)
//        btnLogin.frame = CGRect(x: padding, y: 0, width: width, height: 44)
//        btnLogin.center = CGPointMake(0.5*frame.size.width, 0.6*frame.size.height)
//        btnLogin.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.65)
//        btnLogin.layer.cornerRadius = 22
//        btnLogin.layer.borderWidth = 2
//        btnLogin.layer.borderColor = UIColor.whiteColor().CGColor
//        btnLogin.setTitle("Login", forState: .Normal)
//        btnLogin.setTitleColor(.whiteColor(), forState: .Normal)
//        btnLogin.titleLabel?.font = UIFont(name: "Heiti SC", size: 18)
//        view.addSubview(btnLogin)
        
        
        self.view = view
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    func buttonTapped(btn: UIButton){
        let buttonTitle = btn.titleLabel?.text?.lowercaseString
        print("buttonTapped: \(buttonTitle!)")
        
        if(buttonTitle == "sign up"){
            let registerVc = CTRegisterViewController()
            self.navigationController?.pushViewController(registerVc, animated: true)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
}
