//
//  LocationSearchBar.swift
//  LiveBus
//
//  Created by Arthur GUIBERT on 31/01/2015.
//  Copyright (c) 2015 Arthur GUIBERT. All rights reserved.
//

import UIKit

class LocationSearchBar: UISearchBar {
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = 2
        layer.shadowRadius = 5
        layer.shadowOpacity = 0.25
        layer.shadowColor = UIColor.blackColor().CGColor
        layer.shadowOffset = CGSize(width: 0,height: 0)
    }
}