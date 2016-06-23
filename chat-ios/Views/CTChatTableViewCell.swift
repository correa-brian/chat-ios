//
//  CTChatTableViewCell.swift
//  chat-ios
//
//  Created by Brian Correa on 6/16/16.
//  Copyright © 2016 Velocity 360. All rights reserved.
//

import UIKit

class CTChatTableViewCell: UITableViewCell {
    
    static var cellId = "cellId"
    var messageLabel: UILabel!
    var dateLabel: UILabel!
    
    required init?(coder aDecoder: NSCoder){
        super.init(coder: aDecoder)
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?){
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        let frame = UIScreen.mainScreen().bounds
        
        let y = CGFloat(12)
        
        self.dateLabel = UILabel(frame: CGRect(x: 12, y: y, width: frame.size.width-24, height: 22))
        self.dateLabel.backgroundColor = .whiteColor()
        self.dateLabel.font = UIFont(name: "Heiti SC", size: 12)
        self.contentView.addSubview(self.dateLabel)
        
        self.messageLabel = UILabel(frame: CGRect(x: 12, y: 36, width: frame.size.width-24, height: 22))
        self.messageLabel.backgroundColor = .whiteColor()
        self.contentView.addSubview(self.messageLabel)
    }

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
