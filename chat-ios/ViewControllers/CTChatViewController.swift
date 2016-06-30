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
    var cameraBtn: UIButton!
    var loaded = false
    
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
        self.chatTable.showsVerticalScrollIndicator = false
        self.chatTable.contentInset = UIEdgeInsetsMake(0, 0, 44, 0)
        self.chatTable.separatorStyle = .None
        self.chatTable.registerClass(CTChatTableViewCell.classForCoder(), forCellReuseIdentifier: "cellId")
        view.addSubview(self.chatTable)
        
        var height = self.chatTable.contentInset.bottom
        let width = frame.size.width
        
        let y = frame.size.height //offscreen bounds; will animate in
        self.bottomView = UIView(frame: CGRect(x: 0, y: y, width: width, height: height))
        self.bottomView.autoresizingMask = .FlexibleTopMargin
        self.bottomView.backgroundColor = UIColor(red: 0.86, green: 0.86, blue: 0.86, alpha: 0.5)
        view.addSubview(bottomView)
        
        let padding = CGFloat(6)
        let btnWidth = CGFloat(80)
        
        self.cameraBtn = UIButton(type: .Custom)
        self.cameraBtn.frame = CGRect(x: 0, y: 0, width: height, height: height)
        self.cameraBtn.backgroundColor = .clearColor()
        self.cameraBtn.setImage(UIImage(named: "camera-icon.png"), forState: .Normal)
        self.cameraBtn.addTarget(self, action: #selector(CTChatViewController.showCameraOptions(_:)), forControlEvents: .TouchUpInside)
        self.bottomView.addSubview(self.cameraBtn)
        
        // Message TextField
        height = height-2*padding
        self.messageField = UITextField(frame: CGRect(x: padding+40, y: padding, width: width-2*padding-btnWidth-40, height: height))
        self.messageField.borderStyle = .RoundedRect
        self.messageField.placeholder = "Post a Message"
        self.messageField.delegate = self
        self.bottomView.addSubview(self.messageField)
        
        
        //Send Button
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
        self.place.visited = true
        self.configureCustomBackButton()
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
                    
                    let lastIndexPath = NSIndexPath(forItem: self.posts.count-1, inSection: 0)
                    
                    self.chatTable.scrollToRowAtIndexPath(
                        lastIndexPath,
                        atScrollPosition: .Top,
                        animated: self.loaded
                    )
                    
                    self.loaded = true
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
    
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        
        dispatch_async(dispatch_get_main_queue(), {
            let post = object as! CTPost
            post.removeObserver(self, forKeyPath: "thumbnailData")
            self.chatTable.reloadData()
        })
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
        
        if (self.selectedImage == nil){
            self.presentViewController(actionSheet, animated: true, completion: nil)
            return
        }
        
        actionSheet.addAction(UIAlertAction(title: "Remove Image", style: .Default, handler: { action in
            
            dispatch_async(dispatch_get_main_queue(), {
                self.selectedImage = nil
                self.cameraBtn.setImage(nil, forState: .Normal)
                
                UIView.transitionWithView(
                    self.cameraBtn,
                    duration: 0.3,
                    options: UIViewAnimationOptions.TransitionFlipFromLeft,
                    animations: {
                    self.cameraBtn.setImage(UIImage(named: "camera-icon.png"), forState: .Normal)
                    },
                    
                    completion: nil)
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
                                
                                //https://res.cloudinary.com/hltq8e6fy/image/upload/v1467130421/rrgs3vusdsn0mdek8d80.jpg
                                
                                var imageUrl = ""
                                if let secure_url = dataDictionary["secure_url"] as? String{
                                    imageUrl = secure_url
                                }
                                
                                //https://res.cloudinary.com/hltq8e6fy/image/upload/t_thumb_250/v1467130421/rrgs3vusdsn0mdek8d80.jpg
                                
                                let thumbnailUrl = imageUrl.stringByReplacingOccurrencesOfString("/upload/", withString: "/upload/t_thumb_250/")
                                
                                let imageInfo = [
                                    "original": imageUrl,
                                    "thumb": thumbnailUrl
                                ]
                                
                                self.postMessageDict(self.preparePostInfo(imageInfo))
                            })
                            
            },
                        andProgress: { (bytesWritten:Int, totalBytesWritten:Int, totalBytesExpectedToWrite:Int, context:AnyObject!) -> Void in
                            
                            print("Upload progress: \((totalBytesWritten * 100)/totalBytesExpectedToWrite) %");
            }
        )
    }
    
    func preparePostInfo(imageInfo: Dictionary<String, AnyObject>) -> Dictionary<String, AnyObject>{
        var postInfo = Dictionary<String, AnyObject>()
        postInfo["from"] = CTViewController.currentUser.id!
        postInfo["message"] = self.messageField.text!
        postInfo["timestamp"] = "\(NSDate().timeIntervalSince1970)"
        postInfo["place"] = self.place.id
        postInfo["image"] = imageInfo
        return postInfo
    }
    
    func postMessage(){
        let loggedIn = self.checkLoggedIn()
        if(loggedIn == false){
            return
        }
        
        let imageInfo = ["original": "", "thumb": ""]
        self.postMessageDict(self.preparePostInfo(imageInfo))
    }
    
    func postMessageDict(postInfo: Dictionary<String, AnyObject>) {
        
        let message = postInfo["messsage"] as! String
        if(message.characters.count == 0){
            print("empty message")
            let alert = UIAlertController(
            title: "No Message",
            message: "Please enter a message",
            preferredStyle: .Alert
            )
            
            alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: { action in
                
                
            }))
            self.presentViewController(alert, animated: true, completion: nil)
            return
    
        }
        
        self.messageField.resignFirstResponder()
        self.messageField.text = ""
        
        if (self.selectedImage != nil){ //upload image first
            self.uploadImage()
            return
        }
        
        UIView.transitionWithView(
            self.cameraBtn,
            duration: 0.3,
            options: UIViewAnimationOptions.TransitionFlipFromLeft,
            animations: {
                self.cameraBtn.setImage(UIImage(named: "camera-icon.png"), forState: .Normal)
                self.cameraBtn.alpha = 1
            }, completion: nil)
        
        //Push Data to Firebase Database
        self.firebase.child(self.place.id).childByAutoId().setValue(postInfo)
    }
    
    //MARK: UIImagePickerControllerDelegate
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String: AnyObject]){
        print("didFinishPickingMediaWithInfo: \(info)")
        
        if let image = info[UIImagePickerControllerEditedImage] as? UIImage{
            self.selectedImage = image
        }
        
        picker.dismissViewControllerAnimated(true, completion: {
            UIView.transitionWithView(
                self.cameraBtn,
                duration: 0.3,
                options: UIViewAnimationOptions.TransitionFlipFromLeft,
                animations: {
                    self.cameraBtn.setImage(self.selectedImage, forState: .Normal)
                    self.cameraBtn.alpha = 1.0
                },
                
                completion: nil)
        })
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController){
        picker.dismissViewControllerAnimated(true, completion: nil)
    }
    
    //MARK: - KeyboardNotifcations:
    
    func shiftKeyboardUp(notification: NSNotification){
        if let keyboardFrame = notification.userInfo![UIKeyboardFrameEndUserInfoKey]?.CGRectValue() {
//            print("\(notification.userInfo!)")
            
            var frame = self.bottomView.frame
            frame.origin.y = keyboardFrame.origin.y-frame.size.height
            self.bottomView.frame = frame
            
            frame = self.chatTable.frame
            frame.origin.y = -keyboardFrame.size.height
            self.chatTable.frame = frame
        }
    }
    
    func shiftKeyboardDown(notfcation: NSNotification){
        var frame = self.bottomView.frame
        frame.origin.y = self.view.frame.size.height-frame.size.height
        self.bottomView.frame = frame
        
        frame = self.chatTable.frame
        frame.origin.y = 0
        self.chatTable.frame = frame
    }
    
    //MARK: - TextField Delegate
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        let loggedIn = self.checkLoggedIn()
        if(loggedIn == false){
            return false
        }
        
        let imageInfo = ["original":"", "thumb":""]
        
        self.postMessageDict(self.preparePostInfo(imageInfo))
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
        
        if(post.thumbnailUrl.characters.count == 0){
            cell.thumbnail.image = nil
            return cell
        }
        
        if(post.thumbnailData != nil){
            cell.thumbnail.image = post.thumbnailData
            return cell
        }
        
        post.addObserver(self, forKeyPath: "thumbnailData", options: .Initial, context: nil)
        post.fetchThumbnail()
        return cell
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return CTChatTableViewCell.defaultHeight
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        print("didSelectRowAtIndexPath")
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }

}
