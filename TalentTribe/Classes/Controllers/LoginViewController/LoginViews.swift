//
//  LoginViews.swift
//  TalentTribe
//
//  Created by Bogdan Andresyuk on 8/12/15.
//  Copyright (c) 2015 OnOApps. All rights reserved.
//

import Foundation
import UIKit

class TTOnePixelView: UIView {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        var onePixel:CGFloat = 1.0 / UIScreen.main.scale
        if (UIScreen.main.responds(to: #selector(getter: UIScreen.nativeScale))) {
            onePixel = 1.0 / UIScreen.main.nativeScale
        }
        let foundConstraint: NSLayoutConstraint? = self.findConstraint(.height)
        if (foundConstraint != nil) {
            foundConstraint?.constant = onePixel
        }
    }
    
    fileprivate func findConstraint(_ attribute: NSLayoutAttribute) -> NSLayoutConstraint? {
        var foundConstraint: NSLayoutConstraint?
        
        if attribute == .width || attribute == .height {
            for (_, constraint): (Int, NSLayoutConstraint) in (self.constraints ).enumerated() {
                if constraint.isMember(of: NSLayoutConstraint) && constraint.firstAttribute == attribute {
                    foundConstraint = constraint
                }
            }
        }
        
        return foundConstraint
    }
}

class TTUnderlinedTextField: UITextField {
    
    var bottomLine: UIView!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    func commonInit() {
        bottomLine = UIView(frame: CGRect.zero)
        bottomLine.isUserInteractionEnabled = false
        setDefaultBottomLineColor()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.addSubview(bottomLine)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let height: CGFloat = 1.0 / UIScreen.main.scale
        bottomLine.frame = CGRect(x: 0, y: self.frame.height - height, width: self.frame.width, height: height)
    }
    
    func setBottomLineColor(_ color: UIColor) {
        bottomLine.backgroundColor = color
    }
    
    func setDefaultBottomLineColor() {
        setBottomLineColor(UIColor.white)
    }
    
    func setHighlightedBottomLineColor() {
        setBottomLineColor(UIColor(red: 202.0 / 255.0, green: 48.0 / 255.0, blue: 48.0 / 255.0, alpha: 1.0))
    }
    
}

class TTBorderButton:UIButton {
    override func awakeFromNib() {
        super.awakeFromNib()
        self.layer.cornerRadius = 3.5
        self.layer.borderColor = UIColor.white.cgColor
        self.layer.borderWidth = 1.0 / UIScreen.main.scale
    }
}

class FadeAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval{
        return 0.3
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let from = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from)!
        let to = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to)!
        
        to.view.frame = transitionContext.finalFrame(for: to);
        to.view.layoutIfNeeded()
        
        to.view.alpha = 0.0
        transitionContext.containerView.addSubview(to.view)
        
        UIView.animate(withDuration: 0.6, animations:{
            to.view.layoutIfNeeded()
            
            to.view.alpha = 1.0
            from.view.alpha = 0.0
        }, completion: {
                _ in
                transitionContext.completeTransition(true)
        })
    }
}

