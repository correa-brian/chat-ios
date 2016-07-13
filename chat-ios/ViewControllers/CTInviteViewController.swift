//
//  CTInviteViewController.swift
//  chat-ios
//
//  Created by Brian Correa on 7/12/16.
//  Copyright © 2016 Velocity 360. All rights reserved.
//

import UIKit
import AddressBookUI
import AddressBook

class CTInviteViewController: CTViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, UIScrollViewDelegate {
    
    var contactTable: UITableView!
    var searchField: UISearchBar!

    var contacts = Array<CTContact>()
    
    //MARK: - Lifecycle Methods
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
        self.edgesForExtendedLayout = .None
        
        let list = [
        ["firstName":"John F. Kennedy", "state": "New York"],
        ["firstName":"Bill Clinton", "state": "Arkansas"],
        ["firstName":"Hilary Clinton", "state": "Illinois"],
        ["firstName":"George H.W. Bush", "state": "Connecticut"],
        ["firstName":"Donald Trump", "state": "New York"],
        ["firstName":"Ronald Reagan", "state": "California"],
        ["firstName":"George W. Bush", "state": "Texas"],
        ["firstName":"Barack Obama", "state": "Illinois"],
        ["firstName":"Jimmy Carter", "state": "Georgia"],
        ["firstName":"Abraham Lincoln", "state": "Illinois"],
        ["firstName":"Richard Nixon", "state": "Alaska"],
        ["firstName":"Calvin Coolidge", "state": "Michigan"],
        ["firstName":"George Washington", "state": "Pennsylvania"],
        ["firstName":"John Adams", "state": "Massachusetts"],
        ["firstName":"Thomas Jefferson", "state": "Massachusetts"],
        ["firstName":"James Madison", "state": "Virginia"],
        ["firstName":"Andrew Jackson", "state": "New Jersey"],
        ["firstName":"James Monroe", "state": "New York"],
        ["firstName":"Grover Cleveland", "state": "Delaware"],
        ["firstName":"James Garfield", "state": "Florida"],
        ["firstName":"Ulysses Grant", "state": "Massachusetts"],
        ]
        
        for contactInfo in list {
            let contact = CTContact()
            contact.populate(contactInfo)
            self.contacts.append(contact)
        }
    }
    
    override func loadView(){
        let frame = UIScreen.mainScreen().bounds
        let view = UIView(frame: frame)
        view.backgroundColor = .greenColor()
        
        let topView = UIView(frame: CGRect(x: 0, y: 0, width: frame.size.width, height: 106))
        topView.autoresizingMask = .FlexibleTopMargin
        topView.backgroundColor = UIColor(red: 0.5, green: 0, blue: 0.5, alpha: 1)
        
        let y = CGFloat(15)
        let padding = CGFloat(6)
        let width = frame.size.width
        let height = CGFloat(44)
        
        let btnCancel = UIButton(type: .Custom)
        btnCancel.frame = CGRect(x: padding, y: y, width: height, height: height)
        btnCancel.setImage(UIImage(named: "cancel_icon.png"), forState: .Normal)
        btnCancel.setTitleColor(.whiteColor(), forState: .Normal)
        btnCancel.addTarget(self,
                            action: #selector(CTViewController.exit),
                            forControlEvents: .TouchUpInside)
        topView.addSubview(btnCancel)

        self.searchField = UISearchBar(frame: CGRect(x: 0, y: topView.frame.size.height-height, width: width, height: height))
        self.searchField.delegate = self
        self.searchField.placeholder = "Search Your Contacts"
        topView.addSubview(self.searchField)
    
        view.addSubview(topView)
        
        self.contactTable = UITableView(frame: frame, style: .Plain)
        self.contactTable.delegate = self
        self.contactTable.dataSource = self
        self.contactTable.contentInset = UIEdgeInsetsMake(topView.frame.size.height, 0, 0, 0)
        self.contactTable.registerClass(UITableViewCell.classForCoder(), forCellReuseIdentifier: "cellId")
        view.addSubview(self.contactTable)
        view.bringSubviewToFront(topView)
        
        self.view = view
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.contacts.sortInPlace {
            $0.firstName!.compare($1.firstName!) == .OrderedAscending
        }
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        print("textDidChange: \(searchText)")
    }
    
    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        self.searchField.resignFirstResponder()
    }
    
    //MARK: - TableView Delegates
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contacts.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let contact = self.contacts[indexPath.row]
        let cell = tableView.dequeueReusableCellWithIdentifier("cellId", forIndexPath: indexPath)
        cell.textLabel?.text = contact.firstName
        return cell
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}
