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
class LoginVC: UIViewController {
    
    @IBOutlet weak var emailTextField: FancyField!
    @IBOutlet weak var pwdTextField: FancyField!
    var newUserHasSign = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        emailTextField.delegate = self
        pwdTextField.delegate = self
    }
    override func viewDidAppear(_ animated: Bool) {
        //if user has login,go to feedview
        if let _ = KeychainWrapper.standard.string(forKey: KEY_USER_ID) {
            performSegue(withIdentifier: "goFeedView", sender: nil)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goFeedView" {
            let destinationVC = segue.destination as! FeedVC
            destinationVC.isNewUser = newUserHasSign
        }
    }
    
    @IBAction func signInBtnTapped(_ sender:UIButton) {
        if self.checkTextfieldTypingError() {
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
                FBSDKGraphRequest(graphPath: "me", parameters: ["fields":"id, name, email, picture.type(large)"]).start(completionHandler: { (connection, result, error) in
                    if error == nil {
                        let userInfo = result as! [String:Any]
                        let credential = FIRFacebookAuthProvider.credential(withAccessToken: FBSDKAccessToken.current().tokenString)
                        ProgressView.shared.showProgressView(self.view)
                        self.firebaseAuthCredential(credential, userInfo: userInfo)
                    }
                })
            }
        }
    }
    
    func checkTextfieldTypingError() -> Bool {
        
        guard let email = emailTextField.text, let pwd = pwdTextField.text , !email.isEmpty , !pwd.isEmpty else {
            self.showAlertView(message: InputError.emptyField.rawValue)
            return false
        }
        
        guard let emailFormat = emailTextField.text, emailFormat.isValidEmail() else {
            self.showAlertView(message: InputError.emailIsNotFormat.rawValue)
            return false
        }
        
        guard let pwdFormat = pwdTextField.text, pwdFormat.characters.count>=6 else {
            self.showAlertView(message: InputError.passwordIsNotFormat.rawValue)
            return false
        }
        return true
    }
    
    func checkUserKeyChain(_ user: FIRUser) {
        KeychainWrapper.standard.set(user.uid, forKey: KEY_USER_ID)
        self.performSegue(withIdentifier: "goFeedView", sender: nil)
    }
    
    func showAlertView(message: String) {
        let alertViewController = UIAlertController(title: "登入失敗", message: "", preferredStyle: .alert)
        let alertAction = UIAlertAction(title: "重新輸入", style: .default, handler: nil)
        alertViewController.addAction(alertAction)
        
        alertViewController.message = message
        self.present(alertViewController, animated: true, completion: nil)
    }
    
    // MARK: - firebaseAuth
    
    func firebaseAuthCredential(_ credential:FIRAuthCredential,userInfo: [String:Any]) {
        FIRAuth.auth()?.signIn(with: credential, completion: { (user, error) in
            if error != nil{
                print("MARK: Unable to authenticate with firebase - \(error)")
            }else {
                print("MARK: Success, authenticate with firebase")
                if let user = user {
                    let picture = "https://graph.facebook.com/\(userInfo["id"]!)/picture?type=large"
                    let userdata = ["provider": credential.provider,"name":userInfo["name"]!,"picture_url":picture]
                    DataService.dataservice.createDBUser(uid: user.uid, userData: userdata)
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
                        let userdata = ["provider": user.providerID]
                        DataService.dataservice.createDBUser(uid: user.uid, userData: userdata)
                        self.checkUserKeyChain(user)
                    }
                }else {
                    FIRAuth.auth()?.createUser(withEmail: email, password: pwd, completion: { (user, error) in
                        if error != nil {
                            print("MARK: (Email) User can't authenticate with firebase")
                        }else {
                            print("MARK: (Email) User successfully create a new account")
                            if let user = user {
                                let userdata = ["provider": user.providerID]
                                DataService.dataservice.createDBUser(uid: user.uid, userData: userdata)
                                self.newUserHasSign = true
                                self.checkUserKeyChain(user)
                            }
                        }
                    })
                }
            })
        }
    }
}
extension String {
    func isValidEmail() -> Bool{
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"
        return NSPredicate(format: "SELF MATCHES %@", emailRegex).evaluate(with: self)
    }
}
// MARK: - dismiss textfield
extension LoginVC: UITextFieldDelegate {
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
