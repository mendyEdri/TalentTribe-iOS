//
//  LoginSelectionViewController.swift
//  TalentTribe
//
//  Created by Bogdan Andresyuk on 8/28/15.
//  Copyright (c) 2015 OnOApps. All rights reserved.
//

import Foundation

class LoginSelectionViewController: UIViewController, UINavigationControllerDelegate, UIAlertViewDelegate {
    
    @objc enum ViewState: Int {
        case regular = 0
        case action = 1
    }
    
    @objc var viewState: ViewState
    
    //@IBOutlet var logoIcon: UIImageView!
    
    @IBOutlet var memberButton: UIButton!
    @IBOutlet var cancelButton: UIButton!
    
    @IBOutlet var skipButton: UIButton!
    @IBOutlet var signinButton: UIButton!
    
    @IBOutlet var registerLabel: UILabel!
    
    @IBOutlet var termsButton: UIButton!
    @IBOutlet var privacyButton: UIButton!
    
    @IBOutlet var termsPrivacyLabel: UILabel!
    
    @IBOutlet var mainContainer: UIView!
    @IBOutlet var alertContainer: UIView!
    
    var fromLinkedIn: Bool!
    
    //MARK: - Initialization
    
    required init(coder aDecoder: NSCoder) {
        self.viewState = ViewState.regular
        self.fromLinkedIn = false
        super.init(coder: aDecoder)!
    }
    
    //MARK: - Interface actions
    
    @IBAction func loginButtonPressed(_ sender: UIButton) {
        self.openLoginScreen()
    }
    
    @IBAction func linkedInButtonPressed(_ sender: UIButton) {
        //self.showLinkedInAlert(true)
        self.openLinkedInLogin()
    }
    
    @IBAction func emailButtonPressed(_ sender: UIButton) {
        self.openEmailSignup()
    }
    
    @IBAction func skipButtonPressed(_ sender: UIButton) {
        DataManager.shared().clearCurrentUser()
        DataManager.shared().isAnonymous = true
        self.moveToMainScreen()
    }
    
    @IBAction func signinButtonPressed(_ sender: UIButton) {
        self.openLoginScreen()
    }
    
    @IBAction func cancelButtonPressed(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil);
    }
    
    @IBAction func termsAndConditionsButtonPressed(_ sender: UIButton) {
        self.showWebLinkWithTitle("TERMS & CONDITIONS", urlToOpen: URL(string: String(format: "%@/terms", DataManager.shared().serverURL()))!)
    }
    
    @IBAction func privacyButtonPressed(_ sender: UIButton) {
        self.showWebLinkWithTitle("PRIVACY POLICY", urlToOpen: URL(string: String(format: "%@/privacy", DataManager.shared().serverURL()))!)
    }
    
    @IBAction func closeLinkedInAlertPressed(_ sender: UIButton) {
        self.showMainContainer(true)
    }
    
    @IBAction func connectLinkedInPressed(_ sender: UIButton) {
        self.openLinkedInLogin()
    }
    
    //MARK: - Selection handling
    
    func showError(_ error: NSString) {
        if (error.length > 0)
        {
            let alert = UIAlertView(title: nil, message: error as String, delegate: nil, cancelButtonTitle: "OK")
            alert.show()
        }
    }
    
    func moveToMainScreen() {
        self.hideAllContainers(true, completion: { (Void) -> Void in
            if (self.isModal() == true) {
                self.dismiss(animated: true, completion: nil);
            } else {
                self.rootNavigationController!.move(toTabBar: false)
            }
        })
    }
    
    func moveToCreateUserScreen() {
        let controller: LoginSignupViewController = self.storyboard!.instantiateViewController(withIdentifier: "loginSignupViewController") as! LoginSignupViewController;
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    func moveToUserProfileLinkedIn() {
        let controller: UIViewController = UIStoryboard(name: "UserProfile", bundle: nil).instantiateViewController(withIdentifier: "userProfileLinkedInViewController")
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    func openLinkedInLogin() {
        synced(self) {
            if (!Loading.active) {
                Loading.active = true
                self.fromLinkedIn = true
                DataManager.shared().requestLinkedInToken(authorizationHandler: { (result: AnyObject!, error: NSError!) -> Void in
                    self.hideAllContainers(true, completion:{ _ in })
                    StrokeLogoIndicator.showOnMainWindowOnTop()
                }, completionHandler: { (result: AnyObject!, error: NSError!) -> Void in
                    StrokeLogoIndicator.dismiss()
                    if (result != nil && error == nil) {
                        self.moveToCreateUserScreen()
                        Loading.active = false
                    } else {
                        if (error != nil) {
                            self.showError("Unable to signup with LinkedIn")
                        }
                        self.showMainContainer(true)
                        Loading.active = false
                    }
                    self.fromLinkedIn = false
                })
            }
        }
    }
    
    func openEmailSignup() {
        self.openLoginOrSignupScreen(true)
    }
    
    func openLoginScreen() {
        self.openLoginOrSignupScreen(false)
    }
    
    func openLoginOrSignupScreen(_ signup: Bool) {
        let controller: LoginSignupViewController = self.storyboard!.instantiateViewController(withIdentifier: "loginSignupViewController") as! LoginSignupViewController
        controller.signup = signup
        if(self.restorationIdentifier != nil && self.restorationIdentifier! == "shouldContinueCreateStoryProcess")
        {
            controller.restorationIdentifier = "shouldContinueCreateStoryProcess"
        }
        
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    //MARK: - LinkedIn alert handling
    
    func showLinkedInAlert(_ animated: Bool) {
        self.alertContainer.alpha = 0.0
        self.alertContainer.isHidden = false
        UIView.animate(withDuration: animated ? 0.5 : 0.0, animations: { () -> Void in
            self.mainContainer.alpha = 0.0
            self.alertContainer.alpha = 1.0
        }, completion: { (finished: Bool) -> Void in
            self.mainContainer.isHidden = true
        })  
    }
    
    func showMainContainer(_ animated: Bool) {
        //self.logoIcon.hidden = false
        self.mainContainer.alpha = 0.0
        self.mainContainer.isHidden = false
        UIView.animate(withDuration: animated ? 0.5 : 0.0, animations: { () -> Void in
            self.mainContainer.alpha = 1.0
            self.alertContainer.alpha = 0.0
        }, completion: { (finished: Bool) -> Void in
                self.alertContainer.isHidden = true
        })   
    }
    
    func hideAllContainers(_ animated: Bool, completion: @escaping (Void) -> Void) {
        UIView.animate(withDuration: animated ? 0.5 : 0.0, animations: { () -> Void in
            self.mainContainer.alpha = 0.0
            self.alertContainer.alpha = 0.0
        }, completion: { (finished: Bool) -> Void in
            //self.logoIcon.hidden = true
            completion()
        })   
    }
    
    func hideMainContainer() {
        self.mainContainer.isHidden = true
        self.alertContainer.isHidden = true
    }
    
    //MARK: - Misc
    
    func showWebLinkWithTitle(_ title: String, urlToOpen: URL) {
        let controller: WebLinkViewController = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "webLinkViewController") as! WebLinkViewController
        controller.urlToOpen = urlToOpen
        controller.titleString = title
        let navController: UINavigationController = UINavigationController(rootViewController: controller);
        self.present(navController, animated: true, completion: nil)
    }
    
    func setupTermsAndConditionsButton() {
        let mainStr: NSString = "By signing up, I agree to TalentTribe's\nTerms & Conditions and Privacy Policy"
        let termsRange: NSRange =  mainStr.range(of: "Terms & Conditions")
        let privacyRange: NSRange =  mainStr.range(of: "Privacy Policy")
        let str = NSMutableAttributedString(string: mainStr as String)
        str.addAttribute(NSForegroundColorAttributeName, value: UIColor.white, range: NSMakeRange(0, str.length))
        str.addAttribute(NSUnderlineStyleAttributeName, value: NSUnderlineStyle.styleSingle.rawValue, range: termsRange)
        str.addAttribute(NSUnderlineStyleAttributeName, value: NSUnderlineStyle.styleSingle.rawValue, range: privacyRange)
        termsPrivacyLabel.attributedText = str
    }
    
    func setupViews() {
        self.setupTermsAndConditionsButton()
        if (self.viewState == ViewState.regular) {
            self.memberButton.isHidden = false
            self.cancelButton.isHidden = true
            self.registerLabel.isHidden = true
            self.skipButton.isHidden = false
            self.signinButton.isHidden = true
        } else {
            self.memberButton.isHidden = true
            self.cancelButton.isHidden = false
            self.registerLabel.isHidden = false
            self.skipButton.isHidden = true
            self.signinButton.isHidden = false
        }
    }
    
    //MARK: Gesture detection
    
    override var canBecomeFirstResponder : Bool {
        return true
    }
    
    override func motionEnded(_ motion: UIEventSubtype, with event: UIEvent?) {
        NSLog("SHAKE");
        struct Holder {
            static var shakesCounter = 0
        }
        if (motion == UIEventSubtype.motionShake) {
            Holder.shakesCounter += 1
            if (Holder.shakesCounter >= 2) {
                self.showBaseInputAlert()
                Holder.shakesCounter = 0
            }
        }
    }
    
    func showBaseInputAlert() {
        let alert: UIAlertView = UIAlertView(title: "Please insert Base URL", message: "", delegate: self, cancelButtonTitle: "CANCEL", otherButtonTitles: "SAVE")
        alert.alertViewStyle = UIAlertViewStyle.plainTextInput
        if DataManager.shared().serverURL() != nil {
            alert.textField(at: 0)!.text = DataManager.shared().serverURL()
        }
        alert.show()
    }
    
    //MARK: UIAlertView delegate
    
    func alertView(_ alertView: UIAlertView, willDismissWithButtonIndex buttonIndex: Int) {
        if (alertView.cancelButtonIndex != buttonIndex) {
            let baseURL: String = alertView.textField(at: 0)!.text!
            if (baseURL.hasPrefix("http://") || baseURL.hasPrefix("https://")) {
                 DataManager.shared().setServerURL(baseURL)
            }
        }
    }
    
    //MARK: - Sync
    
    struct Loading {
        static var active = false
    }
    
    func synced(_ lock: AnyObject, closure: () -> ()) {
        objc_sync_enter(lock)
        closure()
        objc_sync_exit(lock)
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
        StrokeLogoIndicator.dismiss()
        if (!self.fromLinkedIn) {
            self.showMainContainer(animated)
        } else {
            self.hideMainContainer()
        }
        self.navigationController?.delegate = self
        self.becomeFirstResponder()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        //self.navigationController?.delegate = nil
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupViews()
    }
    
    deinit {
    }
    
}
