//
//  HomeTableViewController.swift
//  Gegder
//
//  Copyright (c) 2015 Genesys. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIPopoverPresentationControllerDelegate {
    
    @IBOutlet weak var menuButton: UIBarButtonItem!
    @IBOutlet weak var HomeTableView: UITableView!
    let postCellId = "PostCell"
    let data = PostData()
    let userID = (UIApplication.sharedApplication().delegate as! AppDelegate).userID
    let albumID = (UIApplication.sharedApplication().delegate as! AppDelegate).albumID
    var lastPostID = ""
    var refreshControl: UIRefreshControl!
    var imageCache = [String:UIImage]()
    var selectedPostCellId = ""
    var selectedPostCell : PostTableViewCell!
    
    // Camera view
    let picker = UIImagePickerController()
    var newImage: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        (UIApplication.sharedApplication().delegate as! AppDelegate).homeView = self
        
        
        let modelName = UIDevice.currentDevice().modelName
        
        if modelName == "iPhone 4" || modelName == "iPhone 4S" {
            HomeTableView.estimatedRowHeight = 450
        }
        else if modelName == "iPhone 5" || modelName == "iPhone 5C" || modelName == "iPhone 5S" {
            HomeTableView.estimatedRowHeight = 500
        }
        else if modelName == "iPhone 6" {
            HomeTableView.estimatedRowHeight = 550
        }
        else if modelName == "iPhone 6 Plus" {
            HomeTableView.estimatedRowHeight = 600
        }
        else {
            HomeTableView.estimatedRowHeight = 500
        }
        
        HomeTableView.delegate = self
        HomeTableView.dataSource = self
        //HomeTableView.estimatedRowHeight = 550 //value affects scrolling behavior after new posts loads need more experimentation
        HomeTableView.rowHeight = UITableViewAutomaticDimension
        
        // Get first load posts
        var urlString = "http://0720backendapi15.snapsnap.com.sg/index.php/dphodto/dphodto_list/" + albumID! + "/" + userID!
        let url = NSURL(string: urlString)
        var request = NSURLRequest(URL: url!)
        let queue: NSOperationQueue = NSOperationQueue.mainQueue()
        NSURLConnection.sendAsynchronousRequest(request, queue: queue, completionHandler: { (response: NSURLResponse!, data: NSData!, error: NSError!) -> Void in
            
            if error == nil {
                if (response as! NSHTTPURLResponse).statusCode == 200 {
                    if data != nil {
                        var posts = JSON(data: data!)
                        
                        if posts.count > 0 {
                            self.data.clearEntries()
                            (UIApplication.sharedApplication().delegate as! AppDelegate).isInitialEntryCleared = true
                            self.data.addEntriesFromJSON(posts)
                            (UIApplication.sharedApplication().delegate as! AppDelegate).firstPostID = self.data.entries.first!.post_id!
                            self.HomeTableView.reloadData()
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
        
        // Camera view
        picker.delegate = self
        picker.navigationBar.translucent = false
        picker.navigationBar.barTintColor = UIColor(red: CGFloat(251.0/255.0), green: CGFloat(44.0/255.0), blue: CGFloat(125.0/255.0), alpha: CGFloat(1.0))
//        picker.navigationBar.barTintColor = UIColor.magentaColor() // Background color
        picker.navigationBar.tintColor = .whiteColor() // Cancel button ~ any UITabBarButton items
//        picker.navigationBar.titleTextAttributes = [
//            NSForegroundColorAttributeName : UIColor.whiteColor()
//        ]
        
        // Pull to refresh code
        self.refreshControl = UIRefreshControl()
        //self.refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        self.refreshControl.addTarget(self, action: "getNewPosts", forControlEvents: UIControlEvents.ValueChanged)
        self.HomeTableView.addSubview(refreshControl)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        flushCache()
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.entries.count
    }
    
    func tableView(tableView: UITableView, didEndDisplayingCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        //disable any operations still waiting for download, to fix wrong image loads from previously reused cells
        //https://stavash.wordpress.com/2012/12/14/advanced-issues-asynchronous-uitableviewcell-content-loading-done-right/
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(postCellId, forIndexPath: indexPath) as! PostTableViewCell
        
        //prevent layout constraints error
        cell.contentView.bounds = CGRectMake(0, 0, 99999, 99999);
        
        // Initialise an instance of PostData class using the current row
        let post = data.entries[indexPath.row]
        cell.PostImage.image = UIImage(named:"post_default")
        
        // Assign image URL string as key to image cache
        let urlString = post.media_url
        
        // If this image is already cached, don't re-download
        if (urlString != nil) {
            if let img = imageCache[urlString!] {
                
                cell.PostImage.image = img
            }
            else {
                // The image isn't cached, download the img data
                // We should perform this in a background thread
                if urlString != nil {
                    if let imageUrl = NSURL(string: urlString!) {
                        let imageRequest: NSURLRequest = NSURLRequest(URL: imageUrl)
                        let queue: NSOperationQueue = NSOperationQueue.mainQueue()
                        NSURLConnection.sendAsynchronousRequest(imageRequest, queue: queue, completionHandler: { (response: NSURLResponse!, data: NSData!, error: NSError!) -> Void in
                            
                            if error == nil {
                                if (response as! NSHTTPURLResponse).statusCode == 200 {
                                    if data != nil {
                                        // Convert the downloaded data in to a UIImage object and cache
                                        let image = UIImage(data: data)
                                        self.imageCache[urlString!] = image
                                        self.trimCache()
                                        
                                        // Update the cell
                                        dispatch_async(dispatch_get_main_queue(), {
                                            if let cellToUpdate = tableView.cellForRowAtIndexPath(indexPath) {
                                                (cellToUpdate as! PostTableViewCell).PostImage.image = image
                                                //might cause an error if image is loaded *after* cell has been reused
                                                //https://stavash.wordpress.com/2012/12/14/advanced-issues-asynchronous-uitableviewcell-content-loading-done-right/
                                            }
                                        })
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
        }
        
        // Update the UI with the current post
//        cell.PostTitle.text = post.title
//        cell.UserLabel.text = post.username
//        cell.UserLocation.text = post.location
        cell.PostDateTime.text = post.created_datetime
        cell.PostHashtags.text = post.hash_tag
        cell.PostCommentCount.text = post.total_comments
        cell.PostLikeCount.text = post.total_likes
        cell.PostId = post.post_id
        cell.UserId = self.userID
        cell.IsLike = post.is_like
        cell.parentView = self
        
        if post.is_like {
            cell.PostLikeButton.imageView?.image = UIImage(named:"ic_like_on")
        } else {
            cell.PostLikeButton.imageView?.image = UIImage(named:"ic_like")
        }
        
        //        println(post.display_order)
        //        println(post.post_id)
        
        return cell
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        if data.entries.last?.post_id != nil {
            var height = scrollView.frame.size.height
            var contentYoffset = scrollView.contentOffset.y
            var distanceFromBottom = scrollView.contentSize.height - contentYoffset
            
            if distanceFromBottom < height {
                
                // Reached end of table
                let currentLastPostID = data.entries.last?.post_id!
                
                // Track the last post ID globally so as to not make repeated "Get Previous Posts" on the same last post
                if lastPostID != currentLastPostID {
                    
                    lastPostID = currentLastPostID!
                    getPreviousPosts(currentLastPostID)
                }
            }
        }
    }
    
    func trimCache() {
        if imageCache.count > 10 {
            for index in 0...4 {
                imageCache.removeAtIndex(imageCache.startIndex)
            }
        }
    }
    
    func flushCache() {
        imageCache.removeAll(keepCapacity: false)
    }
    
    func getPreviousPosts(postID : String?) {
        
        // Get previous posts based on oldest post
        var urlString = "http://0720backendapi15.snapsnap.com.sg/index.php/dphodto/dphodto_previous_post/" + albumID! + "/" + postID! + "/" + userID!
        
        let url = NSURL(string: urlString)
        var request = NSURLRequest(URL: url!)
        let queue: NSOperationQueue = NSOperationQueue.mainQueue()
        NSURLConnection.sendAsynchronousRequest(request, queue: queue, completionHandler: { (response: NSURLResponse!, data: NSData!, error: NSError!) -> Void in
            
            if error == nil {
                if (response as! NSHTTPURLResponse).statusCode == 200 {
                    if data != nil {
                        var posts = JSON(data: data!)
                        
                        // Only add if JSON from server contains more posts
                        if posts.count != 0 {
                            
                            self.data.addEntriesFromJSON(posts)
                            self.HomeTableView.reloadData()
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
    
    func getNewPosts() {
        
        var urlString = ""
        
        if (UIApplication.sharedApplication().delegate as! AppDelegate).firstPostID == nil {
            println("Getting first load posts")
            // Get first load posts
            urlString = "http://0720backendapi15.snapsnap.com.sg/index.php/dphodto/dphodto_list/" + albumID! + "/" + userID!
        } else {
            println("Getting newer posts based on most recent post")
            // Get new posts based on newest post
            urlString = "http://0720backendapi15.snapsnap.com.sg/index.php/dphodto/dphodto_new_post/" + albumID! + "/" + self.data.entries.first!.post_id! + "/" + userID!
        }
        
        println(urlString)
        
        let url = NSURL(string: urlString)
        var request = NSURLRequest(URL: url!)
        let queue: NSOperationQueue = NSOperationQueue.mainQueue()
        NSURLConnection.sendAsynchronousRequest(request, queue: queue, completionHandler: { (response: NSURLResponse!, data: NSData!, error: NSError!) -> Void in
            
            if error == nil {
                if (response as! NSHTTPURLResponse).statusCode == 200 {
                    if data != nil {
                        var posts = JSON(data: data!)
                        
                        // Only add if JSON from server contains more posts
                        if posts.count != 0 {
                            
                            if (UIApplication.sharedApplication().delegate as! AppDelegate).isInitialEntryCleared == false {
                                self.data.clearEntries()
                                (UIApplication.sharedApplication().delegate as! AppDelegate).isInitialEntryCleared = true
                            }
                            
                            self.data.addEntriesToFrontFromJSON(posts)
                            (UIApplication.sharedApplication().delegate as! AppDelegate).firstPostID = self.data.entries.first!.post_id!
                            self.HomeTableView.reloadData()
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
            
            self.refreshControl.endRefreshing()
        })
    }
    
    // Prepare for segue transitions
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        if (segue.identifier == "GoToNewPost") {
            var nc = segue.destinationViewController as! UINavigationController
            var vc = nc.viewControllers.first as! NewPostViewController
            
            vc.newImage = self.newImage
        }
        else if (segue.identifier == "ShowComments") {
            var vc = segue.destinationViewController as! CommentsViewController
            
            vc.postId = self.selectedPostCellId
            vc.parentView = self
            vc.currentCellView = self.selectedPostCell
        }
        else if (segue.identifier == "menuPopoverSegue") {
            
            let vc = segue.destinationViewController as! MenuViewController
            vc.modalPresentationStyle = UIModalPresentationStyle.Popover
            vc.popoverPresentationController!.delegate = self
            vc.parentView = self
        }
        else if (segue.identifier == "ShowWebView") {
            
            let option = (sender as! MenuViewController).option
            let vc = segue.destinationViewController as! WebViewController
            vc.option = option
        }
        else if (segue.identifier == "ShowImageViewer") {
            
            var vc = segue.destinationViewController as! ImageViewController
            vc.image = self.selectedPostCell.PostImage.image
        }
    }
    
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.None
    }
    
    // Camera view
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
        newImage = info[UIImagePickerControllerOriginalImage] as? UIImage
        dismissViewControllerAnimated(true, completion: {
            self.performSegueWithIdentifier("GoToNewPost", sender:self)
        })
        
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func noCamera(){
        let alertVC = UIAlertController(title: "No Camera", message: "Sorry, this device has no camera", preferredStyle: .Alert)
        let okAction = UIAlertAction(title: "OK", style:.Default, handler: nil)
        alertVC.addAction(okAction)
        presentViewController(alertVC, animated: true, completion: nil)
    }
    
    @IBAction func newPost(sender: AnyObject) {
        
        let optionMenu = UIAlertController(title: "New post", message: nil, preferredStyle: .Alert)
        
        let cameraAction = UIAlertAction(title: "Take Photo", style: .Default, handler: {
            (alert: UIAlertAction!) -> Void in
            
            if UIImagePickerController.availableCaptureModesForCameraDevice(.Rear) != nil {
                self.picker.allowsEditing = false
                self.picker.sourceType = UIImagePickerControllerSourceType.Camera
                self.picker.cameraCaptureMode = UIImagePickerControllerCameraCaptureMode.Photo
                self.picker.showsCameraControls = true
                self.presentViewController(self.picker, animated: true, completion: nil)
            } else {
                self.noCamera()
            }

        })
        
        let libraryAction = UIAlertAction(title: "Photo Library", style: .Default, handler: {
            (alert: UIAlertAction!) -> Void in
            
            self.picker.allowsEditing = false
            self.picker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
            self.presentViewController(self.picker, animated: true, completion: nil)
            
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: {
            (alert: UIAlertAction!) -> Void in
        })
        
        optionMenu.addAction(cameraAction)
        optionMenu.addAction(libraryAction)
        optionMenu.addAction(cancelAction)
        
        presentViewController(optionMenu, animated: true, completion: nil)
    }
    
}

