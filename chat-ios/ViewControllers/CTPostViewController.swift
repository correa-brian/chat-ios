//
//  CTPostViewController.swift
//  chat-ios
//
//  Created by Brian Correa on 7/6/16.
//  Copyright © 2016 Velocity 360. All rights reserved.
//

import UIKit

class CTPostViewController: CTViewController, UIScrollViewDelegate {

    var post: CTPost!
    var postImage: UIImageView!
    var scrollView: UIScrollView!

    
    required init?(coder aDecoder: NSCoder){
        super.init(coder: aDecoder)
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?){
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        self.edgesForExtendedLayout = .None
    }
    
    override func loadView(){
        
        let frame = UIScreen.mainScreen().bounds
        let view = UIView(frame: frame)
        view.backgroundColor = UIColor.blueColor()

        self.postImage = UIImageView(frame: CGRectMake(0, 0, frame.size.width, frame.size.width))
        self.postImage.alpha = 0
        
        let layer = CAGradientLayer()
        layer.frame = CGRect(x: 0, y: 0, width: frame.size.width, height: frame.size.width)
        
        let blk = UIColor(red: 0, green: 0, blue: 0, alpha: 0.7)
        layer.colors = [blk.CGColor, UIColor.clearColor().CGColor]
        self.postImage.layer.addSublayer(layer)
        
        let padding = CGFloat(Constants.padding)
        
        let lblPlace = UILabel(frame: CGRect(x: padding, y: padding, width: frame.size.width-2*padding, height: 22))
        lblPlace.textColor = .whiteColor()
        lblPlace.font = UIFont(name: "Heiti SC", size: 18)
        lblPlace.text = "WeWork Nomad"

        self.postImage.addSubview(lblPlace)
        
        view.addSubview(self.postImage)
        
        self.scrollView = UIScrollView(frame: frame)
        self.scrollView.delegate = self
        self.scrollView.showsVerticalScrollIndicator = false
        self.scrollView.backgroundColor = .clearColor()
        let bgText = UIView(frame: CGRect(x: 0, y: 250, width: frame.size.width, height: frame.size.height))
        bgText.backgroundColor = .whiteColor()
        self.scrollView.addSubview(bgText)
        self.scrollView.contentSize = CGSizeMake(0, 1000)
        view.addSubview(self.scrollView)
        
        self.view = view
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //no image, ignore
        if(self.post.imageUrl.characters.count == 0){
            return
        }
        
        //image already fetched
        if(self.post.imageData != nil){
            self.postImage.alpha = 1
            self.postImage.image = self.post.imageData
            self.postImage.frame = self.resizeFrame(self.postImage.frame, image: self.post.imageData!)
            return
        }
        
        //fetch image:
        self.post.fetchImage({ image in
            dispatch_async(dispatch_get_main_queue(), {
                self.postImage.frame = self.resizeFrame(self.postImage.frame, image: image)
                self.postImage.image = image
                UIView.animateWithDuration(0.3,
                    animations: {
                        self.postImage.alpha = 1
                })
            })
        })
    
    }
    
    func resizeFrame(frame: CGRect, image: UIImage) -> CGRect{
        
        let width = frame.size.width
        let scale = width/image.size.width
        let height = scale*image.size.height
        return CGRect(x: frame.origin.x, y: frame.origin.y, width: width, height: height)
        
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        print("scrollViewDidScroll: \(scrollView.contentOffset.y)")
        
        if(scrollView.contentOffset.y>0){
            self.postImage.transform = CGAffineTransformIdentity
            return
        }
        
        let delta = -scrollView.contentOffset.y //convert to positive
        
        // span 0 to 80
        let scale = 1+(delta/80)
        
        self.postImage.transform = CGAffineTransformMakeScale(scale, scale)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}
