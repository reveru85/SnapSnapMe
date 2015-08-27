//
//  ImageViewController.swift
//  Gegder
//
//  Copyright (c) 2015 Genesys. All rights reserved.
//

import UIKit

class ImageViewController: UIViewController, UIScrollViewDelegate {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var imageView: UIImageView!
    
    var image: UIImage!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        imageView.image = self.image
        
        self.scrollView.maximumZoomScale = 5.0
        self.scrollView.clipsToBounds = true
    }
    
    @IBAction func closeButtonTouch(sender: UIButton) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return self.imageView
    }
}