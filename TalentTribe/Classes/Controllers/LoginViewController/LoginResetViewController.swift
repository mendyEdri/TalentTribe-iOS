//
//  LoginResetViewController.swift
//  TalentTribe
//
//  Created by Bogdan Andresyuk on 8/31/15.
//  Copyright (c) 2015 OnOApps. All rights reserved.
//

import Foundation
import UIKit

class LoginResetViewController: UIViewController, UITextFieldDelegate, UINavigationControllerDelegate {
    
    @IBOutlet var mainContainer: UIView!
    
    @IBOutlet var resetButton: UIButton!
    @IBOutlet var resetField: TTUnderlinedTextField!
    
    @IBOutlet var doneLabel: UILabel!
    @IBOutlet var doneButton: UIButton!
    
    @IBOutlet var resetBottomSpace: NSLayoutConstraint!

    //MARK: - Initialization
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    //MARK: - Interface actions
    
    @IBAction func resetButtonPressed(_ sender: UIButton) {
        if (!DataManager.validateEmail(resetField.text)) {
            resetField.setHighlightedBottomLineColor()
        } else {
            self.performResetRequest()
        }
    }
    
    @IBAction func doneButtonPressed(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func backButtonPressed(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func closeButtonPressed(_ sender: UIButton) {
        DataManager.shared().clearCurrentUser()
        DataManager.shared().isAnonymous = true
        self.moveToMainScreen()
    }
    
    //MARK: - Keyboard handling
    
    func keyboardWillShow(_ notif: Notification) {
        self.handleKeyboardNotification(notif, show: true)
    }
    
    func keyboardWillHide(_ notif: Notification) {
        self.handleKeyboardNotification(notif, show: false)
    }
    
    func handleKeyboardNotification(_ notif: Notification, show: Bool) {
        
        let dict:NSDictionary = notif.userInfo! as NSDictionary
        let keyboardFrame:CGRect = (dict.value(forKey: UIKeyboardFrameEndUserInfoKey)! as AnyObject).cgRectValue as CGRect
        let duration: TimeInterval = (dict[UIKeyboardAnimationDurationUserInfoKey]! as AnyObject).doubleValue!
        
        self.view.layoutIfNeeded()
        
        if (show) {
            self.updateBottomSpace(keyboardFrame.height)
            UIView.animate(withDuration: duration, animations: { () -> Void in
                self.view.layoutIfNeeded()
            })
        }
    }
    
    func updateBottomSpace(_ height: CGFloat) {
        self.resetBottomSpace.constant = height + 30.0
    }
    
    //MARK: - UITextField delegate
    
    @IBAction func textFieldInputChanged(_ textField: UITextField) {
        let lineTextField = textField as? TTUnderlinedTextField
        if (lineTextField != nil) {
            lineTextField?.setDefaultBottomLineColor()
        }
        enableButton(self.resetButton, enabled:DataManager.validateEmail(resetField.text))
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        let lineTextField = textField as? TTUnderlinedTextField
        if (lineTextField != nil) {
            lineTextField?.setDefaultBottomLineColor()
        }
        enableButton(self.resetButton, enabled:DataManager.validateEmail(resetField.text))
    }
    
    //MARK: - Signup handling
    
    struct Loading {
        static var active = false
    }
    
    func synced(_ lock: AnyObject, closure: () -> ()) {
        objc_sync_enter(lock)
        closure()
        objc_sync_exit(lock)
    }
    
    func showError(_ error: String) {
        let alert = UIAlertView(title: error, message: nil, delegate: nil, cancelButtonTitle: "OK")
        alert.show()
    }
    
    func moveToMainScreen() {
        if (self.isModal() == true) {
            self.dismiss(animated: true, completion: nil);
        } else {
            self.rootNavigationController!.move(toTabBar: false)
        }
    }
    
    func showDoneView(_ animated: Bool) {
        self.view.isUserInteractionEnabled = false
        self.view.endEditing(true)
        self.doneLabel.text = NSString(format:"A password reset link was sent to:\n%@", self.resetField.text!) as String

        UIView.animate(withDuration: (animated ? 0.4 : 0.0), animations: { () -> Void in
            self.resetField.alpha = 0.0
            self.resetButton.alpha = 0.0
        }, completion: { (finished: Bool) -> Void in
            
            self.doneLabel.isHidden = false
            self.doneButton.isHidden = false
            
            UIView.animate(withDuration: 0.3, animations: { () -> Void in
                self.mainContainer.alpha = 1
                self.doneLabel.alpha = 1.0
                self.doneButton.alpha = 1.0
                }, completion: { (finished:Bool) -> Void in
                    self.view.isUserInteractionEnabled = true
            }) 
        }) 
    }
    
    func performResetRequest()
    {
        synced(self)
            {
            if (!Loading.active)
            {
                Loading.active = true
                self.view.endEditing(true)
                self.hideAllContainers(true);
                //TTActivityIndicator.showOnMainWindowOnTop()
                StrokeLogoIndicator.showOnMainWindowOnTop()
                DataManager.shared().recoverPassword(withEmail: self.resetField.text, completionHandler: { (success, error) -> Void in
                    //TTActivityIndicator.dismiss()
                    StrokeLogoIndicator.dismiss()
                    Loading.active = false
                    if(success && error == nil)
                    {
                        self.showDoneView(true)
                    }
                    else
                    {
                        self.showMainContainer(true)
                    }
                })
            }
        }
    }
    
    //MARK Containers appearance
    
    func showMainContainer(_ animated: Bool) {
        self.mainContainer.alpha = 0.0
        self.mainContainer.isHidden = false
        UIView.animate(withDuration: animated ? 0.5 : 0.0, animations: { () -> Void in
            self.mainContainer.alpha = 1.0
            }, completion: { (finished: Bool) -> Void in
        })   
    }
    
    func hideAllContainers(_ animated: Bool) {
        UIView.animate(withDuration: animated ? 0.5 : 0.0, animations: { () -> Void in
            self.mainContainer.alpha = 0.0
            }, completion: { (finished: Bool) -> Void in
        })   
    }
    
    func setupKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(LoginResetViewController.keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(LoginResetViewController.keyboardWillHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    
    func setupPlaceholders() {
        resetField.attributedPlaceholder = NSAttributedString(string: "Email", attributes: [NSFontAttributeName : resetField.font!, NSForegroundColorAttributeName : UIColor.white])
    }
    
    func setupViews() {
        setupPlaceholders()
    }
    
    func enableButton(_ button: UIButton!, enabled: Bool) {
        if (enabled) {
            button.setTitleColor(UIColor.white, for: UIControlState())
        } else {
            button.setTitleColor(UIColor(red: 220.0 / 255.0, green: 220.0 / 255.0, blue: 220.0 / 255.0, alpha: 1.0), for: UIControlState())
        }
    }
    
    //MARK: UINavigationController delegate
    
    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationControllerOperation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        if (operation == .push || operation == .pop) {
            return FadeAnimator()
        }
        return nil
    }
    
    //MARK: - View lifeCycle
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if ((KeyboardStateListener.sharedListener() as AnyObject).keyboardShown == true) {
            self.updateBottomSpace(((KeyboardStateListener.sharedListener() as AnyObject).keyboardFrame).height)
        }
        self.resetField.becomeFirstResponder()
        self.navigationController?.delegate = self
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        //self.navigationController?.delegate = nil
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupViews()
        self.setupKeyboardNotifications()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
