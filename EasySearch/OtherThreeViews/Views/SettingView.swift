//
//  SettingView.swift
//  TestSettingPage
//
//  Created by l_yq on 2018/1/6.
//  Copyright © 2018年 l_yq. All rights reserved.
//

import UIKit

class SettingView: UIView {
    
    var uname: UILabel!
    var uemail: UILabel!
    var changePwdBtn: UIButton!
    var logoutBtn: UIButton!
    var resetBtn: UIButton!
    var accountBtn: UIButton!
    var delegate: SettingViewDelegate?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    func setupUI() {
        
        self.layer.masksToBounds = true
        self.layer.cornerRadius = 10.0
        self.backgroundColor = UIColor(displayP3Red: 252.0/255.0, green: 250.0/255.0, blue: 242.0/255.0, alpha: 1.0)
        
        let utop = 30
        let lh = 23 + 15
        let bh = 35 + 15
        
        uname = UILabel(frame: CGRect(x: 15, y: utop, width: 300, height: 23))
        uemail = UILabel(frame: CGRect(x: 15, y: utop + lh, width: 300, height: 23))
        self.addSubview(uname)
        self.addSubview(uemail)
        
        changePwdBtn = UIButton(type: .system)
        changePwdBtn.backgroundColor = TINT_COLOR
        changePwdBtn.frame = CGRect(x: 15, y: utop+lh*2, width: 160, height: 35)
        changePwdBtn.layer.masksToBounds = true
        changePwdBtn.layer.cornerRadius = 15.0
        changePwdBtn.setTitle("Change Password", for: .normal)
        changePwdBtn.tintColor = .white
        changePwdBtn.titleLabel?.font = UIFont(name: "System", size: 25.0)
        self.addSubview(changePwdBtn)
        
        logoutBtn = UIButton(type: .system)
        logoutBtn.backgroundColor = TINT_COLOR
        logoutBtn.frame = CGRect(x: 15, y: utop+lh*2+bh, width: 80, height: 35)
        logoutBtn.layer.masksToBounds = true
        logoutBtn.layer.cornerRadius = 15.0
        logoutBtn.setTitle("Logout", for: .normal)
        logoutBtn.tintColor = .white
        logoutBtn.titleLabel?.font = UIFont(name: "System", size: 25.0)
        self.addSubview(logoutBtn)
        
        resetBtn = UIButton(type: .system)
        resetBtn.backgroundColor = TINT_COLOR
        resetBtn.frame = CGRect(x: 15, y: utop+lh*2+bh*2, width: 70, height: 35)
        resetBtn.layer.masksToBounds = true
        resetBtn.layer.cornerRadius = 15.0
        resetBtn.setTitle("Reset", for: .normal)
        resetBtn.tintColor = .gray
        resetBtn.titleLabel?.font = UIFont(name: "System", size: 25.0)
        self.addSubview(resetBtn)

        accountBtn = UIButton(type: .system)
        accountBtn.frame = CGRect(x: Int(Double(SCREEN_WIDTH)/2.0 - 100.0), y: utop+lh*2+bh*3+20, width: 200, height: 45)
        accountBtn.setTitle("My Account balance", for: .normal)
        accountBtn.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20.0)
        accountBtn.tintColor = TINT_COLOR
        self.addSubview(accountBtn)
        
        changePwdBtn.addTarget(self, action: #selector(btnClick(_:)), for: .touchUpInside)
        logoutBtn.addTarget(self, action: #selector(btnClick(_:)), for: .touchUpInside)
        resetBtn.addTarget(self, action: #selector(btnClick(_:)), for: .touchUpInside)
        accountBtn.addTarget(self, action: #selector(btnClick(_:)), for: .touchUpInside)
        
        uname.text = "Name"
        uemail.text = "E-mail Address"
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func btnClick(_ sender: UIButton) {
        if delegate != nil {
            switch(sender){
            case changePwdBtn: delegate?.changePwdAction()
            case resetBtn: delegate?.resetAction()
            case logoutBtn: delegate?.logoutAction()
            case accountBtn: delegate?.accountAction()
            default:
                break
            }
        } else {
            print("delegate is nil")
        }
    }
    
}

protocol SettingViewDelegate {
    func changePwdAction()
    func resetAction()
    func logoutAction()
    func accountAction()
}
