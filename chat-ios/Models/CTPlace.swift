//
//  CTPlace.swift
//  chat-ios
//
//  Created by Brian Correa on 6/7/16.
//  Copyright © 2016 Velocity 360. All rights reserved.
//

import UIKit
import MapKit
import Alamofire

class CTPlace: NSObject, MKAnnotation {
    
    var id: String!
    var name: String!
    var city: String!
    var state: String!
    var zip: String!
    var address: String!
    var password: String!
    var admins: Array<String>!
    var lat: Double!
    var lng: Double!
    var visited = false
    
    var image: Dictionary<String,AnyObject>!
    var thumbnailUrl: String!
    var thumbnailData: UIImage?
    var isFetching = false
    
    func populate(placeInfo: Dictionary<String, AnyObject>){
        
        let keys = ["name", "city", "state", "address", "zip", "id", "password", "admins", "image"]
        
        for key in keys {
            let value = placeInfo[key]
            self.setValue(value, forKey: key)
        }
        
        if let _geo = placeInfo["geo"] as? Array<Double> {
            self.lat = _geo[0]
            self.lng = _geo[1]
        }
        
        if (self.image == nil){
            return
        }
        
        if let _thumbnailUrl = self.image["thumb"] as? String?{
            self.thumbnailUrl = _thumbnailUrl
        }
    }
    
    func fetchThumbnail(completion: ((image: UIImage) -> Void)?){
        
        if (self.thumbnailUrl.characters.count == 0){
            return
        }
        
        if(self.thumbnailData != nil){
            return
        }
        
        if (self.isFetching == true){
            return
        }
        
        self.isFetching = true
        Alamofire.request(.GET, self.thumbnailUrl, parameters: nil).response { (req, res, data, error) in
            self.isFetching = false
            if (error != nil){
                return
            }
            
            if let img = UIImage(data: data!){
                self.thumbnailData = img
                
                if(completion == nil){
                    return
                }
                completion!(image: img)
            }
            
        }
        
    }

    //MARK: - MKAnnotation Overrides
    
    var title: String? {
        return self.name
    }
    
    var subtitle: String? {
        return self.address
    }
    
    var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2DMake(self.lat, self.lng)
    }
    
}
