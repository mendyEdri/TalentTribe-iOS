//
//  SignupEmailViewController.swift
//  TalentTribe
//
//  Created by Bogdan Andresyuk on 8/28/15.
//  Copyright (c) 2015 OnOApps. All rights reserved.
//

import Foundation
import UIKit

class LoginSignupViewController: UIViewController, UITextFieldDelegate, UINavigationControllerDelegate {

    @IBOutlet var mainContainer: UIView!
    
    @IBOutlet var signupButton: UIButton!
    @IBOutlet var emailField: TTUnderlinedTextField!
    @IBOutlet var passwordField: TTUnderlinedTextField!
    
    @IBOutlet var forgotButton: UIButton!
    
    @IBOutlet var signupBottomSpace: NSLayoutConstraint!
    
    @IBOutlet var userContainer: UIView!
    @IBOutlet var userImageView: UIImageView!
    @IBOutlet var userLabel: UILabel!
    @IBOutlet var userActivityIndicator: UIActivityIndicatorView!
    
    @IBOutlet var importedLabel: UILabel!
    
    var signup: Bool
    
    //MARK: - Initialization
    
    required init?(coder aDecoder: NSCoder) {
        self.signup = true
        super.init(coder: aDecoder)
    }
    
    //MARK: - Interface actions
    
    @IBAction func signupButtonPressed(_ sender: UIButton)
    {
        if (!DataManager.validateEmail(emailField.text))
        {
            emailField.setHighlightedBottomLineColor()
        }
        else if (!DataManager.validatePassword(passwordField.text))
        {
            passwordField.setHighlightedBottomLineColor()
        }
        else
        {
            self.view.endEditing(true)
            if (self.signup == false)
            {
                self.performLoginRequest()
            }
            else
            {
                self.performSignupRequest()
            }
        }
    }
    
    @IBAction func backButtonPressed(_ sender: UIButton) {
        DataManager.shared().clearCurrentUser()
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func closeButtonPressed(_ sender: UIButton) {
        DataManager.shared().clearCurrentUser()
        DataManager.shared().isAnonymous = true
        self.moveToMainScreen()
    }
    
    @IBAction func forgotButtonPressed(_ sender: UIButton) {
        self.moveToForgotScreen()
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
        self.signupBottomSpace.constant = height + 45.0
    }
    
    //MARK: - UITextField delegate
    
    @IBAction func textFieldInputChanged(_ textField: UITextField) {
        let lineTextField = textField as? TTUnderlinedTextField
        if (lineTextField != nil) {
            lineTextField?.setDefaultBottomLineColor()
        }
        enableButton(self.signupButton, enabled:DataManager.validatePassword(passwordField.text) &&  DataManager.validateEmail(emailField.text))
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        let lineTextField = textField as? TTUnderlinedTextField
        if (lineTextField != nil) {
            lineTextField?.setDefaultBottomLineColor()
        }
        if (textField == passwordField) {
            if (!DataManager.validateEmail(emailField.text) && !emailField.text!.isEmpty) {
                emailField.setHighlightedBottomLineColor()
            } else {
                emailField.setDefaultBottomLineColor()
            }
        } else if (textField == emailField) {
            if (!DataManager.validatePassword(passwordField.text) && !passwordField.text!.isEmpty) {
                passwordField.setHighlightedBottomLineColor()
            }  else {
                passwordField.setDefaultBottomLineColor()
            }
        }
        enableButton(self.signupButton, enabled:DataManager.validatePassword(passwordField.text) &&  DataManager.validateEmail(emailField.text))
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if (textField == passwordField) {
            if (string == " ") {
                return false; 
            }
        }
        return true;
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if (textField == emailField) {
            passwordField.becomeFirstResponder();
        } else if (textField == passwordField) {
            signupButtonPressed(self.signupButton);
        }
        return true;
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
    
    func showError(_ error: NSString) {
        if (error.length > 0)
        {
            let alert = UIAlertView(title: nil, message: error as String, delegate: nil, cancelButtonTitle: "TRY AGAIN")
            alert.show()
        }
    }
    
    func moveToMainScreen() {
        if (self.isModal() == true) {
            //TTActivityIndicator.dismiss()
            StrokeLogoIndicator.dismiss();
            if(self.restorationIdentifier == "shouldContinueCreateStoryProcess") {
                self.dismiss(animated: true, completion: {})
            } else {
                if (!DataManager.shared().currentUser.isProfileMinimumFilled()) {
                    self.moveToUserProfileScreen()
                    return
                }
                self.dismiss(animated: true, completion: {})
            }
        } else {
            self.rootNavigationController!.move(toTabBar: false)
        }
    }
    
    func moveToUserProfileScreen() {
        let controller: UIViewController = UIStoryboard(name: "UserProfile", bundle: nil).instantiateViewController(withIdentifier: "userProfileSummaryViewController") 
        self.navigationController?.setViewControllers([controller], animated: true)
    }
    
    func moveToForgotScreen() {
        let controller: UIViewController = self.storyboard!.instantiateViewController(withIdentifier: "loginResetViewController") 
        self.navigationController?.pushViewController(controller, animated: true)
    }

    func performLoginRequest() {
        synced(self) {
            if (!Loading.active) {
                Loading.active = true
                self.hideAllContainers(true);
                //TTActivityIndicator.showOnMainWindowOnTop()
                StrokeLogoIndicator.showOnMainWindowOnTop()
                DataManager.shared().login(withUsername: self.emailField.text, password: self.passwordField.text){(result, error) -> Void in
                    Loading.active = false
                    if (result != nil && error == nil) {
                        self.moveToMainScreen()
                    }
                    else
                    {
                        //TTActivityIndicator.dismiss()
                        StrokeLogoIndicator.dismiss()
                        if (DataManager.shared().isReachable()) {
                            if (error != nil) {
                                self.showError(error.domain)
                            }
                        }
                        self.showMainContainer(true);
                    }
                    
                }
            }
        }
    }
    
    func performSignupRequest() {
        synced(self) {
            if (!Loading.active) {
                Loading.active = true
                self.hideAllContainers(true);
                StrokeLogoIndicator.showOnMainWindowOnTop()
                //TTActivityIndicator.showOnMainWindowOnTop()
                DataManager.shared().register(withEmail: self.emailField.text, password: self.passwordField.text) { (result, error) -> Void in
                    Loading.active = false
                    if ((result != nil) && (error == nil)) {
                        self.moveToMainScreen()
                    }
                    else
                    {
                        //TTActivityIndicator.dismiss()
                        StrokeLogoIndicator.dismiss()
                        if (DataManager.shared().isReachable())
                        {
                            if (error != nil)
                            {
                                self.showError(error.domain);
                            }
                        }
                        self.showMainContainer(true)
                    }
                }
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
    
    //MARK: Misc
    
    func setupKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(LoginSignupViewController.keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(LoginSignupViewController.keyboardWillHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    func setupPlaceholders() {
        emailField.attributedPlaceholder = NSAttributedString(string: "Email", attributes: [NSFontAttributeName : emailField.font!, NSForegroundColorAttributeName : UIColor.white])
        passwordField.attributedPlaceholder = NSAttributedString(string: "Password", attributes: [NSFontAttributeName : passwordField.font!, NSForegroundColorAttributeName : UIColor.white])
    }
    
    func setupUserInfo() {
        self.forgotButton.isHidden = self.signup
    
        if let user: User = DataManager.shared().currentUser {
            let hideUser: Bool = (self.signup && (user.linkedInToken != nil)) ? false : true
            
            self.userContainer.isHidden = hideUser
            
            if (!hideUser) {
                self.userContainer.isHidden = true
                self.userActivityIndicator.isHidden = false
                self.userActivityIndicator.startAnimating()
                DataManager.shared().linkedInProfile(completion: { (result: AnyObject!, error: NSError!) -> Void in
                    if (result != nil && error == nil) {
                        let user: User = result as! User
                        self.emailField.text = user.userEmail;
                        if (user.userFirstName != nil && user.userLastName != nil) {
                            let firstLastName: NSString = NSString(format: "%@ %@", user.userFirstName, user.userLastName)
                            self.userLabel.text = firstLastName as String!
                        }
                        
                        if (user.userProfileImageURL != nil) {
                            self.userImageView.sd_setImage(with: URL(string: user.userProfileImageURL as String), completed: { (image: UIImage!, error: NSError!, cache: SDImageCacheType, url : URL!) -> Void in
                                if (image != nil) {
                                    user.userProfileImage = image
                                }
                            })
                        }
                        self.userContainer.isHidden = false
                        self.passwordField.becomeFirstResponder()
                    }
                    self.userActivityIndicator.isHidden = true
                })
            } else {
                
            }
            self.userImageView.layer.cornerRadius = self.userImageView.frame.size.width / 2.0
            self.userImageView.layer.masksToBounds = true
            
            self.userImageView.translatesAutoresizingMaskIntoConstraints = true
            self.userLabel.translatesAutoresizingMaskIntoConstraints = true
        }
    }
    
    func setupViews() {
        setupPlaceholders()
        setupUserInfo()
        if (self.signup) {
            self.signupButton.setTitle("SIGN UP", for: UIControlState())
        } else {
            self.signupButton.setTitle("LOG IN", for: UIControlState())
        }
    }
    
    func enableButton(_ button: UIButton!, enabled: Bool) {
        if (enabled) {
            button.setTitleColor(UIColor.white, for: UIControlState())
        } else {
            button.setTitleColor(UIColor(red: 220.0 / 255.0, green: 220.0 / 255.0, blue: 220.0 / 255.0, alpha: 1.0), for: UIControlState())
        }
    }
    
    func alignImageViewWithLabel(_ imageView: UIImageView!, label: UILabel) {
        label.sizeToFit()
        let imageOriginX: CGFloat = (self.userContainer.frame.size.width - imageView.frame.size.width - label.frame.size.width) / 2
        imageView.frame = CGRect(x: imageOriginX >= 0 ? imageOriginX : 0, y: imageView.frame.origin.y, width: imageView.frame.size.width, height: imageView.frame.size.height)
        let imageMaxX: CGFloat = imageView.frame.origin.x + imageView.frame.size.width + 5
        let labelMaxX: CGFloat = imageMaxX + label.frame.size.width
        label.frame = CGRect(x: imageMaxX, y: 0, width: labelMaxX <= self.userContainer.frame.size.width ? label.frame.size.width : label.frame.size.width - (labelMaxX - self.userContainer.frame.size.width), height: self.userContainer.frame.size.height)
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
        alignImageViewWithLabel(self.userImageView, label: self.userLabel)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if ((KeyboardStateListener.sharedListener() as AnyObject).keyboardShown == true) {
            self.updateBottomSpace(((KeyboardStateListener.sharedListener() as AnyObject).keyboardFrame).height)
        }
        self.emailField.becomeFirstResponder()
        self.navigationController?.delegate = self
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        SocialManager.shared().cancelAllRequests()
        //self.navigationController?.delegate = nil
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupViews()
        self.setupKeyboardNotifications()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        self.userImageView.sd_cancelCurrentImageLoad()
    }
    
}
