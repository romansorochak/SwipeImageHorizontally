//
//  ViewController.swift
//  SwipePhotoHorizontally
//
//  Created by super_user on 6/7/15.
//  Copyright (c) 2015 DevCom. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var previousImageView: UIImageView!
    @IBOutlet weak var currentImageView: UIImageView!
    @IBOutlet weak var nextImageView: UIImageView!
    
    @IBOutlet weak var draggableConstraint: NSLayoutConstraint!
    
    
    private var images: [String] = ["1", "2", "3", "4", "5"]
    private var currentImage: Int = 0
    
    private let SWIPE_ANIMATION_DURATION = 0.3
    private let DRAG_PERCENT_NEEDS_TO_SWIPE: CGFloat = 0.6
    private let DRAG_MIN_PERCENT_NEEDS_TO_SWIPE: CGFloat = 0.1
    private let TIMESTAMP_NEEDS_TO_SWIPE: NSTimeInterval = 0.2
    
    private var viewWidthHalf: CGFloat!
    private var viewWidth: CGFloat!
    private var xTouchBeganFromCenter: CGFloat = 0
    private var timestampTouchBegan: NSTimeInterval!
    private var timestampTouch: NSTimeInterval!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.viewWidth = self.view.frame.width
        self.viewWidthHalf = self.viewWidth / 2
        
        self.currentImageView.image = UIImage(named: "1")
        self.currentImage = 0
        self.nextImageView.image = self.getNextImage()
        self.previousImageView.image = self.getPreviousImage()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK - touch handlers
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        super.touchesBegan(touches, withEvent: event)
        
        if let touch = touches.first as? UITouch {
            if touch.view == self.currentImageView {
                
                self.xTouchBeganFromCenter = self.viewWidthHalf - touch.locationInView(self.view).x
                self.timestampTouchBegan = touch.timestamp
            }
        }
    }
    
    override func touchesMoved(touches: Set<NSObject>, withEvent event: UIEvent) {
        super.touchesMoved(touches, withEvent: event)
        
        if let touch = touches.first as? UITouch {
            if touch.view == self.currentImageView {
                
                let xTouchFromCenter = touch.locationInView(self.view).x
                let drag = self.viewWidthHalf - xTouchFromCenter - self.xTouchBeganFromCenter
                
                self.draggableConstraint.constant = drag
            }
        }
    }
    
    override func touchesEnded(touches: Set<NSObject>, withEvent event: UIEvent) {
        super.touchesEnded(touches, withEvent: event)
        
        if let touch = touches.first as? UITouch {
            if touch.view == self.currentImageView {
                
                self.timestampTouch = touch.timestamp - self.timestampTouchBegan
                
                self.handleSwipeToLeftOrRightOrCenter()
            }
        }
    }
    
    
    // MARK - swipe animation & help methods
    
    private func dragRight() -> Bool {
        return self.draggableConstraint.constant < 0
    }
    
    private func dragPercentFromCenter() -> CGFloat {
        return abs(self.draggableConstraint.constant / self.viewWidthHalf)
    }
    
    private func canSwipeWithAnimationRight() -> Bool {
        return self.isPreviousImage()
            &&
            (self.dragPercentFromCenter() >= DRAG_PERCENT_NEEDS_TO_SWIPE
                ||
                (self.timestampTouch <= TIMESTAMP_NEEDS_TO_SWIPE
                    &&
                    self.dragPercentFromCenter() >= DRAG_MIN_PERCENT_NEEDS_TO_SWIPE))
    }
    
    private func canSwipeWithAnimationLeft() -> Bool {
        return self.isNextImage()
            &&
            (self.dragPercentFromCenter() >= DRAG_PERCENT_NEEDS_TO_SWIPE
                ||
                (self.timestampTouch <= TIMESTAMP_NEEDS_TO_SWIPE
                    &&
                    self.dragPercentFromCenter() >= DRAG_MIN_PERCENT_NEEDS_TO_SWIPE))
    }
    
    private func handleSwipeToLeftOrRightOrCenter() {
        
        if self.dragRight() { // swipe right to previous image
            
            self.canSwipeWithAnimationRight() ? self.swipeCurrentImageViewToRight() : self.swipeCurrentImageViewToCenter()
            
        } else { // swipe left to next image
            
            self.canSwipeWithAnimationLeft() ? self.swipeCurrentImageViewToLeft() : self.swipeCurrentImageViewToCenter()
        }
    }
    
    // swipe to previous image
    private func swipeCurrentImageViewToRight() {
        
        UIView.animateWithDuration(0.3, animations: { () -> Void in
            
            self.draggableConstraint.constant = -self.viewWidth
            self.currentImageView.layoutIfNeeded()
            self.previousImageView.layoutIfNeeded()
            
            }) { _ in
                
                self.draggableConstraint.constant = 0
                
                self.currentImageView.image = self.goToPreviousImage()
                self.nextImageView.image = self.getNextImage()
                self.previousImageView.image = self.getPreviousImage()
        }
    }
    
    // swipe to next image
    private func swipeCurrentImageViewToLeft() {
        
        UIView.animateWithDuration(0.3, animations: { () -> Void in
            
            self.draggableConstraint.constant = self.viewWidth
            self.currentImageView.layoutIfNeeded()
            self.nextImageView.layoutIfNeeded()
            
            }) { _ in
                
                self.draggableConstraint.constant = 0
                
                self.currentImageView.image = self.goToNextImage()
                self.nextImageView.image = self.getNextImage()
                self.previousImageView.image = self.getPreviousImage()
        }
    }
    
    private func swipeCurrentImageViewToCenter() {
        
        UIView.animateWithDuration(0.3, animations: { () -> Void in
            
            self.draggableConstraint.constant = 0
            self.currentImageView.layoutIfNeeded()
            self.nextImageView.layoutIfNeeded()
            self.previousImageView.layoutIfNeeded()
        })
    }
    
    
    // MARK - images
    
    private func isNextImage() -> Bool {
        return self.currentImage < self.images.count - 1
    }
    
    private func isPreviousImage() -> Bool {
        return self.currentImage > 0
    }
    
    private func getNextImage() -> UIImage? {
        
        if isNextImage() == false {
            return nil
        }
        
        let nextImageName = self.images[self.currentImage+1]
        
        return UIImage(named: nextImageName)
    }
    
    private func goToNextImage() -> UIImage? {
        
        let image = getNextImage()
        
        if image != nil {
            self.currentImage++
        }
        
        return image
    }
    
    private func getPreviousImage() -> UIImage? {
        
        if isPreviousImage() == false {
            return nil
        }
        
        let previousImageName = self.images[self.currentImage-1]
        
        return UIImage(named: previousImageName)
    }
    
    private func goToPreviousImage() -> UIImage? {
        
        let image = getPreviousImage()
        
        if image != nil {
            self.currentImage--
        }
        
        return image
    }
}

