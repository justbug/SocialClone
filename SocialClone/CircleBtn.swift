//
//  CircleBtn.swift
//  SocialClone
//
//  Created by Mark Chen on 2016/12/5.
//  Copyright © 2016年 Mark Chen. All rights reserved.
//

import UIKit

class CircleBtn: UIButton {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        layer.shadowColor = UIColor(red: SHADOW_GRAY, green: SHADOW_GRAY, blue: SHADOW_GRAY, alpha: 0.6).cgColor
        layer.shadowOpacity = 0.8
        layer.shadowRadius = 5.0
        layer.shadowOffset = CGSize(width: 1.0, height: 1.0)
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = bounds.size.width / 2 
    }

}
