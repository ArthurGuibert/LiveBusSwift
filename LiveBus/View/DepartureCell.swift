//
//  DepartureCell.swift
//  LiveBus
//
//  Created by Arthur GUIBERT on 01/02/2015.
//  Copyright (c) 2015 Arthur GUIBERT. All rights reserved.
//

import UIKit

class DepartureCell: UITableViewCell {
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var directionLabel: UILabel!
    @IBOutlet weak var lineLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Set a custom border
        let border = CALayer()
        border.frame = CGRectMake(32, self.frame.height - 0.5, UIScreen.mainScreen().bounds.size.width - 64, 0.5)
        border.backgroundColor = UIColor(white: 0.9, alpha: 1).CGColor
        border.zPosition = 10
        self.layer.addSublayer(border)
    }
    
}
