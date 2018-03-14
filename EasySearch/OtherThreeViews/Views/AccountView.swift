//
//  AccountView.swift
//  TestSettingPage
//
//  Created by l_yq on 2018/1/6.
//  Copyright © 2018年 l_yq. All rights reserved.
//

import UIKit

class AccountView: UIView {
    
    var uname: UILabel!
    var account: UILabel!
    var rechargeImage: UIImageView!
    var vipImage: UIImageView!
    var rechargeBtn: UIButton!
    var vipBtn: UIButton!
    
    var delegate: AccountViewDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    func setupUI() {
        self.layer.masksToBounds = true
        self.layer.cornerRadius = 10.0
        self.backgroundColor = UIColor(displayP3Red: 252.0/255.0, green: 250.0/255.0, blue: 242.0/255.0, alpha: 1.0)
        
        uname = UILabel(frame: CGRect(x: 15, y: 30, width: 300, height: 23))
        uname.font = UIFont(name: "System", size: 25.0)
        self.addSubview(uname)
        
        account = UILabel(frame: CGRect(x: 15, y: 100, width: 300, height: 40))
        account.font = UIFont.systemFont(ofSize: 30)
        account.text = "Account: ￥0.00"
        account.textColor = TINT_COLOR
        self.addSubview(account)
        
        rechargeImage = UIImageView(frame: CGRect(x: 15, y: 140+30, width: 39, height: 27))
        self.addSubview(rechargeImage)
        rechargeImage.image = #imageLiteral(resourceName: "recharge.icon")
        
        rechargeBtn = UIButton(type: .system)
        rechargeBtn.backgroundColor = TINT_COLOR
        rechargeBtn.frame = CGRect(x: 15+60, y: 140+27, width: 120, height: 35)
        rechargeBtn.layer.masksToBounds = true
        rechargeBtn.layer.cornerRadius = 15.0
        rechargeBtn.setTitle("Recharge", for: .normal)
        rechargeBtn.tintColor = .white
        rechargeBtn.titleLabel?.font = UIFont(name: "System", size: 25.0)
        self.addSubview(rechargeBtn)
        
        vipImage = UIImageView(frame: CGRect(x: 15, y: 140+40+46, width: 43, height: 38))
        self.addSubview(vipImage)
        vipImage.image = #imageLiteral(resourceName: "vip.icon")
        
        vipBtn = UIButton(type: .system)
        vipBtn.backgroundColor = TINT_COLOR
        vipBtn.frame = CGRect(x: 15+60, y: 140+40+48, width: 120, height: 35)
        vipBtn.layer.masksToBounds = true
        vipBtn.layer.cornerRadius = 15.0
        vipBtn.setTitle("VIP", for: .normal)
        vipBtn.tintColor = .white
        vipBtn.titleLabel?.font = UIFont(name: "System", size: 25.0)
        self.addSubview(vipBtn)
        
        rechargeBtn.addTarget(self, action: #selector(btnClick(_:)), for: .touchUpInside)
        vipBtn.addTarget(self, action: #selector(btnClick(_:)), for: .touchUpInside)
        
        uname.text = "Name"
        
    }
    
    func setAccount(balance: Double) {
        self.account.text = "Account: ￥" + String(balance)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func btnClick(_ sender: UIButton) {
        if delegate != nil {
            switch(sender) {
            case rechargeBtn: delegate?.rechargeAction()
            case vipBtn: delegate?.vipAction()
            default:
                break
            }
        } else {
            print("delegate is nil")
        }
    }
    
    func resetView() {
        // request balance from server
    }

}

protocol AccountViewDelegate {
    func rechargeAction()
    func vipAction()
}
