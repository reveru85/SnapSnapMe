//
//  CommentsTableViewCell.swift
//  Gegder
//
//  Copyright (c) 2015 Genesys. All rights reserved.
//

import UIKit

class CommentsTableViewCell: UITableViewCell {

    @IBOutlet weak var Comment: UILabel!
    @IBOutlet weak var CommentDatetime: UILabel!
    @IBOutlet weak var UserLabel: UILabel!
    
    var parentView: CommentsViewController!
    var entry : CommentData.CommentEntry!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    @IBAction func FlagButtonTouch(sender: UIButton) {
        
        var urlString = "http://0720backendapi15.snapsnap.com.sg/index.php/dphodto_comment/action_flag_as_inappropriate/" + self.entry.commentId!
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
                            (self.parentView as CommentsViewController).data.removeEntry(self.entry.commentId!)
                            (self.parentView as CommentsViewController).CommentsTableView.reloadData()
                            
                            var flagAlert = UIAlertController(title: "", message: "You have flagged the comment as inappropriate.", preferredStyle: UIAlertControllerStyle.Alert)
                            flagAlert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Cancel, handler: nil))
                            (self.parentView as CommentsViewController).presentViewController(flagAlert, animated: true, completion: nil)
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

