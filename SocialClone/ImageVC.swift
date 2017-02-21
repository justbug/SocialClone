//
//  ImageVC.swift
//  SocialClone
//
//  Created by Mark Chen on 2017/2/12.
//  Copyright © 2017年 Mark Chen. All rights reserved.
//

import UIKit
import Hero
import Firebase
class ImageVC: UIViewController {

    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var caption: UILabel!
    @IBOutlet weak var name: UILabel!
    var imageFromFeed = UIImage()
    var post:Post!
    var loadingIndicator = UIActivityIndicatorView()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadingIndicator.center = image.center
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.activityIndicatorViewStyle = .white
        self.view.addSubview(loadingIndicator)
        loadingIndicator.startAnimating()
        
        let ref = FIRStorage.storage().reference(forURL: post.imageUrl)
        ref.data(withMaxSize: 2 * 1024 * 1024, completion: { (data, error) in
            if error != nil {
                print("MARK: Unable to download from firebase")
            } else {
                print("MARK: Image downloaded from firebase")
                if let imageData = data {
                    if let image = UIImage(data: imageData) {
                        DispatchQueue.main.async {
                            self.image.image = image
                        }
                        self.loadingIndicator.stopAnimating()
                    }
                }
            }
        })
   //     image.image = imageFromFeed
        name.text = post.poster_name
        caption.text = post.caption
        // Do any additional setup after loading the view.
    }


}
