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
class FeedVC: UIViewController, UITableViewDelegate, UITableViewDataSource{
    @IBOutlet weak var signOutBtn: UIButton!

    @IBOutlet weak var feedTableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        signOutBtn.imageView?.contentMode = .scaleAspectFit
        // Do any additional setup after loading the view.
    }
    
    @IBAction func signOutBtnTapped(_ sender: UIButton) {
        let removeSuccessful = KeychainWrapper.standard.removeObject(forKey: KEY_USER_ID)
        if removeSuccessful {
            try! FIRAuth.auth()?.signOut()
            performSegue(withIdentifier: "goLoginView", sender: nil)
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "FeedCell") {
            return cell
        } else {
            return UITableViewCell()
        }
    }
}
