//
//  ViewController.swift
//  GifVault
//
//  Created by Johnny Slagle on 1/22/15.
//  Copyright (c) 2015 Johnny Slagle. All rights reserved.
//

import UIKit
import MessageUI

///TODO: Make a "tags" section where you can browse by reaction, series, etc.

// MARK: Consts
let kCellSpacing: CGFloat = 0.5
let kNumberOfGifColumns: CGFloat = 3.0
let kFavoritesDictionaryKey = "favoritesKey"

class GifViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, MFMessageComposeViewControllerDelegate, JTSImageViewControllerOptionsDelegate, JTSImageViewControllerAnimationDelegate {
    
    // MARK: Variables
    var collectionView : UICollectionView!
    var dataSource : NSArray!
    
    var favorites : [String] {
        get {
            var returnValue: [String]? = NSUserDefaults.standardUserDefaults().objectForKey(kFavoritesDictionaryKey) as? [String]
            
            if (returnValue == nil) {
                returnValue = []
            }
            
            return returnValue!
        }
        set (newValue) {
            if let val = newValue as [String]! {
                NSUserDefaults.standardUserDefaults().setObject(val, forKey: kFavoritesDictionaryKey)
                NSUserDefaults.standardUserDefaults().synchronize()
            }
        }
    }
    
    
    // MARK: View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // UI
        self.view.layer.cornerRadius = 8
        self.view.clipsToBounds = true
        
        // Setup
        self.setupDataSource()
        self.setupCollectionView()
        self.setupBlurView()
    }
    
    
    // MARK: Setup methods
    func setupDataSource() {
        ///TODO: Strip the document path and just do the .gif part.  It would make me not have blank things on reset, I think?
        var fileArray = NSBundle.mainBundle().pathsForResourcesOfType("gif", inDirectory: nil) as [String]
        self.dataSource = fileArray.sorted({ $0.localizedCaseInsensitiveCompare($1) == NSComparisonResult.OrderedAscending})
    }
    
    
    func setupCollectionView() {
        // Size
        let cellWidth = ((self.view.bounds.size.width - (kNumberOfGifColumns * kCellSpacing)) / kNumberOfGifColumns)
        
        // Layout
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.itemSize = CGSize(width: cellWidth, height: cellWidth)
        
        // Collection View
        self.collectionView = UICollectionView(frame: self.view.bounds, collectionViewLayout: flowLayout)
        collectionView.alwaysBounceVertical = true
        collectionView.backgroundColor = UIColor(red: 0.969, green: 0.961, blue: 0.957, alpha: 1.0)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.delaysContentTouches = false
        self.view.addSubview(collectionView)
        
        // Cells
        collectionView.registerClass(GifCell.self, forCellWithReuseIdentifier: GifCell.cellIdentifier())
        collectionView.registerClass(GifHeaderView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: GifHeaderView.reuseIdentifier())
        
        // Gesture
        var tapGesture = UITapGestureRecognizer(target: self, action: "didDoubleTapOnCell:")
        tapGesture.delaysTouchesBegan = false
        tapGesture.numberOfTapsRequired = 2
        self.collectionView.addGestureRecognizer(tapGesture)
    }
    
    
    func setupBlurView() {
        // Status Bar Offset
        self.collectionView.contentInset = UIEdgeInsetsMake(20, 0, 0, 0)
        
        // Status Bar Blur
        let blurView = UIVisualEffectView(effect: UIBlurEffect(style: UIBlurEffectStyle.Light));
        blurView.frame = CGRectMake(0.0, 0.0, self.view.bounds.size.width, 20.0);
        self.view.insertSubview(blurView, aboveSubview: self.collectionView);
    }
    
    
    // MARK: Gesture Recognizer
    func didDoubleTapOnCell(gesture: UITapGestureRecognizer) {
        if (gesture.state == .Ended) {
            if let indexPath = self.collectionView.indexPathForItemAtPoint(gesture.locationInView(self.collectionView)) {
                self.previewImageAtIndexPath(indexPath)
            }
        }
    }
    
    
    // MARK: CollectionView DataSource & Delegate
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 2;
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return (section == 0) ? self.favorites.count : self.dataSource.count
    }
    
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        var cell = collectionView.dequeueReusableCellWithReuseIdentifier(GifCell.cellIdentifier(), forIndexPath: indexPath) as GifCell
        
        cell.gifImageName = (indexPath.section == 0) ? self.favorites[indexPath.row] as String : self.dataSource[indexPath.row] as String
        cell.favorite = (indexPath.section == 0) ? false : contains(self.favorites, cell.gifImageName!)
        
        return cell
    }
    
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        self.textImageAtIndexPath(indexPath)
        collectionView.deselectItemAtIndexPath(indexPath, animated: true)
    }
    
    
    func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        var gifHeader : GifHeaderView? = nil
        
        if kind == UICollectionElementKindSectionHeader {
            gifHeader = collectionView.dequeueReusableSupplementaryViewOfKind(UICollectionElementKindSectionHeader, withReuseIdentifier:GifHeaderView.reuseIdentifier(), forIndexPath:indexPath) as? GifHeaderView
            gifHeader!.headerLabel.text = (indexPath.section == 0) ? "★'s" : ""
        }
        
        return gifHeader!
    }
    
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
        return kCellSpacing
    }
    
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
        return kCellSpacing
    }
    
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSizeZero
        
        //        if (section == 0) {
        //            if (self.favorites.count > 0) {
        //                return CGSize(width: self.view.bounds.size.width, height: 56.0)
        //            }
        //            return CGSizeZero
        //        } else {
        //            return CGSize(width: self.view.bounds.size.width, height: 56.0)
        //        }
    }
    
    
    // MARK: JTSImageViewControllerAnimationDelegate
    func alphaForBackgroundDimmingOverlayInImageViewer(imageViewer: JTSImageViewController!) -> CGFloat {
        return 0.7
    }
    
    
    // MARK: Actions
    func previewImageAtIndexPath(indexPath: NSIndexPath) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), { () -> Void in
            
            var gifCell = self.collectionView.cellForItemAtIndexPath(indexPath) as GifCell
            
            let filePath = ((indexPath.section == 0) ? self.favorites[indexPath.row] : self.dataSource[indexPath.row]) as String
            
            var imageInfo = JTSImageInfo()
            imageInfo.image = JTSAnimatedGIFUtility.animatedImageWithAnimatedGIFData(gifCell.gifImageView.animatedImage.data)
            imageInfo.referenceRect = gifCell.frame
            imageInfo.referenceView = self.collectionView
            imageInfo.referenceContentMode = gifCell.gifImageView.contentMode
            
            
            var imageViewController = JTSImageViewController(imageInfo: imageInfo, mode: .Image, backgroundStyle: .Scaled)
            imageViewController.optionsDelegate = self
            imageViewController.animationDelegate = self
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                imageViewController.showFromViewController(self, transition: ._FromOriginalPosition)
            })
        })
    }
    
    
    func textImageAtIndexPath(indexPath: NSIndexPath) {
        if MFMessageComposeViewController.canSendText() {
            var gifCell : GifCell = collectionView.cellForItemAtIndexPath(indexPath) as GifCell
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), { () -> Void in
                let messageComposeVC = MFMessageComposeViewController()
                messageComposeVC.messageComposeDelegate = self
                messageComposeVC.addAttachmentData(gifCell.gifImageView.animatedImage.data, typeIdentifier: "public.data", filename: "MyGif.gif")
                
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.presentViewController(messageComposeVC, animated: true, completion: nil)
                })
            })
        }
    }
    
    
    func favoriteImageAtIndexPath(indexPath: NSIndexPath) {
        var gifCell = self.collectionView.cellForItemAtIndexPath(indexPath) as GifCell
        
        if let path = gifCell.gifImageName? {
            self.collectionView.performBatchUpdates({ () -> Void in
                
                if (!contains(self.favorites, path)) {
                    self.favorites.append(path)
                } else {
                    if let indexOfObject = find(self.favorites, path) {
                        self.favorites.removeAtIndex(indexOfObject)
                    }
                }
                
                self.collectionView.reloadSections(NSIndexSet(indexesInRange: NSMakeRange(0, 1)))
                
                if (indexPath.section != 0) {
                    ///TODO: This also needs to reload the item of the gif in the "All" section if they removed this from favorites.
                    self.collectionView.reloadItemsAtIndexPaths([indexPath])
                }
                
            }, completion: nil)
        }
        
    }
    
    
    // MARK: MFMessageComposeViewControllerDelegate
    func messageComposeViewController(controller: MFMessageComposeViewController!, didFinishWithResult result: MessageComposeResult) {
        controller.dismissViewControllerAnimated(true, completion: nil)
    }
}


//    • Favs are broken and you can't fav anything now. no touch/gesture lets you'

//    func imageViewerWillAnimatePresentation(imageViewer: JTSImageViewController!, withContainerView containerView: UIView!, duration: CGFloat) {
//        print("imageViewerWillAnimatePresentation")
//
//        let buttonWidth : CGFloat = 75.0
//        let buttonPadding : CGFloat = 10.0
//
//        var whiteView = UIView(frame: CGRect(x: self.view.bounds.size.width - buttonWidth - buttonPadding, y: self.view.bounds.size.height * 2, width: buttonWidth, height: buttonWidth))
//
//        whiteView.alpha = 0.6
//        whiteView.backgroundColor = self.view.backgroundColor
//        whiteView.clipsToBounds = true
//        whiteView.center = CGPoint(x: whiteView.center.x, y: self.view.bounds.size.height - (buttonWidth / 2) - buttonPadding)
//        whiteView.layer.cornerRadius = (buttonWidth / 2)
//
//        containerView.addSubview(whiteView)
//    }