//
//  PostTableViewCell.swift
//  Gegder
//
//  Copyright (c) 2015 Genesys. All rights reserved.
//

import UIKit

class PostTableViewCell: UITableViewCell {
    
    @IBOutlet weak var PostTitle: UILabel!
    @IBOutlet weak var UserImage: UIImageView!
    @IBOutlet weak var UserLabel: UILabel!
    @IBOutlet weak var UserLocation: UILabel!
    @IBOutlet weak var PostImage: UIImageView!
    @IBOutlet weak var PostDateTime: UILabel!
    @IBOutlet weak var PostHashtags: UILabel!
    @IBOutlet weak var PostCommentButton: UIButton!
    @IBOutlet weak var PostCommentCount: UILabel!
    @IBOutlet weak var PostLikeButton: UIButton!
    @IBOutlet weak var PostLikeCount: UILabel!
    var PostId: String!
    var UserId: String!
    var IsLike: Bool!
    var parentView: UIViewController!
    
    override func awakeFromNib() {
        super.awakeFromNib()        
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    @IBAction func PostLikeButtonTouch(sender: UIButton) {
        
        if PostId != nil {
            if parentView is HomeViewController {
                
                // Like post API
                var urlString = "http://0720backendapi15.snapsnap.com.sg/index.php/dphodto/action_like/" + PostId! + "/" + UserId!
                let url = NSURL(string: urlString)
                var request = NSURLRequest(URL: url!)
                let queue: NSOperationQueue = NSOperationQueue.mainQueue()
                NSURLConnection.sendAsynchronousRequest(request, queue: queue, completionHandler: { (response: NSURLResponse!, data: NSData!, error: NSError!) -> Void in
                    
                    if error == nil {
                        if (response as! NSHTTPURLResponse).statusCode == 200 {
                            if data != nil {
                                var str = NSString(data: data, encoding: NSUTF8StringEncoding)
                                
                                if str == "completed" {
                                    // Update immediate UI
                                    self.PostLikeButton.imageView?.image = UIImage(named:"ic_like_on")
                                    self.IsLike = true;
                                    
                                    // Update post entry variable in HomeViewController (backend data)
                                    (self.parentView as! HomeViewController).data.likePost(self.PostId!)
                                    
                                    // Update post cell display in HomeViewController (frontend display)
                                    var likesInt = self.PostLikeCount.text?.toInt()
                                    likesInt!++
                                    self.PostLikeCount.text = String(likesInt!)
                                }
                                else if str == "liked" {
                                    self.PostLikeButton.imageView?.image = UIImage(named:"ic_like_on")
                                    
                                    var likeAlert = UIAlertController(title: "", message: "You have liked the post.", preferredStyle: UIAlertControllerStyle.Alert)
                                    likeAlert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Cancel, handler: nil))
                                    (self.parentView as! HomeViewController).presentViewController(likeAlert, animated: true, completion: nil)
                                }
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
    }
    
    @IBAction func PostCommentButtonTouch(sender: UIButton) {
        
        if PostId != nil {
            if parentView is HomeViewController {
                (parentView as! HomeViewController).selectedPostCellId = PostId
                (parentView as! HomeViewController).selectedPostCell = self
            }
            
            parentView.performSegueWithIdentifier("ShowComments", sender:self)
        }
    }
    
    @IBAction func MoreButtonTouch(sender: UIButton) {
        
        if PostId != nil {
            
            let optionMenu = UIAlertController(title: "More options", message: nil, preferredStyle: .Alert)
            
            let shareAction = UIAlertAction(title: "Share on Facebook", style: .Default, handler: {
                (alert: UIAlertAction!) -> Void in
                
                if self.parentView is HomeViewController {
                    
                    let content : FBSDKShareLinkContent = FBSDKShareLinkContent()
                    content.contentURL = NSURL(string: "http://www.snapsnap.com.sg/webdev/album")// + self.PostId)
                    content.contentTitle = self.PostTitle.text
                    content.contentDescription = self.PostHashtags.text
                    content.imageURL = NSURL(string: (self.parentView as! HomeViewController).data.findEntry(self.PostId).media_url!)
                    
                    let button : FBSDKShareButton = FBSDKShareButton()
                    button.shareContent = content
                    button.frame = CGRectMake((UIScreen.mainScreen().bounds.width - 100) * 0.5, 50, 100, 25)
                    button.hidden = true
                    button.sendActionsForControlEvents(UIControlEvents.TouchUpInside)
                    
                }
            })
            
            let flagAction = UIAlertAction(title: "Flag as inappropriate", style: .Destructive, handler: {
                (alert: UIAlertAction!) -> Void in
                
                if self.parentView is HomeViewController {
                    
                    var urlString = "http://0720backendapi15.snapsnap.com.sg/index.php/dphodto/action_flag_as_inappropriate/" + self.PostId
                    let url = NSURL(string: urlString)
                    var request = NSURLRequest(URL: url!)
                    let queue: NSOperationQueue = NSOperationQueue.mainQueue()
                    NSURLConnection.sendAsynchronousRequest(request, queue: queue, completionHandler: { (response: NSURLResponse!, data: NSData!, error: NSError!) -> Void in
                        
                        if error == nil {
                            if (response as! NSHTTPURLResponse).statusCode == 200 {
                                if data != nil {
                                    var str = NSString(data: data, encoding: NSUTF8StringEncoding)
                                    
                                    if str == "completed" {
                                        // Remove post from post data in code behind and refresh view
                                        (self.parentView as! HomeViewController).data.removeEntry(self.PostId)
                                        (self.parentView as! HomeViewController).HomeTableView.reloadData()
                                        
                                        var flagAlert = UIAlertController(title: "", message: "You have flagged the post as inappropriate.", preferredStyle: UIAlertControllerStyle.Alert)
                                        flagAlert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Cancel, handler: nil))
                                        (self.parentView as! HomeViewController).presentViewController(flagAlert, animated: true, completion: nil)
                                    }
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
            })
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: {
                (alert: UIAlertAction!) -> Void in
            })
            
            optionMenu.addAction(shareAction)
            optionMenu.addAction(flagAction)
            optionMenu.addAction(cancelAction)
            
            parentView.presentViewController(optionMenu, animated: true, completion: nil)
        }
    }
    
    @IBAction func ImageTouch(sender: AnyObject) {
        
        if PostId != nil {
            if parentView is HomeViewController {
                (parentView as! HomeViewController).selectedPostCellId = PostId
                (parentView as! HomeViewController).selectedPostCell = self
            }
            
            parentView.performSegueWithIdentifier("ShowImageViewer", sender:self)
        }
    }
}
