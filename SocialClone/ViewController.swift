//
//  ViewController.swift
//  SocialClone
//
//  Created by Mark Chen on 2016/11/21.
//  Copyright © 2016年 Mark Chen. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit
import FirebaseAuth
class ViewController: UIViewController,UITextFieldDelegate {

    @IBOutlet weak var emailTextField: FancyField!
    @IBOutlet weak var pwdTextField: FancyField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        emailTextField.delegate = self
        pwdTextField.delegate = self
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    @IBAction func tappedFBLoginBtn(_ sender: UIButton) {
        let FBLogin = FBSDKLoginManager()
        
        FBLogin.logIn(withReadPermissions: ["email"], from: self) { (result, error) in
            if error != nil {
                print("MARK: Unable to authenticate with facebook - \(error)")
            }else if result?.isCancelled == true {
                print("MARK: User cancelled facebook authenticate")
            }else{
                print("MARK: Success, authenticate with facebook")
                let credential = FIRFacebookAuthProvider.credential(withAccessToken: FBSDKAccessToken.current().tokenString)
                self.firebaseAuth(credential)
            }
        }
    }
    
    func firebaseAuth(_ credential:FIRAuthCredential){
        FIRAuth.auth()?.signIn(with: credential, completion: { (user, error) in
            if error != nil{
                print("MARK: Unable to authenticate with firebase - \(error)")
            }else {
                print("MARK: Success, authenticate with firebase")
            }
        })
        
    }
    //MARK- dismiss textfield
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
        super.touchesBegan(touches, with: event)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        emailTextField.resignFirstResponder()
        pwdTextField.resignFirstResponder()
        return true
    }

}

