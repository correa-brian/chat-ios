//
//  CTLoginViewController.swift
//  chat-ios
//
//  Created by Brian Correa on 6/10/16.
//  Copyright © 2016 Velocity 360. All rights reserved.
//

import UIKit

class CTLoginViewController: CTViewController, UITextFieldDelegate {

    var textFields = Array<UITextField>()
    
    override func loadView() {
        let frame = UIScreen.mainScreen().bounds
        let view = UIView(frame: frame)
        view.backgroundColor = UIColor.grayColor()
        
        let padding = CGFloat(Constants.padding)
        let width = frame.size.width-2*padding
        let height = CGFloat(32)
        var y = CGFloat(Constants.origin_y)
        
        let fieldNames = ["Email", "Password"]
        
        for fieldName in fieldNames {
            
            let field = CTTextField(frame: CGRect(x: padding, y: y, width: width, height: height))
            field.delegate = self
            field.placeholder = fieldName
            let isPassword = (fieldName == "Password")
            field.secureTextEntry = isPassword
            field.returnKeyType = isPassword ? .Join : .Next
            
            view.addSubview(field)
            self.textFields.append(field)
            y += height+padding
        }
        
        self.view = view
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        let index = self.textFields.indexOf(textField)!
        print("textFieldShouldReturn: \(index)")
        
        if(index == self.textFields.count-1){ //Password Field, register
            print("Sign Up: ")
            
            var missingValue = ""
            var profileInfo = Dictionary<String, AnyObject>()
            for textField in self.textFields{
                if(textField.text?.characters.count == 0){
                    missingValue = textField.placeholder!
                    break
                }
                
                profileInfo[textField.placeholder!.lowercaseString] = textField.text!
            }
            
            // Incomplete:
            if(missingValue.characters.count > 0){
                print("MISSING VALUE")
                let msg = "Your forgot the missing "+missingValue
                let alert = UIAlertController(title: "Missing Value",
                                              message: msg,
                                              preferredStyle: .Alert)
                
                alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
                self.presentViewController(alert, animated: true, completion: nil)
                return true
            }
            
            //            print("\(profileInfo)")
            APIManager.postRequest("/account/login",
                                   params: profileInfo,
                                   completion: { error, response in
                                    
                                    if(error != nil){
                                        let errorObj = error?.userInfo
                                        let errorMsg = errorObj!["message"] as! String
                                        print("ERROR: \(errorMsg)")
                                        
                                        dispatch_async(dispatch_get_main_queue(), {
                                            let alert = UIAlertController(
                                                title: "Error",
                                                message: errorMsg,
                                                preferredStyle: .Alert)
                                            alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
                                            self.presentViewController(alert, animated: true, completion: nil)
                                        })
                                        
                                        return
                                    }
                                    
                                    print("\(response)")
                                    
                                    if let result = response!["currentUser"] as?
                                        Dictionary<String, AnyObject>{
                                        
                                        CTViewController.currentUser.populate(result)
                                        
                                        dispatch_async(dispatch_get_main_queue(), {
                                            self.postLoggedInNotification(result)
                                            let accountVc = CTAccountViewController()
                                            self.navigationController?.pushViewController(accountVc, animated: true)
                                        })

                                    }
                                    
            })
            
            return true
        }
        
        let nextField = self.textFields[index+1]
        nextField.becomeFirstResponder()
        
        return true
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()

    }
    

}
