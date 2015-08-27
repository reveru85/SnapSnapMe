//
//  NewPostViewController.swift
//  Gegder
//
//  Copyright (c) 2015 Genesys. All rights reserved.
//

import UIKit
//import CoreLocation

class NewPostViewController: UIViewController, UITextFieldDelegate {
    
//    @IBOutlet weak var locationLabel: UILabel!
//    @IBOutlet var previewHeightConstraint: NSLayoutConstraint!
//    @IBOutlet weak var titleField: UITextField!
    @IBOutlet weak var postingBlurView: UIVisualEffectView!
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    @IBOutlet weak var postButton: UIBarButtonItem!
    @IBOutlet weak var hashtagField: UITextField!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var cameraPreview: UIImageView!
    var newImage: UIImage?
    let userID = (UIApplication.sharedApplication().delegate as! AppDelegate).userID
    let albumID = (UIApplication.sharedApplication().delegate as! AppDelegate).albumID
    let homeView = (UIApplication.sharedApplication().delegate as! AppDelegate).homeView
    
    // Location functionality
//    var manager: OneShotLocationManager?
//    var address = ""            // subThroughfare + throughfare + country + postal code
//    var latitude = ""           //              > latitude
//    var longitude = ""          //              > longitude
//    var subThoroughfare = ""    // 211C         > location*
//    var thoroughfare = ""       // Punggol Walk > location*
//    var postalCode = ""         // 823211       > location*
//    var country = ""            // Singapore    > locationCategory1 (Country)
//    var administrativeArea = "" // Singapore    > locationCategory2 (State)
//    var locality = ""           // Punggol      > locationCategory3 (City)
//    var subAdministrativeArea = "" // nil       > locationCategory4 (County)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        cameraPreview.image = newImage
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardNotification:"), name:UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardNotification:"), name:UIKeyboardWillHideNotification, object: nil)
        
        // Get current location immediately after image is taken
//        manager = OneShotLocationManager()
//        manager!.fetchWithCompletion { location, error in
//            
//            // fetch location or an error
//            if let loc = location {
////                println(location)
//                // Convert location to geocode
//                self.getLocationAddress(location! as CLLocation)
//            } else if let err = error {
////                println(err.localizedDescription)
//                self.locationLabel.text = "Unknown (Disabled in Settings)"
//            }
//           
//            self.manager = nil
//            
//        }
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func CancelButton(sender: AnyObject) {
        // Hide keyboard
        view.endEditing(true)
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func PostButton(sender: AnyObject) {
        
        // Hide keyboard
        view.endEditing(true)
        
        // Disable buttons and show spinner
        postButton.enabled = false
        cancelButton.enabled = false
        postingBlurView.hidden = false
//        titleField.enabled = false
        hashtagField.enabled = false
        
        // Fix image orientation and crop to square
        var editedImage = newImage?.fixOrientation()
//        editedImage = editedImage?.cropToSquare()
        
        // Resize image to 720x720
//        let size = CGSizeMake(720, 720)
//        UIGraphicsBeginImageContextWithOptions(size, true, 1.0)
//        editedImage!.drawInRect(CGRect(origin: CGPointZero, size: size))
//        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
//        UIGraphicsEndImageContext()
        
        // Create base64 from image
        var imageData = UIImageJPEGRepresentation(editedImage, 0.2)
        let base64String = imageData.base64EncodedStringWithOptions(.allZeros)
        
        // Replace + with %2B to get around HTTP post restriction
        let newBase64String = base64String.stringByReplacingOccurrencesOfString("+", withString: "%2B")
        
        // Prepare data for posting
        var firstPostId = ""
        if (UIApplication.sharedApplication().delegate as! AppDelegate).firstPostID != nil {
            firstPostId = (UIApplication.sharedApplication().delegate as! AppDelegate).firstPostID!
        }
        
        var isLogin = ""
        
        if (UIApplication.sharedApplication().delegate as! AppDelegate).isFBLogin == true {
            isLogin = "1"
        }
        else {
            isLogin = "0"
        }
        
        /*
        jpegImageEncoded [compulsory]
        albumId[compulsory]
        latestPostId [compulsory] => Post ID / Empty String if there is no latest post
        userId [compulsory] => User ID
        longitude [optional] => Longitude value
        latitude [optional] => Latitude value
        timezone [can be empty at this moment]
        title [optional] => Title of post
        description [can be empty at this moment]
        hashtag [optional] => Hash tag / comment
        location [optional] => Address
        locationCategory1 [optional] => Country Code
        locationCategory2 [optional] => State
        locationCategory3 [optional] => City
        locationCategory4 [optional] => can be empty at this moment
        isLogin [compulsory] => 0 or 1
        */
        
        var postData1 = "jpegImageEncoded=" + newBase64String + "&albumId=" + albumID! + "&latestPostId=" + firstPostId
//        var postData2 = "&userId=" + userID! + "&isLogin=" + isLogin + "&title=" + titleField.text + "&hashtag=" + hashtagField.text
        var postData2 = "&userId=" + userID! + "&isLogin=" + isLogin + "&hashtag=" + hashtagField.text

//        var postData3 = "&latitude=" + self.latitude + "&longitude=" + self.longitude + "&location=" + self.address
//        var postData4 = "&locationCategory1=" + self.country + "&locationCategory2=" + self.administrativeArea
//        var postData5 = "&locationCategory3=" + self.locality + "&locationCategory4=" + self.subAdministrativeArea
        
        var postData = postData1 + postData2// + postData3 + postData4 + postData5
        
        let urlPath: String = "http://0720backendapi15.snapsnap.com.sg/index.php/dphodto/dphodto_image_post"
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
                        var strData = NSString(data: data, encoding: NSUTF8StringEncoding)
                        
                        println(strData)
                        
                        var posts = JSON(data: data!)
                        
                        // Only add if JSON from server contains more posts
                        if posts.count != 0 {
                            
                            if (UIApplication.sharedApplication().delegate as! AppDelegate).isInitialEntryCleared == false {
                                self.homeView!.data.clearEntries()
                                (UIApplication.sharedApplication().delegate as! AppDelegate).isInitialEntryCleared = true
                            }
                            
                            self.homeView!.data.addEntriesToFrontFromJSON(posts)
                            (UIApplication.sharedApplication().delegate as! AppDelegate).firstPostID = self.homeView!.data.entries.first!.post_id!
                            self.homeView!.HomeTableView.reloadData()
                        }
                        
                        self.dismissViewControllerAnimated(true, completion: nil)
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
                self.bottomConstraint?.constant = endFrameHeight + 10
//                self.previewHeightConstraint?.active = false
            } else {
//                self.previewHeightConstraint?.active = true
                self.bottomConstraint?.constant = 10.0
            }
            
            UIView.animateWithDuration(duration,
                delay: NSTimeInterval(0),
                options: animationCurve,
                animations: { self.view.layoutIfNeeded() },
                completion: nil)
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
//        if (textField === titleField) {
//            hashtagField.becomeFirstResponder()
//        } else if (textField === hashtagField) {
        if (textField === hashtagField) {
            textField.resignFirstResponder()
        }
        
        return true
    }
    
//    func getLocationAddress(location:CLLocation) {
//        var geocoder = CLGeocoder()
//        
//        geocoder.reverseGeocodeLocation(location, completionHandler: {(placemarks, error)->Void in
//            var placemark:CLPlacemark!
//            
//            if error == nil && placemarks.count > 0 {
//                placemark = placemarks[0] as! CLPlacemark
//                
//                self.address = ""
//                self.subThoroughfare = ""
//                self.thoroughfare = ""
//                self.country = ""
//                self.postalCode = ""
//                self.locality = ""
//                self.administrativeArea = ""
//                self.subAdministrativeArea = ""
//                
//                if placemark.subThoroughfare != nil {
//                    self.subThoroughfare = placemark.subThoroughfare
//                    self.address = placemark.subThoroughfare + " "
//                }
//                
//                if placemark.thoroughfare != nil {
//                    self.thoroughfare = placemark.thoroughfare
//                    self.address = self.address + placemark.thoroughfare + ", "
//                }
//                
//                if placemark.country != nil {
//                    self.country = placemark.country
//                    self.address = self.address + placemark.country + " "
//                }
//                
//                if placemark.postalCode != nil {
//                    self.postalCode = placemark.postalCode
//                    self.address = self.address + placemark.postalCode + " "
//                }
//                
//                if placemark.locality != nil {
//                    self.locality = placemark.locality
//                }
//                
//                if placemark.administrativeArea != nil {
//                    self.administrativeArea = placemark.administrativeArea
//                }
//                
//                if placemark.subAdministrativeArea != nil {
//                    self.subAdministrativeArea = placemark.subAdministrativeArea
//                }
//                
//                self.locationLabel.text = self.address
//                
//            }
//        })
//    }
}

extension UIImage {
    
    func cropToSquare() -> UIImage {
        // Create a copy of the image without the imageOrientation property so it is in its native orientation (landscape)
        let contextImage: UIImage = UIImage(CGImage: self.CGImage)!
        
        // Get the size of the contextImage
        let contextSize: CGSize = contextImage.size
        
        let posX: CGFloat
        let posY: CGFloat
        let width: CGFloat
        let height: CGFloat
        
        // Check to see which length is the longest and create the offset based on that length, then set the width and height of our rect
        if contextSize.width > contextSize.height {
            posX = ((contextSize.width - contextSize.height) / 2)
            posY = 0
            width = contextSize.height
            height = contextSize.height
        } else {
            posX = 0
            posY = ((contextSize.height - contextSize.width) / 2)
            width = contextSize.width
            height = contextSize.width
        }
        
        let rect: CGRect = CGRectMake(posX, posY, width, height)
        
        // Create bitmap image from context using the rect
        let imageRef: CGImageRef = CGImageCreateWithImageInRect(contextImage.CGImage, rect)
        
        // Create a new image based on the imageRef and rotate back to the original orientation
        let image: UIImage = UIImage(CGImage: imageRef, scale: self.scale, orientation: self.imageOrientation)!
        
        return image
    }
    
    func fixOrientation() -> UIImage {
        
        // No-op if the orientation is already correct
        if ( self.imageOrientation == UIImageOrientation.Up ) {
            return self;
        }
        
        // We need to calculate the proper transformation to make the image upright.
        // We do it in 2 steps: Rotate if Left/Right/Down, and then flip if Mirrored.
        var transform: CGAffineTransform = CGAffineTransformIdentity
        
        if ( self.imageOrientation == UIImageOrientation.Down || self.imageOrientation == UIImageOrientation.DownMirrored ) {
            transform = CGAffineTransformTranslate(transform, self.size.width, self.size.height)
            transform = CGAffineTransformRotate(transform, CGFloat(M_PI))
        }
        
        if ( self.imageOrientation == UIImageOrientation.Left || self.imageOrientation == UIImageOrientation.LeftMirrored ) {
            transform = CGAffineTransformTranslate(transform, self.size.width, 0)
            transform = CGAffineTransformRotate(transform, CGFloat(M_PI_2))
        }
        
        if ( self.imageOrientation == UIImageOrientation.Right || self.imageOrientation == UIImageOrientation.RightMirrored ) {
            transform = CGAffineTransformTranslate(transform, 0, self.size.height);
            transform = CGAffineTransformRotate(transform,  CGFloat(-M_PI_2));
        }
        
        if ( self.imageOrientation == UIImageOrientation.UpMirrored || self.imageOrientation == UIImageOrientation.DownMirrored ) {
            transform = CGAffineTransformTranslate(transform, self.size.width, 0)
            transform = CGAffineTransformScale(transform, -1, 1)
        }
        
        if ( self.imageOrientation == UIImageOrientation.LeftMirrored || self.imageOrientation == UIImageOrientation.RightMirrored ) {
            transform = CGAffineTransformTranslate(transform, self.size.height, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
        }
        
        // Now we draw the underlying CGImage into a new context, applying the transform
        // calculated above.
        var ctx: CGContextRef = CGBitmapContextCreate(nil, Int(self.size.width), Int(self.size.height),
            CGImageGetBitsPerComponent(self.CGImage), 0,
            CGImageGetColorSpace(self.CGImage),
            CGImageGetBitmapInfo(self.CGImage));
        
        CGContextConcatCTM(ctx, transform)
        
        if ( self.imageOrientation == UIImageOrientation.Left ||
            self.imageOrientation == UIImageOrientation.LeftMirrored ||
            self.imageOrientation == UIImageOrientation.Right ||
            self.imageOrientation == UIImageOrientation.RightMirrored ) {
                CGContextDrawImage(ctx, CGRectMake(0,0,self.size.height,self.size.width), self.CGImage)
        } else {
            CGContextDrawImage(ctx, CGRectMake(0,0,self.size.width,self.size.height), self.CGImage)
        }
        
        // And now we just create a new UIImage from the drawing context and return it
        return UIImage(CGImage: CGBitmapContextCreateImage(ctx))!
    }
}
