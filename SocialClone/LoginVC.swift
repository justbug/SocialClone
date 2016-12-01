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
import SwiftKeychainWrapper
class LoginVC: UIViewController,UITextFieldDelegate {
    
    @IBOutlet weak var emailTextField: FancyField!
    @IBOutlet weak var pwdTextField: FancyField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        emailTextField.delegate = self
        pwdTextField.delegate = self
        // Do any additional setup after loading the view, typically from a nib.
    }
    override func viewDidAppear(_ animated: Bool) {
        if let _ = KeychainWrapper.standard.string(forKey: KEY_USER_ID) {
            performSegue(withIdentifier: "goFeedView", sender: nil)
        }
    }
    
    @IBAction func signInBtnTapped(_ sender:UIButton) {
        self.checkTextfieldTypingError {
            self.firebaseAuthEmail()
        }
    }
    
    @IBAction func FBLoginBtnTapped(_ sender: UIButton) {
        let FBLogin = FBSDKLoginManager()
        
        FBLogin.logIn(withReadPermissions: ["email"], from: self) { (result, error) in
            if error != nil {
                print("MARK: Unable to authenticate with facebook - \(error)")
            }else if result?.isCancelled == true {
                print("MARK: User cancelled facebook authenticate")
            }else{
                print("MARK: Success, authenticate with facebook")
                let credential = FIRFacebookAuthProvider.credential(withAccessToken: FBSDKAccessToken.current().tokenString)
                self.firebaseAuthCredential(credential)
            }
        }
    }
    
    func checkTextfieldTypingError(completed: ()->()) {
        
        let alertViewController = UIAlertController(title: "登入失敗", message: "", preferredStyle: .alert)
        let alertAction = UIAlertAction(title: "重新輸入", style: .default, handler: nil)
        alertViewController.addAction(alertAction)
        
        if emailTextField.text == "" || pwdTextField.text == "" {
            alertViewController.message = "電子郵件或密碼有一欄為空值"
            self.present(alertViewController, animated: true, completion: nil)
        }else {
            if !(emailTextField.text?.isValidEmail())! {
                alertViewController.message = "電子郵件格式不正確"
                self.present(alertViewController, animated: true, completion: nil)
            }else  if (pwdTextField.text?.characters.count)! < 6{
                alertViewController.message = "密碼不能少於5個字元"
                self.present(alertViewController, animated: true, completion: nil)
            }else {
                completed()
            }
        }
    }
    
    func checkUserKeyChain(_ user: FIRUser) {
        KeychainWrapper.standard.set(user.uid, forKey: KEY_USER_ID)
        self.performSegue(withIdentifier: "goFeedView", sender: nil)
    }
    
    // MARK: - firebaseAuth
    
    func firebaseAuthCredential(_ credential:FIRAuthCredential) {
        FIRAuth.auth()?.signIn(with: credential, completion: { (user, error) in
            if error != nil{
                print("MARK: Unable to authenticate with firebase - \(error)")
            }else {
                print("MARK: Success, authenticate with firebase")
                if let user = user {
                    self.checkUserKeyChain(user)
                }
            }
        })
        
    }
    
    func firebaseAuthEmail() {
        if let email = emailTextField.text, let pwd = pwdTextField.text {
            FIRAuth.auth()?.signIn(withEmail: email, password: pwd, completion: { (user, error) in
                if error == nil {
                    print("MARK: (Email) User authenticate with firebase")
                    if let user = user {
                        self.checkUserKeyChain(user)
                    }
                }else {
                    FIRAuth.auth()?.createUser(withEmail: email, password: pwd, completion: { (user, error) in
                        if error != nil {
                            print("MARK: (Email) User can't authenticate with firebase")
                            print(error)
                        }else {
                            print("MARK: (Email) User successfully create a new account")
                            if let user = user {
                                self.checkUserKeyChain(user)
                            }
                        }
                    })
                }
            })
        }
    }

    // MARK: - dismiss textfield
    
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

extension String {
    func isValidEmail() -> Bool{
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"
        return NSPredicate(format: "SELF MATCHES %@", emailRegex).evaluate(with: self)
    }
}
