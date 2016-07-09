//
//  CTAccountViewController.swift
//  chat-ios
//
//  Created by Brian Correa on 6/7/16.
//  Copyright © 2016 Velocity 360. All rights reserved.
//

import UIKit

class CTAccountViewController: CTViewController, UITableViewDelegate, UITableViewDataSource {
    
    var loginButtons = Array<UIButton>()
    var places = Array<CTPlace>()
    var placesTable: UITableView!
    var showsBackButton = false
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        self.title = ""
        self.tabBarItem.title = "Account"
        self.tabBarItem.image = UIImage(named: "profile-icon.png")
        self.edgesForExtendedLayout = .None
    }
    
    override func loadView() {
        let frame = UIScreen.mainScreen().bounds
        let view = UIView(frame: frame)
        view.backgroundColor = .whiteColor()
        
        
        if (CTViewController.currentUser.id == nil){ // not logged in
            self.loadSignupView(frame, view: view)
            
        }
        else { // logged in
            
            self.loadAccountView(frame, view: view)
        }
        
        self.view = view
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.hidesBackButton = !self.showsBackButton
        
        if(self.showsBackButton == false){
            self.loadAccountPlaces()
            return
        }
        
        if (self.showsBackButton){
            let btnCancel = UIButton(type: .Custom)
            let cancelIcon = UIImage(named: "cancel_icon.png")!
            btnCancel.setImage(cancelIcon, forState: .Normal)
            
            btnCancel.frame = CGRect(x: 0, y: 0, width: cancelIcon.size.width, height: 44)
            
            btnCancel.addTarget(
                self,
                action: #selector(CTAccountViewController.exit),
                forControlEvents: .TouchUpInside
            )
            
            self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: btnCancel)
            self.loadAccountPlaces()
        }
    }
    
    func loadAccountPlaces(){
        if(CTViewController.currentUser.id == nil){
            return
        }
        
        let path = "/api/place"
        
        var params = Dictionary<String, AnyObject>()
        params["admins"] = CTViewController.currentUser.id
        params["key"] = Constants.APIKey // temporary
        
        APIManager.getRequest(
            path,
            params: params,
            completion: { response in
                
                if let results = response["results"] as? Array<Dictionary<String, AnyObject>>{
                    print("\(results)")
                    
                    for placeInfo in results {
                        let place = CTPlace()
                        place.populate(placeInfo)
                        self.places.append(place)
                    }
                    
                    dispatch_async(dispatch_get_main_queue(), {
                        self.placesTable.reloadData()
                        
                        UIView.animateWithDuration(
                            1.5,
                            delay: 0,
                            usingSpringWithDamping: 0.5,
                            initialSpringVelocity: 0,
                            options: UIViewAnimationOptions.CurveEaseInOut,
                            animations: {
                                var frame = self.placesTable.frame
                                frame.origin.y = CGFloat(self.placesTable.tag)
                                self.placesTable.frame = frame
                                
                            },
                            completion: nil
                        )
                    })
                }
        })
    }
    
    func loadAccountView(frame: CGRect, view: UIView){
        let padding = CGFloat(Constants.padding)
        let width = frame.size.width-2*padding
        let font = UIFont(name: Constants.baseFont, size: 14)
        
        let userView = UIView(frame: CGRect(x: 0, y: 0, width: frame.size.width, height: 82.5))
        userView.backgroundColor = UIColor(red: 0.88, green: 0.79, blue: 0.95, alpha: 1.0)
        
        let lblUsername = UILabel(frame: CGRect(x: padding, y: padding, width: width, height: 24))
        lblUsername.textColor = .darkGrayColor()
        lblUsername.font = UIFont.boldSystemFontOfSize(24)
        lblUsername.text = CTViewController.currentUser.username
        userView.addSubview(lblUsername)
        
        var y = padding+lblUsername.frame.size.height
        
        let lblEmail = UILabel(frame: CGRect(x: padding, y: y, width: width, height: 18))
        lblEmail.font = font
        lblEmail.textColor = .darkGrayColor()
        lblEmail.text = CTViewController.currentUser.email
        userView.addSubview(lblEmail)
        
        y += padding+lblEmail.frame.size.height
        
        view.addSubview(userView)
        
        let line = UIView(frame: CGRect(x: 0, y: y, width: frame.size.width, height: 0.5))
        line.backgroundColor = .darkGrayColor()
        userView.addSubview(line)
        
        y += line.frame.size.height
        
        let verticalLine = UIView(frame: CGRect(x: 53, y: y, width: 2, height: frame.size.height-y))
        verticalLine.backgroundColor = .grayColor()
        view.addSubview(verticalLine)
        
        self.placesTable = UITableView(frame: CGRect(x: 0, y: frame.size.height, width: frame.size.width, height: frame.size.height-y))
        self.placesTable.tag = Int(y)
        self.placesTable.dataSource = self
        self.placesTable.delegate = self
        self.placesTable.separatorStyle = .None
        self.placesTable.backgroundColor = .clearColor()
        self.placesTable.autoresizingMask = .FlexibleHeight
        self.placesTable.showsVerticalScrollIndicator = false
        self.placesTable.registerClass(CTPlaceTableViewCell.classForCoder(), forCellReuseIdentifier: "cellId")
        self.placesTable.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: frame.size.width, height: 20))
        view.addSubview(self.placesTable)
        
        view.bringSubviewToFront(userView)
        
        let dropShadow = UIImageView(frame: CGRect(x: 0, y: y, width: frame.size.width, height: 12))
        dropShadow.image = UIImage(named: "dropShadow.png")
        view.addSubview(dropShadow)
    }
    
    //MARK: - TableViewDelegate
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("PLACES COUNT: \(self.places.count)")

        return self.places.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let place = self.places[indexPath.row]
        
        let cell = tableView.dequeueReusableCellWithIdentifier(CTPlaceTableViewCell.cellId, forIndexPath: indexPath) as! CTPlaceTableViewCell
        cell.lblTitle.text = place.title
        
        if(place.thumbnailUrl.characters.count == 0){
            return cell
        }
        
        if(place.thumbnailData != nil){
            cell.thumbnail.image = place.thumbnailData
            return cell
        }
        
        place.fetchThumbnail({ image in
            dispatch_async(dispatch_get_main_queue(), {
                cell.thumbnail.image = image

                self.performSelector(
                    #selector(CTAccountViewController.animateCell(_:)),
                    withObject: cell,
                    afterDelay: Double(indexPath.row)/2
                )

            })
        })
        
        return cell
    }
    
    func animateCell(cell: CTPlaceTableViewCell){
        UIView.transitionWithView(
            cell.thumbnail,
            duration: 0.75,
            options: UIViewAnimationOptions.TransitionFlipFromLeft,
            animations: {
                cell.thumbnail.alpha = 1
            },
            completion: nil
        )
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return CTPlaceTableViewCell.defaultHeight
    }
    
    
    //MARK: - Logout
    
    func logout(){
        APIManager.getRequest("/account/logout", params: nil, completion: { response in
            print("\(response)")
            
        })
    }
    
    //MARK: - Load Sign Up View
    
    func loadSignupView(frame: CGRect, view: UIView){
        
        let padding = CGFloat(Constants.padding)
        let width = frame.size.width-2*padding
        let height = CGFloat(44)
        var y = CGFloat(Constants.origin_y)
        
        let buttonTitles = ["Sign Up", "Login"]
        for btnTitle in buttonTitles {
            let btn = CTButton(frame: CGRect(x: padding, y: y, width: width, height: height))
            btn.setTitle(btnTitle, forState: .Normal)
            btn.addTarget(self, action: #selector(CTAccountViewController.buttonTapped(_:)), forControlEvents: .TouchUpInside)
            self.loginButtons.append(btn)
            view.addSubview(btn)
            y += height+padding
        }
        
    }
    
    func buttonTapped(btn: UIButton){
        let buttonTitle = btn.titleLabel?.text?.lowercaseString
        print("buttonTapped: \(buttonTitle!)")
        
        if (buttonTitle == "sign up"){
            let registerVc = CTRegisterViewController()
            registerVc.navigationItem.leftBarButtonItem = self.navigationItem.leftBarButtonItem
            self.navigationController?.pushViewController(registerVc, animated: true)
        }
        
        if (buttonTitle == "login"){
            let loginVc = CTLoginViewController()
            loginVc.navigationItem.leftBarButtonItem = self.navigationItem.leftBarButtonItem
            self.navigationController?.pushViewController(loginVc, animated: true)
        }
    }
    
    override func userLoggedIn(notification: NSNotification){
        super.userLoggedIn(notification)
        if (CTViewController.currentUser.id == nil){
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