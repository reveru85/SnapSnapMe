//
//  WelcomeViewController.swift
//  Gegder
//
//  Copyright (c) 2015 Genesys. All rights reserved.
//

import UIKit
import CoreLocation

class WelcomeViewController: UIViewController, FBSDKLoginButtonDelegate, UITextFieldDelegate {
    
    @IBOutlet weak var LoadingSpinner: UIActivityIndicatorView!
//    @IBOutlet weak var NotNowButton: UIButton!
//    @IBOutlet weak var ConnectFBButton: UIButton!
    @IBOutlet weak var EventCodeField: UITextField!
    @IBOutlet weak var PinField: UITextField!
    @IBOutlet weak var BottomConstraint: NSLayoutConstraint!
    
    var userID = ""
    var albumID = ""
    var fbId = ""
    var firstName = ""
    var lastName = ""
    var gender = ""
    var email = ""
    var timezone = 0
    let loginView : FBSDKLoginButton = FBSDKLoginButton()
    var firstload = true
    var loginFromWelcomeScreen = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
//        ConnectFBButton.layer.backgroundColor = UIColor.darkGrayColor().colorWithAlphaComponent(0.3).CGColor
        
//        self.view.addSubview(loginView)
        loginView.center = CGPoint(x: self.view.center.x, y: self.view.center.y + 100)
        loginView.readPermissions = ["public_profile", "email", "user_friends"]
        loginView.delegate = self
        loginView.hidden = true
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardNotification:"), name:UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardNotification:"), name:UIKeyboardWillHideNotification, object: nil)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        var login = false
        login = (UIApplication.sharedApplication().delegate as! AppDelegate).isFBLogin!
        if login {
//            NotNowButton.setTitle("Continue", forState: UIControlState.allZeros)
//            ConnectFBButton.setTitle("Logout from Facebook", forState: UIControlState.allZeros)
        } else {
//            NotNowButton.setTitle("Not now", forState: UIControlState.allZeros)
//            ConnectFBButton.setTitle("Connect with Facebook", forState: UIControlState.allZeros)
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        loginFromWelcomeScreen = true
        
        if firstload {
            firstload = false
            
            let deviceID = UIDevice.currentDevice().identifierForVendor.UUIDString
            let deviceHash = deviceID.md5()
            
            var urlString = "http://0720backendapi15.snapsnap.com.sg/index.php/user/load_user/" + deviceHash!
            
            // Get UserID from server based on deviceID's hash
            var url = NSURL(string: urlString)
            var request = NSURLRequest(URL: url!)
            let queue: NSOperationQueue = NSOperationQueue.mainQueue()
            NSURLConnection.sendAsynchronousRequest(request, queue: queue, completionHandler: { (response: NSURLResponse!, data: NSData!, error: NSError!) -> Void in
                
                if error == nil {
                    if (response as! NSHTTPURLResponse).statusCode == 200 {
                        if data != nil {
                            var user = JSON(data: data!)
                            self.userID = user["id"].string!
                            (UIApplication.sharedApplication().delegate as! AppDelegate).userID = self.userID
                            self.userIDLoadComplete()
                        }
                    } else {
                        println(response)
                        // Insert action here for updating UI
                    }
                } else {
                    println(error)
                    // Insert action here for updating UI
                }
            })
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        if (segue.identifier == "GoToHome") {
            (UIApplication.sharedApplication().delegate as! AppDelegate).mainTabViewController = segue.destinationViewController as? UITabBarController
        }
    }
    
    func userIDLoadRetry() {
        let deviceID = UIDevice.currentDevice().identifierForVendor.UUIDString
        let deviceHash = deviceID.md5()
        
        var urlString = "http://0720backendapi15.snapsnap.com.sg/index.php/user/load_user/" + deviceHash!
        
        // Get UserID from server based on deviceID's hash
        var url = NSURL(string: urlString)
        var request = NSURLRequest(URL: url!)
        let queue: NSOperationQueue = NSOperationQueue.mainQueue()
        NSURLConnection.sendAsynchronousRequest(request, queue: queue, completionHandler: { (response: NSURLResponse!, data: NSData!, error: NSError!) -> Void in
            
            if error == nil {
                if (response as! NSHTTPURLResponse).statusCode == 200 {
                    if data != nil {
                        var user = JSON(data: data!)
                        self.userID = user["id"].string!
                        (UIApplication.sharedApplication().delegate as! AppDelegate).userID = self.userID
                        self.userIDLoadComplete()
                    }
                } else {
                    println(response)
                    // Insert action here for updating UI
                }
            } else {
                println(error)
                // Insert action here for updating UI
            }
        })
    }
    
    func userIDLoadComplete() {
        LoadingSpinner.hidden = true
//        ConnectFBButton.hidden = false
//        NotNowButton.hidden = false
        EventCodeField.hidden = false
        PinField.hidden = false
        
        if (FBSDKAccessToken.currentAccessToken() != nil)
        {
            // User is already logged in, do work such as go to next view controller.
            (UIApplication.sharedApplication().delegate as! AppDelegate).isFBLogin = true
            
            // Transition to home view
            //self.performSegueWithIdentifier("GoToHome", sender: self)
        }
    }
    
    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!) {
        
        if ((error) != nil)
        {
            // Process error
        }
        else if result.isCancelled {
            // Handle cancellations
        }
        else {
            // If you ask for multiple permissions at once, you
            // should check if specific permissions missing
            if result.grantedPermissions.contains("public_profile")
            {
                // Do work
                println("returning user data")
                
                returnUserData()
                if loginFromWelcomeScreen {
                    self.performSegueWithIdentifier("GoToHome", sender: self)
                }
            }
        }
    }
    
    @IBAction func FBButtonTouch(sender: UIButton) {
        loginView.sendActionsForControlEvents(UIControlEvents.TouchUpInside)
    }
    
    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {

        (UIApplication.sharedApplication().delegate as! AppDelegate).isFBLogin = false
//        NotNowButton.setTitle("Not now", forState: UIControlState.allZeros)
//        ConnectFBButton.setTitle("Connect with Facebook", forState: UIControlState.allZeros)
        
//        if (UIApplication.sharedApplication().delegate as! AppDelegate).homeView != nil {
//            (UIApplication.sharedApplication().delegate as! AppDelegate).homeView?.dismissViewControllerAnimated(true, completion: nil)
//        }
    }
    
    func returnUserData()
    {
        let graphRequest : FBSDKGraphRequest = FBSDKGraphRequest(graphPath: "/me?fields=id,first_name,last_name,gender,email,timezone", parameters: nil)
        graphRequest.startWithCompletionHandler({ (connection, result, error) -> Void in
            
            if ((error) != nil)
            {
                // Process error
                println("Error: \(error)")
                (UIApplication.sharedApplication().delegate as! AppDelegate).isFBLogin = false
            }
            else
            {
                (UIApplication.sharedApplication().delegate as! AppDelegate).isFBLogin = true
                self.fbId = result.valueForKey("id") as! String
                self.firstName = result.valueForKey("first_name") as! String
                self.lastName = result.valueForKey("last_name") as! String
                self.gender = result.valueForKey("gender") as! String
                self.email = result.valueForKey("email") as! String
                self.timezone = result.valueForKey("timezone") as! Int
                
                self.updateUserData()
            }
        })
    }
    
    func updateUserData() {
        // Update user data
        userID = (UIApplication.sharedApplication().delegate as! AppDelegate).userID!
        var postData0 = "userId=" + userID + "&facebookId=" + self.fbId
        var postData1 = "&firstName=" + self.firstName + "&lastName=" + self.lastName
        var postData2 = "&email=" + self.email + "&gender=" + self.gender
        var postData3 = "&timezone=" + String(self.timezone)
        var postData = postData0 + postData1 + postData2 + postData3
        
        let urlPath: String = "http://0720backendapi15.snapsnap.com.sg/index.php/user/snapsnap_user_update"
        var url = NSURL(string: urlPath)
        var request: NSMutableURLRequest = NSMutableURLRequest(URL: url!)
        let queue: NSOperationQueue = NSOperationQueue.mainQueue()
        
        request.HTTPMethod = "POST"
        request.timeoutInterval = 60
        request.HTTPBody = postData.dataUsingEncoding(NSUTF8StringEncoding)
        request.HTTPShouldHandleCookies=false
        
        NSURLConnection.sendAsynchronousRequest(request, queue: queue, completionHandler: { (response: NSURLResponse!, data: NSData!, error: NSError!) -> Void in
            
            if error == nil {
                if (response as! NSHTTPURLResponse).statusCode == 200 {
                    if data != nil {
                        var str = NSString(data: data, encoding: NSUTF8StringEncoding)
                        
                        if str == "completed" {
                            println("Profile update successfully.")
                        }
                        else if str == "not_updated" {
                            println("Profile update failed.")
                        }
                        else {
                            println(str)
                        }
                    }
                    else {
                        println("data is nil from updateUserData()")
                    }
                } else {
                    println(response)
                    // Insert action here for updating UI
                }
            } else {
                println(error)
                // Insert action here for updating UI
            }
        })
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField == EventCodeField {
            PinField.becomeFirstResponder()
        } else if textField === PinField {
            textField.resignFirstResponder()
            //do submit event and pin event
            SubmitEventPin()
        }
        
        return true
    }
    
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        
        if textField === PinField {
        
            // Create a button bar for the number pad
            let keyboardDoneButtonView = UIToolbar()
            keyboardDoneButtonView.sizeToFit()
            
            let flexSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil)
            let item = UIBarButtonItem(title: "Login", style: UIBarButtonItemStyle.Plain, target: self, action: Selector("endEditingNow"))
            var toolbarButtons = [flexSpace, item]
            
            if EventCodeField.text.isEmpty {
                item.enabled = false
            }
            else {
                item.enabled = true
            }
            
            //Put the buttons into the ToolBar and display the tool bar
            keyboardDoneButtonView.setItems(toolbarButtons, animated: false)
            textField.inputAccessoryView = keyboardDoneButtonView
        }
        
        return true
    }
    
    func endEditingNow(){
        self.textFieldShouldReturn(PinField)
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        //nothing fancy here, just trigger the resign() method to close the keyboard.
        self.resignFirstResponder()
//        self.textFieldShouldReturn(textField)
    }
    
    func keyboardNotification(notification: NSNotification) {
        let isShowing = notification.name == UIKeyboardWillShowNotification
        
        if let userInfo = notification.userInfo {
            let endFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.CGRectValue()
            let endFrameHeight = endFrame?.size.height ?? 0.0
            let duration:NSTimeInterval = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0
            let animationCurveRawNSN = userInfo[UIKeyboardAnimationCurveUserInfoKey] as? NSNumber
            let animationCurveRaw = animationCurveRawNSN?.unsignedLongValue ?? UIViewAnimationOptions.CurveEaseInOut.rawValue
            let animationCurve:UIViewAnimationOptions = UIViewAnimationOptions(rawValue: animationCurveRaw)
            
            if isShowing {
                self.BottomConstraint?.constant = endFrameHeight
            } else {
                self.BottomConstraint?.constant = 0.0
            }
            
            UIView.animateWithDuration(duration,
                delay: NSTimeInterval(0),
                options: animationCurve,
                animations: { self.view.layoutIfNeeded() },
                completion: nil)
        }
    }
    
    func SubmitEventPin() {
        
        var eventStr = EventCodeField.text
        var pinStr = "000000"
        
        if !PinField.text.isEmpty {
            pinStr = PinField.text
        }
        
        //disable fields and show spinner
        EventCodeField.hidden = true
        PinField.hidden = true
        LoadingSpinner.hidden = false
        
        //send eventcode and pin to server
        var urlString = "http://0720backendapi15.snapsnap.com.sg/index.php/album/verify/" + eventStr + "/" + pinStr
        
        // Get UserID from server based on deviceID's hash
        var url = NSURL(string: urlString)
        var request = NSURLRequest(URL: url!)
        let queue: NSOperationQueue = NSOperationQueue.mainQueue()
        NSURLConnection.sendAsynchronousRequest(request, queue: queue, completionHandler: { (response: NSURLResponse!, data: NSData!, error: NSError!) -> Void in

            if error == nil {
                if (response as! NSHTTPURLResponse).statusCode == 200 {
                    if data != nil {
                        
                        //var strData = NSString(data: data, encoding: NSUTF8StringEncoding)
                        //println(strData)
                        
                        let album = JSON(data: data!)
                        
                        if let albumID = album["id"].string {
                            self.albumID = albumID
                            (UIApplication.sharedApplication().delegate as! AppDelegate).albumID = self.albumID
                            
                            //if successful
                            self.EventCodeField.text = ""
                            self.PinField.text = ""
                            self.EventCodeField.hidden = false
                            self.PinField.hidden = false
                            self.LoadingSpinner.hidden = true
                            self.performSegueWithIdentifier("GoToHome", sender:self)
                        } else {
                            //if unsuccessful
                            self.EventCodeField.hidden = false
                            self.PinField.hidden = false
                            self.LoadingSpinner.hidden = true
                            
                            let animationEvent = CABasicAnimation(keyPath: "position")
                            animationEvent.duration = 0.06
                            animationEvent.repeatCount = 3
                            animationEvent.autoreverses = true
                            animationEvent.fromValue = NSValue(CGPoint: CGPointMake(self.EventCodeField.center.x - 7, self.EventCodeField.center.y))
                            animationEvent.toValue = NSValue(CGPoint: CGPointMake(self.EventCodeField.center.x + 7, self.EventCodeField.center.y))
                            
                            let animationPIN = CABasicAnimation(keyPath: "position")
                            animationPIN.duration = 0.06
                            animationPIN.repeatCount = 3
                            animationPIN.autoreverses = true
                            animationPIN.fromValue = NSValue(CGPoint: CGPointMake(self.PinField.center.x + 7, self.PinField.center.y))
                            animationPIN.toValue = NSValue(CGPoint: CGPointMake(self.PinField.center.x - 7, self.PinField.center.y))
                            
                            self.EventCodeField.layer.addAnimation(animationEvent, forKey: "position")
                            self.PinField.layer.addAnimation(animationPIN, forKey: "position")
                        }
                    }
                    else {
                        //if unsuccessful
                        self.EventCodeField.hidden = false
                        self.PinField.hidden = false
                        self.LoadingSpinner.hidden = true
                        
                        let animationEvent = CABasicAnimation(keyPath: "position")
                        animationEvent.duration = 0.06
                        animationEvent.repeatCount = 3
                        animationEvent.autoreverses = true
                        animationEvent.fromValue = NSValue(CGPoint: CGPointMake(self.EventCodeField.center.x - 7, self.EventCodeField.center.y))
                        animationEvent.toValue = NSValue(CGPoint: CGPointMake(self.EventCodeField.center.x + 7, self.EventCodeField.center.y))
                        
                        let animationPIN = CABasicAnimation(keyPath: "position")
                        animationPIN.duration = 0.06
                        animationPIN.repeatCount = 3
                        animationPIN.autoreverses = true
                        animationPIN.fromValue = NSValue(CGPoint: CGPointMake(self.PinField.center.x + 7, self.PinField.center.y))
                        animationPIN.toValue = NSValue(CGPoint: CGPointMake(self.PinField.center.x - 7, self.PinField.center.y))
                        
                        self.EventCodeField.layer.addAnimation(animationEvent, forKey: "position")
                        self.PinField.layer.addAnimation(animationPIN, forKey: "position")
                    }
                } else {
                    println(response)
                    // Insert action here for updating UI
                }
            } else {
                println(error)
                // Insert action here for updating UI
            }
        })
    }
}

