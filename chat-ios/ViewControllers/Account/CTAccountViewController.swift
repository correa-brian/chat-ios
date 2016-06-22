//
//  CTAccountViewController.swift
//  chat-ios
//
//  Created by Brian Correa on 6/7/16.
//  Copyright © 2016 Velocity 360. All rights reserved.
//

import UIKit

class CTAccountViewController: CTViewController {
    
    var loginButtons = Array<UIButton>()
    
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
        
        if (CTViewController.currentUser.id == nil){ // not logged in
            self.loadSignUpView(frame, view: view)
        }
        else{ //logged in
            self.loadAccountView(frame, view: view)
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
        
        self.navigationItem.hidesBackButton = true
        
    }
    
    func loadAccountView(frame: CGRect, view: UIView){

        let padding = CGFloat(Constants.padding)
        let width = frame.size.width-2*padding
        let y = CGFloat(Constants.origin_y)
        
        let nameLabel = UILabel(frame: CGRect(x: padding, y: y, width: width, height: 22))
        nameLabel.text = CTViewController.currentUser.email //change to username
        view.addSubview(nameLabel)

    }
    
    func loadSignUpView(frame: CGRect, view: UIView){
        
        let padding = CGFloat(Constants.padding)
        let width = frame.size.width-2*padding
        let height = CGFloat(44)
        var y = CGFloat(Constants.origin_y)
        
        let buttonTitles = ["Sign Up", "Login"]
        for btnTitle in buttonTitles {
            let btn = CTButton(frame: CGRect(x: padding, y: y, width: width, height: height))
            btn.setTitle(btnTitle, forState: .Normal)
            btn.addTarget(self, action: #selector(CTAccountViewController.buttonTapped(_:)), forControlEvents: .TouchUpInside)
            view.addSubview(btn)
            self.loginButtons.append(btn)
            y += height + padding
        }
        
    }
    
    func buttonTapped(btn: UIButton){
        let buttonTitle = btn.titleLabel?.text?.lowercaseString
        print("buttonTapped: \(buttonTitle!)")
        
        if(buttonTitle == "sign up"){
            let registerVc = CTRegisterViewController()
            self.navigationController?.pushViewController(registerVc, animated: true)
        }
        
        if(buttonTitle == "login"){
            let loginVc = CTLoginViewController()
            self.navigationController?.pushViewController(loginVc, animated: true)
        }
    }
    
    override func userLoggedIn(notification: NSNotification){
        super.userLoggedIn(notification)
        
        if(CTViewController.currentUser.id == nil){
            return
        }
        
        for btn in self.loginButtons{
            btn.alpha = 0
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
}
