//
//  FeedVC.swift
//  SocialClone
//
//  Created by Mark Chen on 2016/12/1.
//  Copyright © 2016年 Mark Chen. All rights reserved.
//

import UIKit
import SwiftKeychainWrapper
import FirebaseAuth
class FeedVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func signOutBtnTapped(_ sender: UIButton) {
        let removeSuccessful = KeychainWrapper.standard.removeObject(forKey: KEY_USER_ID)
        if removeSuccessful {
            try! FIRAuth.auth()?.signOut()
            performSegue(withIdentifier: "goLoginView", sender: nil)
        }
    }

}
