//
//  CTChatViewController.swift
//  chat-ios
//
//  Created by Brian Correa on 6/16/16.
//  Copyright © 2016 Velocity 360. All rights reserved.
//

import UIKit
import Firebase
import Cloudinary

class CTChatViewController: CTViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, CLUploaderDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
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
    var selectedImage: UIImage?
    
    // MARK: - Lifecycle Methods
    required init?(coder aDecoder: NSCoder){
        super.init(coder: aDecoder)
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?){
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
        self.hidesBottomBarWhenPushed = true
        
        let notificationCenter = NSNotificationCenter.defaultCenter()
        
        notificationCenter.addObserver(
        self,
        selector: #selector(CTChatViewController.shiftKeyboardUp(_:)),
        name: UIKeyboardWillShowNotification,
        object: nil
        )
        
        notificationCenter.addObserver(
            self,
            selector: #selector(CTChatViewController.shiftKeyboardDown(_:)),
            name: UIKeyboardWillHideNotification,
            object: nil
        )
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
        
        var height = CGFloat(44)
        let width = frame.size.width
        
        let y = frame.size.height //offscreen bounds; will animate in
        self.bottomView = UIView(frame: CGRect(x: 0, y: y, width: width, height: height))
        self.bottomView.autoresizingMask = .FlexibleTopMargin
        self.bottomView.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.75)
        view.addSubview(bottomView)
        
        let padding = CGFloat(6)
        let btnWidth = CGFloat(80)
        height = height-2*padding
        
        let camerBtn = UIButton(type: .Custom)
        camerBtn.frame = CGRect(x: padding, y: padding, width: height, height: height)
        camerBtn.backgroundColor = .redColor()
        camerBtn.addTarget(self, action: #selector(CTChatViewController.showCameraOptions(_:)), forControlEvents: .TouchUpInside)
        self.bottomView.addSubview(camerBtn)
        
        self.messageField = UITextField(frame: CGRect(x: padding+40, y: padding, width: width-2*padding-btnWidth-40, height: height))
        self.messageField.borderStyle = .RoundedRect
        self.messageField.placeholder = "Post a Message"
        self.messageField.delegate = self
        self.bottomView.addSubview(self.messageField)
        
        let btnSend = UIButton(type: .Custom)
        btnSend.frame = CGRect(x: width-btnWidth, y: padding, width: 74, height: height)
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
        
        if(self._refHandle != nil){
            return
        }
        
        //Listen for new messages in the FB DB
        self._refHandle = self.firebase.child(self.place.id).queryLimitedToLast(25).observeEventType(.Value, withBlock: { (snapshot) -> Void in
            
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
        
        //already on screen
        let bottomFrame = self.bottomView.frame
        if(bottomFrame.origin.y < self.view.frame.size.height){
            return
        }
        
        
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
    
    //MARK: - Camera ActionSheet
    
    func showCameraOptions(btn: UIButton){
        print("showCameraOptions: ")
        
        let actionSheet = UIAlertController(title: "Photo", message: "Select Source", preferredStyle: .ActionSheet)
        
        actionSheet.addAction(UIAlertAction(title: "Camera", style: .Default, handler: { action in
            print("Select Camera: \(action.title!)")
            dispatch_async(dispatch_get_main_queue(), {
                self.launchPhotoPicker(.Camera)
            })
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Photo Library", style: .Default, handler: { action in
            print("Photo Library: \(action.title!)")
            
            dispatch_async(dispatch_get_main_queue(), {
                self.launchPhotoPicker(.PhotoLibrary)
            })
        }))
        
        self.presentViewController(actionSheet, animated: true, completion: nil)
    }
    
    func launchPhotoPicker(soureType: UIImagePickerControllerSourceType){
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = soureType
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        self.presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    //MARK: - Image Processing
    
    func uploadImage(){
        if(self.selectedImage == nil){
            return
        }
        
        print("uploadImage: ")
        
        //CLOUDINARY_URL=cloudinary://317483526839272:LyZuryF3e_Ny9GcNwAlj_2j4bAU@hltq8e6fy
        
        let clouder = CLCloudinary(url:"cloudinary://317483526839272:LyZuryF3e_Ny9GcNwAlj_2j4bAU@hltq8e6fy")
        let forUpload = UIImageJPEGRepresentation(self.selectedImage!, 0.5)
        
        let uploader = CLUploader(clouder, delegate: self)
        
        uploader.upload(forUpload, options: nil,
                        
                        withCompletion: { (dataDictionary: [NSObject: AnyObject]!, errorResult:String!, code:Int, context: AnyObject!) -> Void in
                            
                            print("Upload Response: \(dataDictionary)")
                            
                            // self.uploadResponse = Mapper<ImageUploadResponse>().map(dataDictionary)
                            
                            // if code < 400 { onCompletion(status: true, url: self.uploadResponse?.imageURL)}
                            
                            // else {onCompletion(status: false, url: nil)}
                            
                            dispatch_async(dispatch_get_main_queue(),{
                                self.selectedImage = nil
                                var imageUrl = ""
                                if let secure_url = dataDictionary["secure_url"] as? String{
                                    imageUrl = secure_url
                                }
                                
                                self.postMessageDict(self.preparePostInfo(imageUrl))
                            })
                            
            },
                        andProgress: { (bytesWritten:Int, totalBytesWritten:Int, totalBytesExpectedToWrite:Int, context:AnyObject!) -> Void in
                            
                            print("Upload progress: \((totalBytesWritten * 100)/totalBytesExpectedToWrite) %");
            }
        )
    }
    
    func preparePostInfo(imageUrl: String) -> Dictionary<String, AnyObject>{
        let postInfo = [
            "from": CTViewController.currentUser.id!,
            "message":self.messageField.text!,
            "timestamp": "\(NSDate().timeIntervalSince1970)",
            "place":self.place.id,
            "image": imageUrl
        ]
        return postInfo
    }
    
    func postMessage(){
        self.postMessageDict(self.preparePostInfo(""))
    }
    
    func postMessageDict(postInfo: Dictionary<String, AnyObject>) {
        
        self.messageField.resignFirstResponder()
        self.messageField.text = nil
        
        if (self.selectedImage != nil){ //upload image first
            self.uploadImage()
            return
        }
        
        //Push Data to Firebase Database
        self.firebase.child(self.place.id).childByAutoId().setValue(postInfo)
    }
    
    //MARK: UIImagePickerControllerDelegate
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String: AnyObject]){
        print("didFinishPickingMediaWithInfo: \(info)")
        
        if let image = info[UIImagePickerControllerEditedImage] as? UIImage{
            self.selectedImage = image
        }
        
        picker.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController){
        picker.dismissViewControllerAnimated(true, completion: nil)
    }
    
    //MARK - KeyboardNotifcations:
    
    func shiftKeyboardUp(notification: NSNotification){
        if let keyboardFrame = notification.userInfo![UIKeyboardFrameEndUserInfoKey]?.CGRectValue() {
//            print("\(notification.userInfo!)")
            
            var frame = self.bottomView.frame
            frame.origin.y = keyboardFrame.origin.y-frame.size.height
            self.bottomView.frame = frame
        }
    }
    
    func shiftKeyboardDown(notfcation: NSNotification){
        var frame = self.bottomView.frame
        frame.origin.y = self.view.frame.size.height-frame.size.height
        self.bottomView.frame = frame
    }
    
    //MARK: - TextField Delegate
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        self.postMessageDict(self.preparePostInfo(""))
        return true
    }
    
    //MARK: - TableView Delegate
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        self.messageField.resignFirstResponder()
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.posts.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let post = self.posts[indexPath.row]
        
        let cell = tableView.dequeueReusableCellWithIdentifier(CTChatTableViewCell.cellId, forIndexPath: indexPath) as! CTChatTableViewCell
        cell.messageLabel.text = post.message
        cell.dateLabel.text = post.formattedDate
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        print("didSelectRowAtIndexPath")
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }

}
