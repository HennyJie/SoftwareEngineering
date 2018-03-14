//
//  RegisterViewController.swift
//  EasySearch
//
//  Created by l_yq on 2017/12/14.
//  Copyright © 2017年 l_yq. All rights reserved.
//

import UIKit
import Alamofire

class RegisterViewController: UIViewController, UIGestureRecognizerDelegate, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var userPhotoField: UIImageView!
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var useremailField: UITextField!
    @IBOutlet weak var userpwdField: UITextField!
    @IBOutlet weak var userpwd2Field: UITextField!
    @IBOutlet weak var pwdNotMatchLabel: UILabel!
    @IBOutlet weak var acceptedSwitch: UISwitch!
    @IBOutlet weak var registerBtn: UIButton!

    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
    }
    
    func setupUI() {
        userPhotoField.layer.masksToBounds = true
        userPhotoField.layer.cornerRadius = userPhotoField.bounds.width / 2
        
        registerBtn.layer.masksToBounds = true
        registerBtn.layer.cornerRadius = 10
        
        userpwdField.isSecureTextEntry = true
        userpwd2Field.isSecureTextEntry = true
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapPhoto))
        tapGesture.delegate = self
        userPhotoField.isUserInteractionEnabled = true
        userPhotoField.addGestureRecognizer(tapGesture)
        
        userPhotoField.contentMode = .scaleAspectFill
        
        registerBtn.isEnabled = false
        registerBtn.backgroundColor = TINT_DISABLE_COLOR
        
        usernameField.delegate = self
        useremailField.delegate = self
        userpwdField.delegate = self
        userpwd2Field.delegate = self
        
        usernameField.addTarget(self, action: #selector(textDidChange(_:)), for: .editingChanged)
        useremailField.addTarget(self, action: #selector(textDidChange(_:)), for: .editingChanged)
        userpwdField.addTarget(self, action: #selector(textDidChange(_:)), for: .editingChanged)
        userpwd2Field.addTarget(self, action: #selector(textDidChange(_:)), for: .editingChanged)
        
        pwdNotMatchLabel.isHidden = true

    }
    
    func changeBtnState() {
        if useremailField.text != "" && usernameField.text != "" && userpwdField.text != "" && userpwd2Field.text == userpwdField.text && acceptedSwitch.isOn {
            registerBtn.isEnabled = true
            registerBtn.backgroundColor = TINT_COLOR
        } else {
            registerBtn.isEnabled = false
            registerBtn.backgroundColor = TINT_DISABLE_COLOR
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == userpwd2Field || textField == userpwdField {
            if userpwd2Field.text == userpwdField.text {
                pwdNotMatchLabel.isHidden = true
            } else {
                pwdNotMatchLabel.isHidden = false
            }
        }
    }
    
    @objc func textDidChange(_ textField: UITextField) {
        changeBtnState()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        let nextTag = textField.tag + 1
        
        if let nextResponder = textField.superview?.viewWithTag(nextTag) {
            nextResponder.becomeFirstResponder()
        } else {
            // Not found, so remove keyboard.
            textField.resignFirstResponder()
        }
        return false
    }
    
    @IBAction func acceptConditions(_ sender: UISwitch) {
        changeBtnState()
    }
    
    @objc func tapPhoto() {
        self.view.endEditing(true)
        let alertViewController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let takephotoAction = UIAlertAction(title: "Take photos", style: .default, handler: { (UIAlertAction) in
           
        })
        
        let selectalbumAction = UIAlertAction(title: "Upload from local", style: .default, handler: { (UIAlertAction) in
            self.view.endEditing(true)
            let imagePickerController = UIImagePickerController()
            imagePickerController.sourceType = .photoLibrary
            imagePickerController.delegate = self
            self.present(imagePickerController, animated: true, completion: nil)
        })
        
        alertViewController.addAction(takephotoAction)
        alertViewController.addAction(selectalbumAction)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
        alertViewController.addAction(cancelAction)
        
        self.present(alertViewController, animated: true, completion: nil)
    }
    
    @objc func selectPhotoFromAlbum() {
        self.view.endEditing(true)
        let imagePickerController = UIImagePickerController()
        imagePickerController.sourceType = .photoLibrary
        imagePickerController.delegate = self
        present(imagePickerController, animated: true, completion: nil)
    }
    
    // MARK: UIImagePickerControllerDelegate
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        
        // dismiss the picker if the user canceled
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        guard let selectedImage = info[UIImagePickerControllerOriginalImage] as?
            UIImage else {
                fatalError("Expected a dictionary containing an image, but was provided the following: \(info)")
        }
        
        // resize image.
        let areaOfImage:Double = Double(selectedImage.size.width * selectedImage.size.height)
        if areaOfImage > (100*100) {
            let ratio = sqrt(areaOfImage / (100.0*100.0))
            let newImage = selectedImage.scaleImage(scaleSize: CGFloat(1.0/ratio))
            print(newImage.size)
            userPhotoField.image = newImage
        } else {
            userPhotoField.image = selectedImage
        }
        dismiss(animated: true, completion: nil)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }


    @IBAction func registerNew(_ sender: UIButton) {
        print("register an account.")
        
        guard useremailField.text != "" && usernameField.text != "" && userpwdField.text != "" && userpwd2Field.text == userpwdField.text && acceptedSwitch.isOn else {
            let alertController = UIAlertController(title: "Input Error", message: "Invalid input", preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alertController.addAction(cancelAction)
            self.present(alertController, animated: true, completion: {
                self.userpwdField.text = ""
                self.userpwd2Field.text = ""
                self.registerBtn.isEnabled = false
                self.registerBtn.backgroundColor = TINT_DISABLE_COLOR
            })
            
            print("Input Error: some info is emoty or pwd not match")
            return
        }
        
        let uname = usernameField.text!
        let uemail = useremailField.text!
        let upwd = userpwdField.text!
        let uphoto = userPhotoField.image ?? #imageLiteral(resourceName: "Killua")
        
        
        ApiCnfigModel().hasouInster(uname: uname, uemail: uemail, upwd: upwd, uphoto: uphoto) { (res, error) in
            print("complete.")
            if res {
                // register suc.
                let alertController = UIAlertController(title: "Register", message: "Successfully", preferredStyle: .alert)
                let cancelAction = UIAlertAction(title: "OK", style: .cancel, handler: { (UIAlertAction) in
                    self.navigationController?.popViewController(animated: true)
                })
                alertController.addAction(cancelAction)
                self.present(alertController, animated: true, completion: nil)
            } else {
                // register failed.
                let alertController = UIAlertController(title: "Input Error", message: "E-mail used.", preferredStyle: .alert)
                
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
                    if error == nil {
                        self.useremailField.text = ""
                        self.registerBtn.isEnabled = false
                        self.registerBtn.backgroundColor = TINT_DISABLE_COLOR
                    }
                })
            }
        }
        
    }
}
