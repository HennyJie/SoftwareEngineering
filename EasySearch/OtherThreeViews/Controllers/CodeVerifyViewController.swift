//
//  CodeVerifyViewController.swift
//  EasySearch
//
//  Created by l_yq on 2018/1/7.
//  Copyright © 2018年 l_yq. All rights reserved.
//

import UIKit

class CodeVerifyViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var getCodeBtn: UIButton!
    @IBOutlet weak var nextStep: UIButton!
    @IBOutlet weak var verifyCodeField: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        setupUI()
    }
    
    func setupUI() {
        self.navigationController?.navigationBar.setBackgroundImage(#imageLiteral(resourceName: "Nav.bg"), for: .default)
        self.navigationItem.title = "Account Security"
        navigationController?.navigationBar.tintColor = .black
        
        
        let leftBtn = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelChangePwd))
        navigationItem.leftBarButtonItem = leftBtn
        
        getCodeBtn.layer.masksToBounds = true
        getCodeBtn.layer.cornerRadius = 5
        
        nextStep.layer.masksToBounds = true
        nextStep.layer.cornerRadius = 10
        nextStep.backgroundColor = TINT_DISABLE_COLOR
        nextStep.isEnabled = false
        
        verifyCodeField.addTarget(self, action: #selector(editDidChanged(_:)), for: .editingChanged)
        verifyCodeField.keyboardType = .numberPad
        
    }
    
    @objc func cancelChangePwd() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc func editDidChanged(_ textField: UITextField) {
        if verifyCodeField.text != "" {
            nextStep.backgroundColor = TINT_COLOR
            nextStep.isEnabled = true
        } else {
            nextStep.backgroundColor = TINT_DISABLE_COLOR
            nextStep.isEnabled = false
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func nextAction(_ sender: UIButton) {
        // verify the code...
        performSegue(withIdentifier: "tochangepwd", sender: nil)
    }
    
}
