//
//  LoginViewController.swift
//  EasySearch
//
//  Created by l_yq on 2017/12/9.
//  Copyright © 2017年 l_yq. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import SVProgressHUD

let TINT_COLOR: UIColor = UIColor(displayP3Red: 183.0/255.0, green: 224.0/255.0, blue: 229.0/255.0, alpha: 1.0)
let TINT_DISABLE_COLOR: UIColor = UIColor(displayP3Red: 242.0/255.0, green: 242.0/255.0, blue: 242.0/255.0, alpha: 1.0)

class LoginViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var formField: UIView!
    @IBOutlet weak var userPhoto: UIImageView!
    
    @IBOutlet weak var useremailField: UITextField!
    @IBOutlet weak var userPwdField: UITextField!
    
    @IBOutlet weak var signInBtn: UIButton!
    
    
    var waitingView: UIView!
    var resultImage: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    func setupUI() {
        navigationController?.navigationBar.setBackgroundImage(#imageLiteral(resourceName: "Nav.bg"), for: .default)
        navigationItem.title = "Sign In"
        formField.layer.borderWidth = 1
        formField.layer.borderColor = UIColor(displayP3Red: 233/255, green: 235/255, blue: 236/255, alpha: 1).cgColor
        formField.layer.masksToBounds = true
        formField.layer.cornerRadius = 10
        userPwdField.isSecureTextEntry = true
        
        userPhoto.layer.masksToBounds = true
        userPhoto.layer.cornerRadius = userPhoto.bounds.width / 2
        
        signInBtn.layer.masksToBounds = true
        signInBtn.layer.cornerRadius = 10
        
        navigationController?.navigationBar.tintColor = .black
        
        waitingView = UIView(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: SCREEN_HEIGHT))
        waitingView.backgroundColor = UIColor(displayP3Red: 0, green: 0, blue: 0, alpha: 0.3);
        self.navigationController?.view.addSubview(self.waitingView)
        waitingView.isHidden = true
        
        let resWidth: CGFloat = 150.0
        resultImage = UIImageView(frame: CGRect(x: SCREEN_WIDTH/2 - resWidth/2, y: SCREEN_HEIGHT/2 - resWidth/2, width: resWidth, height: resWidth))
        resultImage.image = #imageLiteral(resourceName: "loginsuc")
        self.view.addSubview(resultImage)
        resultImage.isHidden = true
        
        // when editfield did changed, update the state of signin button.
        useremailField.addTarget(self, action: #selector(textDidChange(_:)), for: .editingChanged)
        userPwdField.addTarget(self, action: #selector(textDidChange(_:)), for: .editingChanged)
        
        userPwdField.delegate = self
        useremailField.delegate = self
        
        signInBtn.isEnabled = false
        signInBtn.backgroundColor = TINT_DISABLE_COLOR
    }
    
    @objc func textDidChange(_ textField: UITextField) {
        if useremailField.text != "" && userPwdField.text != "" {
            signInBtn.isEnabled = true
            signInBtn.backgroundColor = TINT_COLOR
        } else {
            signInBtn.isEnabled = false
            signInBtn.backgroundColor = TINT_DISABLE_COLOR
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == userPwdField {
            self.view.endEditing(true)
        } else {
            userPwdField.becomeFirstResponder()
        }
        return false
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == useremailField {
            ApiCnfigModel().hasouGetPhoto(uemail: textField.text!, complete: { (res, image, error) in
                if res {
                    self.userPhoto.image = image
                }
            })
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    // MARK: action
    @IBAction func skipLogin(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func createNewAccount(_ sender: UIButton) {
        performSegue(withIdentifier: "register", sender: nil)
    }
    
    @IBAction func signIn(_ sender: UIButton) {
        self.view.endEditing(true)
        print(useremailField.text ?? "email nil")
        print(userPwdField.text ?? "pwd nil")
        
        guard userPwdField.text != "" && useremailField.text != "" else {
            let alertController = UIAlertController(title: "Input Error", message: "E-mail or Password is empty.", preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alertController.addAction(cancelAction)
            self.present(alertController, animated: true, completion: {
                self.userPwdField.text = ""
                self.signInBtn.isEnabled = false
                self.signInBtn.backgroundColor = TINT_DISABLE_COLOR
            })
            
            print("Input Error: email or password is empty.")
            return
        }
        
        
        let uemail = useremailField.text!
        let upwd = userPwdField.text!
        
        // asyn op
        waitingView.isHidden = false
        SVProgressHUD.show()
        ApiCnfigModel().hasouCheckUser(uemail: uemail, upwd: upwd) { (res, uname, error) in
            SVProgressHUD.dismiss()
            
            // show result.
            if res { // sign in success.
                print("Success: sign in.")
                
                self.resultImage.alpha = 1.0
                self.resultImage.isHidden = false
                
                // user info
                UserDefaults.standard.set(uname, forKey: "uname")
                UserDefaults.standard.set(uemail, forKey: "uemail")
                UserDefaults.standard.set(upwd, forKey: "upwd")
                
                UIView.animate(withDuration: 0.5, animations: {
                    self.resultImage.alpha = 0.0
                }, completion: { (Bool) in
                    UserDefaults.standard.set(true, forKey: "isLogin")
                    self.dismiss(animated: true, completion: nil)
                })
                
            } else {
                // parse connection error type
                let alertController = UIAlertController(title: "Input Error", message: "Invalid E-mail or Password", preferredStyle: .alert)
                
                if error != nil {
                    alertController.title = "Connection Error"
                    switch(error!) {
                    case .ConFailed:
                        alertController.message = "Cannot connect to server."
                    case .JsonTypeError:
                        alertController.message = "Server return type error"
                    default: break
                    }
                }
                
                let cancelAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                alertController.addAction(cancelAction)
                self.present(alertController, animated: true, completion: {
                    self.userPwdField.text = ""
                    self.signInBtn.isEnabled = false
                    self.signInBtn.backgroundColor = TINT_DISABLE_COLOR
                })
                
                print("Failed: sign in failed.")
            }
            
            self.waitingView.isHidden = true
        }
        
    }
}
