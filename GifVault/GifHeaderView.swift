//
//  ReusableHeaderView.swift
//  GifVault
//
//  Created by Johnny Slagle on 1/22/15.
//  Copyright (c) 2015 Johnny Slagle. All rights reserved.
//

import UIKit

class GifHeaderView: UICollectionReusableView {
    var headerLabel : UILabel!
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.headerLabel = UILabel(frame: CGRectOffset(self.bounds, 12, 0))
        headerLabel.autoresizingMask = .FlexibleWidth | .FlexibleRightMargin
        headerLabel.text = ""
        headerLabel.font = UIFont(name: "HelveticaNeue-Light", size: 28.0)
        self.addSubview(self.headerLabel)
    }

    class func reuseIdentifier() -> String {
        return "GifHeaderReuseIdentifier";
    }
}
