//
//  CommentsViewController.swift
//  Gegder
//
//  Copyright (c) 2015 Genesys. All rights reserved.
//

import UIKit

class CommentsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate {
    
    @IBOutlet weak var postButton: UIButton!
    @IBOutlet weak var postingBlurView: UIVisualEffectView!
    @IBOutlet weak var CommentsTextField: UITextField!
    @IBOutlet weak var NoCommentsView: UIView!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var CommentsTableView: UITableView!
    var postId = ""
    let commentCellId = "CommentCell"
    let data = CommentData()
    let userID = (UIApplication.sharedApplication().delegate as! AppDelegate).userID
    var refreshControl: UIRefreshControl!
    var parentView: UIViewController!
    var currentCellView: PostTableViewCell!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        var login : Bool
        login = (UIApplication.sharedApplication().delegate as! AppDelegate).isFBLogin!
        
//        if !login {
//            postButton.hidden = true
//            CommentsTextField.hidden = true
//        }
        
        CommentsTableView.delegate = self
        CommentsTableView.dataSource = self
        CommentsTableView.estimatedRowHeight = 44
        CommentsTableView.rowHeight = UITableViewAutomaticDimension
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardNotification:"), name:UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardNotification:"), name:UIKeyboardWillHideNotification, object: nil)
        
        // Get comments
        var urlString = "http://0720backendapi15.snapsnap.com.sg/index.php/dphodto_comment/dphodto_comment_list/" + postId
        let url = NSURL(string: urlString)
        var request = NSURLRequest(URL: url!)
        let queue: NSOperationQueue = NSOperationQueue.mainQueue()
        NSURLConnection.sendAsynchronousRequest(request, queue: queue, completionHandler: { (response: NSURLResponse!, data: NSData!, error: NSError!) -> Void in
            
            if error == nil {
                if (response as! NSHTTPURLResponse).statusCode == 200 {
                    if data != nil {
                        var posts = JSON(data: data!)
                        self.data.clearEntries()
                        self.data.addEntriesFromJSON(posts)
                        self.CommentsTableView.reloadData()
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
        
        // Pull to refresh code
        self.refreshControl = UIRefreshControl()
        //self.refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        self.refreshControl.addTarget(self, action: "getNewComments", forControlEvents: UIControlEvents.ValueChanged)
        self.CommentsTableView.addSubview(refreshControl)
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let ret = data.entries.count
        
        if ret == 0 {
            NoCommentsView.hidden = false
        } else {
            NoCommentsView.hidden = true
        }
        
        return ret
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(commentCellId, forIndexPath: indexPath) as! CommentsTableViewCell
        
        // Initialise an instance of PostData class using the current row
        let post = data.entries[indexPath.row]
        
        // Update the UI with the current post
        cell.UserLabel.text = post.name
        cell.CommentDatetime.text = post.datetime
        cell.Comment.text = post.comment
        cell.entry = post
        cell.parentView = self
        
        return cell
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
            self.bottomConstraint?.constant = isShowing ? endFrameHeight : 0.0
            //self.bottomConstraint2?.constant = isShowing ? endFrameHeight + 7 - 49 : 7.0
            UIView.animateWithDuration(duration,
                delay: NSTimeInterval(0),
                options: animationCurve,
                animations: { self.view.layoutIfNeeded() },
                completion: nil)
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func getNewComments() {
        
        // Get comments
        var urlString = "http://0720backendapi15.snapsnap.com.sg/index.php/dphodto_comment/dphodto_comment_list/" + postId
        let url = NSURL(string: urlString)
        var request = NSURLRequest(URL: url!)
        let queue: NSOperationQueue = NSOperationQueue.mainQueue()
        NSURLConnection.sendAsynchronousRequest(request, queue: queue, completionHandler: { (response: NSURLResponse!, data: NSData!, error: NSError!) -> Void in
            
            if error == nil {
                if (response as! NSHTTPURLResponse).statusCode == 200 {
                    if data != nil {
                        var posts = JSON(data: data!)
                        self.data.clearEntries()
                        self.data.addEntriesFromJSON(posts)
                        self.CommentsTableView.reloadData()
                    }
                } else {
                    println(response)
                    // Insert action here for updating UI
                }
            } else {
                println(error)
                // Insert action here for updating UI
            }
            
            self.refreshControl.endRefreshing()
        })
    }
    
    @IBAction func SendComment(sender: UIButton) {
        let comment = CommentsTextField.text
        
        if comment.isEmpty {
            println("no comment entered")
            return
        }
        
        // On send comment button clicked
        sender.enabled = false
        CommentsTextField.enabled = false
        postingBlurView.hidden = false
        
        // Send comment to server
        var postData = "dphodtoId=" + postId + "&userId=" + userID! + "&comment=" + comment
        
        println(userID!)
        
        let urlPath: String = "http://0720backendapi15.snapsnap.com.sg/index.php/dphodto_comment/dphodto_comment_create"
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
                            
                            // Reload comments from server on send complete (in async)
                            self.getNewComments()
                            
                            // Hide sending view and re-enable comments posting (in async)
                            sender.enabled = true
                            self.CommentsTextField.enabled = true
                            self.postingBlurView.hidden = true
                            
                            // Clear CommentsTextField if posting succeeded (in async)
                            self.CommentsTextField.text = ""
                            
                            if self.parentView is HomeViewController {
                                
                                // Update post entry variable in HomeViewController (backend data)
                                (self.parentView as! HomeViewController).data.incrementComment(self.postId)
                                
                                // Update post cell display in HomeViewController (frontend display)
                                var commentsInt = self.currentCellView.PostCommentCount.text?.toInt()
                                commentsInt!++
                                self.currentCellView.PostCommentCount.text = String(commentsInt!)
                            }
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

