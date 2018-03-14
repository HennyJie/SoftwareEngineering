//
//  ChangePwdViewController.swift
//  EasySearch
//
//  Created by l_yq on 2018/1/7.
//  Copyright © 2018年 l_yq. All rights reserved.
//

import UIKit

class ChangePwdViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var confirmBtn: UIButton!
    @IBOutlet weak var currentPwdFieldd: UITextField!
    @IBOutlet weak var newPwdField: UITextField!
    @IBOutlet weak var newPwd2Field: UITextField!
    @IBOutlet weak var pwdNotMatch: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        setupUI()
    }
    
    func setupUI() {
        confirmBtn.layer.masksToBounds = true
        confirmBtn.layer.cornerRadius = 10
        confirmBtn.backgroundColor = TINT_DISABLE_COLOR
        confirmBtn.isEnabled = false
        
        currentPwdFieldd.isSecureTextEntry = true
        newPwdField.isSecureTextEntry = true
        newPwd2Field.isSecureTextEntry = true
        
        currentPwdFieldd.addTarget(self, action: #selector(editDidChanged(_:)), for: .editingChanged)
        newPwdField.addTarget(self, action: #selector(editDidChanged(_:)), for: .editingChanged)
        newPwd2Field.addTarget(self, action: #selector(editDidChanged(_:)), for: .editingChanged)
        
        currentPwdFieldd.delegate = self
        newPwdField.delegate = self
        newPwd2Field.delegate = self
        
        pwdNotMatch.isHidden = true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func changeBtnState() {
        if currentPwdFieldd.text != "" && newPwdField.text != "" && newPwd2Field.text == newPwdField.text {
            confirmBtn.isEnabled = true
            confirmBtn.backgroundColor = TINT_COLOR
        } else {
            confirmBtn.isEnabled = false
            confirmBtn.backgroundColor = TINT_DISABLE_COLOR
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField.tag == 10 {
            newPwdField.becomeFirstResponder()
        } else if textField.tag == 11 {
            newPwd2Field.becomeFirstResponder()
        } else if textField.tag == 12 {
            self.view.endEditing(true)
        }
        return false
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == newPwd2Field || textField == newPwdField {
            if newPwd2Field.text == newPwdField.text {
                pwdNotMatch.isHidden = true
            } else {
                pwdNotMatch.isHidden = false
            }
        }
    }
    
    @objc func editDidChanged(_ textField: UITextField) {
        changeBtnState()
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
