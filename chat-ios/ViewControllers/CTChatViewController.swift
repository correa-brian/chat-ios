//
//  CTChatViewController.swift
//  chat-ios
//
//  Created by Brian Correa on 6/16/16.
//  Copyright © 2016 Velocity 360. All rights reserved.
//

import UIKit
import Firebase

class CTChatViewController: CTViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    
    //MARK: - Firebase Config:
    var firebase: FIRDatabaseReference! // establishes connection and maintains connection to DB
    var _refHandle: UInt!
    
    // MARK: - Properties
    
    var place: CTPlace!
    var chatTable: UITableView!
    var posts = Array<CTPost>()
    var keys = Array<String>()
    
    var bottomView: UIView!
    var messageField: UITextField!
    
    // MARK: - Lifecycle Methods
    
    required init?(coder aDecoder: NSCoder){
        super.init(coder: aDecoder)
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?){
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
        self.hidesBottomBarWhenPushed = true
    }
    
    override func loadView(){
        let frame = UIScreen.mainScreen().bounds
        let view = UIView(frame: frame)
        view.backgroundColor = .grayColor()
        
        self.chatTable = UITableView(frame: frame, style: .Plain)
        self.chatTable.dataSource = self
        self.chatTable.delegate = self
        self.chatTable.registerClass(CTChatTableViewCell.classForCoder(), forCellReuseIdentifier: "cellId")
        view.addSubview(self.chatTable)
        
        let height = CGFloat(44)
        let width = frame.size.width
        
        let y = frame.size.height //offscreen bounds; will animate in
        self.bottomView = UIView(frame: CGRect(x: 0, y: y, width: width, height: height))
        self.bottomView.autoresizingMask = .FlexibleTopMargin
        self.bottomView.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5)
        view.addSubview(bottomView)
        
        let padding = CGFloat(6)
        let btnWidth = CGFloat(80)
        
        self.messageField = UITextField(frame: CGRect(x: padding, y: padding, width: width-2*padding-btnWidth, height: height-2*padding))
        self.messageField.borderStyle = .RoundedRect
        self.messageField.placeholder = "Post a Message"
        self.messageField.delegate = self
        self.bottomView.addSubview(self.messageField)
        
        let btnSend = UIButton(type: .Custom)
        btnSend.frame = CGRect(x: width-btnWidth, y: padding, width: 74, height: height-2*padding)
        btnSend.setTitle("Send", forState: .Normal)
        btnSend.backgroundColor = UIColor.lightGrayColor()
        btnSend.layer.cornerRadius = 5
        btnSend.layer.masksToBounds = true
        btnSend.layer.borderColor = UIColor.darkGrayColor().CGColor
        btnSend.layer.borderWidth = 0.5
        self.bottomView.addSubview(btnSend)
        btnSend.addTarget(self, action: #selector(CTChatViewController.postMessage), forControlEvents: .TouchUpInside)
        
        self.view = view
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.firebase = FIRDatabase.database().reference() // initialize FB manager
    }
    
    override func viewWillAppear(animated: Bool) {
        print("viewWillAppear:")
        
        //Listen for new messages in the FB DB
        self._refHandle = self.firebase.child(self.place.id).observeEventType(.Value, withBlock: { (snapshot) -> Void in
            
            if let payload = snapshot.value as? Dictionary<String, AnyObject> {
                
                for key in payload.keys {
                    let postInfo = payload[key] as! Dictionary<String, AnyObject>
//                    print("POST == \(post)")
                    if(self.keys.contains(key)){
                        continue
                    }
                    
                    self.keys.append(key)
                    let post = CTPost()
                    post.id = key
                    post.populate(postInfo)
                    self.posts.append(post)
                    
                }
                
                print("\(self.posts.count) POSTS")
                self.posts.sortInPlace{
                    $0.timestamp.compare($1.timestamp) == .OrderedAscending
                }
                
                dispatch_async(dispatch_get_main_queue(), {
                    self.chatTable.reloadData()
                })
            }
        })
    }
    
    override func viewDidAppear(animated: Bool) {
        print("viewDidAppear")
        UIView.animateWithDuration(0.35,
                                   delay: 0.25,
                                   options: UIViewAnimationOptions.CurveLinear,
                                   animations: {
                                    var bottomFrame = self.bottomView.frame
                                    bottomFrame.origin.y = bottomFrame.origin.y-self.bottomView.frame.size.height
                                    self.bottomView.frame = bottomFrame
            },
                                   completion: nil)
    }
    
    override func viewWillDisappear(animated: Bool) {
        self.firebase.removeObserverWithHandle(self._refHandle)
        
    }
    
    //Helper Methods
    
    func postMessage(){
        print("postMessage")
        messageField.resignFirstResponder()
        
        //Push data to Firebase Database
        let timestamp = NSDate().timeIntervalSince1970
        let post = [
            "from": CTViewController.currentUser.id!,
            "message":self.messageField.text!,
            "timestamp": "\(timestamp)",
            "place":self.place.id
        ]
        
        self.firebase.child(self.place.id).childByAutoId().setValue(post)
        
        self.messageField.text = nil
        self.shiftView(0)
        
    }
    
    func shiftView(position: CGFloat){
        
        if(self.view.frame.origin.y == position){
            return
        }
        
        UIView.animateWithDuration(0.25,
                                   delay: 0,
                                   options: .CurveEaseInOut,
                                   animations: {
                                    var frame = self.view.frame
                                    frame.origin.y = position
                                    self.view.frame = frame
            },
                                   completion: nil)
        
    }
    
    //MARK: - TextField Delegate
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        messageField.resignFirstResponder()
        
        self.postMessage()
        return true
    }
    
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        
        self.shiftView(-270)
        return true
    }
    
    //MARK: - TableView Delegate
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.posts.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let post = self.posts[indexPath.row]
        
        let cell = tableView.dequeueReusableCellWithIdentifier(CTChatTableViewCell.cellId, forIndexPath: indexPath)
        cell.textLabel?.text = post.message
        return cell
        
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        print("didSelectRowAtIndexPath")
        
//        //Push data to Firebase Database
//        let timestamp = NSDate().timeIntervalSince1970
//        let post = [
//            "from": CTViewController.currentUser.id!,
//            "message":"this is a test - BC1",
//            "timestamp": "\(timestamp)",
//            "place":self.place.id
//        ]
//        
//        self.firebase.child(self.place.id).childByAutoId().setValue(post)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }

}
