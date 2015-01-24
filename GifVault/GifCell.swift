//
//  GifCell.swift
//  GifVault
//
//  Created by Johnny Slagle on 1/22/15.
//  Copyright (c) 2015 Johnny Slagle. All rights reserved.
//

import UIKit

class GifCell: UICollectionViewCell {
    
    // MARK: Variables
    var favoriteLabel : UILabel!
    var favorite : Bool! {
        didSet {
            self.updateText()
        }
    }
    
    var gifImageView : FLAnimatedImageView!
    var gifImageName : String? {
        didSet {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), { () -> Void in
                if let imageName = self.gifImageName {
                    if let gifData = NSData(contentsOfFile: imageName)? {
                        let gifImage = FLAnimatedImage(animatedGIFData: gifData)
                        gifImage.frameCacheSizeMax = 1
                        
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            self.gifImageView.animatedImage = gifImage
                        })
                    }
                }
            })
        }
    }
    
    // MARK: Overriding
    override var highlighted: Bool {
        willSet(newHighlighted) {
            if (newHighlighted) {
                self.insertSubview(self.highlightView, aboveSubview: gifImageView)
            } else {
                self.highlightView.removeFromSuperview()
            }
        }
    }
    
    
    // MARK: Lazy Init.
    lazy var highlightView : UIView = self.generateHighlightView()
    
    
    // MARK: Init
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        // UI
        self.backgroundColor = UIColor(red: 0.298, green: 0.851, blue: 0.392, alpha: 1);
        self.clipsToBounds = true
        
        // GifImageView
        self.gifImageView = FLAnimatedImageView(frame: self.bounds)
        gifImageView.contentMode = .ScaleAspectFill
        gifImageView.autoresizingMask = .FlexibleWidth | .FlexibleHeight
        self.contentView.addSubview(gifImageView)
        
        // Favorite Stuff
        let heartWidth = self.bounds.size.width / 4
        
        self.favoriteLabel = UILabel(frame: CGRect(x: 0, y: 0, width: heartWidth, height: heartWidth))
        favoriteLabel.autoresizingMask = .FlexibleLeftMargin | .FlexibleTopMargin
        favoriteLabel.center = CGPoint(x: self.bounds.width - self.favoriteLabel.bounds.size.width / 2, y: self.bounds.height - self.favoriteLabel.bounds.size.height / 2)
        favoriteLabel.font =  UIFont(name: "HelveticaNeue-Light", size: 26.0)
        favoriteLabel.text = "☆"
        favoriteLabel.textAlignment = .Center
        favoriteLabel.textColor = .whiteColor()
        self.contentView.addSubview(self.favoriteLabel)
        
        self.favorite = false
    }
    
    
    // MARK: Prepare for Resuse
    override func prepareForReuse() {
        super.prepareForReuse()
        self.gifImageView.animatedImage = nil
    }
    
    
    // MARK: Update & Highlight Methods
    func updateText() {
        self.favoriteLabel.text = (favorite!) ? "★" : ""
    }
    
    
    func generateHighlightView() -> UIView {
        var aView = UIView(frame: self.bounds)
        aView.backgroundColor = UIColor(red: 0.69, green: 0.0863, blue: 0.216, alpha: 1).colorWithAlphaComponent(0.6)
        return aView
    }

    
    // MARK: Class Methods
    class func cellIdentifier() -> String {
        return "GifCellIdentifier"
    }
}