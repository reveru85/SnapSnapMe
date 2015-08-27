//
//  WebViewController.swift
//  Gegder
//
//  Copyright (c) 2015 Genesys. All rights reserved.
//

import UIKit

class WebViewController: UIViewController {
    
    // Options> 1:about 2:help
    var option: Int32!
    var address: String!
    let aboutAddress = "http://snapsnap.com.sg/webdev/aboutus.php"
    let helpAddress = "http://snapsnap.com.sg/webdev/help.php"
    @IBOutlet weak var webView: UIWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        switch (self.option) {
        case 1:
            address = aboutAddress
            self.title = "About"
            break;
        case 2:
            address = helpAddress
            self.title = "Help"
            break;
        default:
            address = "http://www.google.com"
            break;
        }
        
        let url = NSURL (string: address);
        let requestObj = NSURLRequest(URL: url!);
        webView.loadRequest(requestObj);
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}