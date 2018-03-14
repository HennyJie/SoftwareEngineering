//
//  RechargeView.swift
//  TestSettingPage
//
//  Created by l_yq on 2018/1/6.
//  Copyright © 2018年 l_yq. All rights reserved.
//

import UIKit

class RechargeView: UIView {
    
    var rechargeImage: UIButton!
    var rechargeBtn: UIButton!
    var infoImage: UIImageView!
    var buyNowBtn: UIButton!
    var moreDis: UILabel!
    var recAmount: UIView!
    var recaInput: UITextField!
    var conAmount: UILabel!
    var confirmBtn: UIButton!
    
    var delegate: RechargeViewDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    func setupUI() {
        self.layer.masksToBounds = true
        self.layer.cornerRadius = 10.0
        self.backgroundColor = UIColor(displayP3Red: 252.0/255.0, green: 250.0/255.0, blue: 242.0/255.0, alpha: 1.0)
        
        rechargeImage = UIButton(type: .system)
        rechargeImage.setBackgroundImage(#imageLiteral(resourceName: "recharge.icon"), for: .normal)
        rechargeImage.frame = CGRect(x: 15, y: 35, width: 39, height: 27)
        rechargeImage.addTarget(self, action: #selector(btnClick(_:)), for: .touchUpInside)
        self.addSubview(rechargeImage)
        
        rechargeBtn = UIButton(type: .system)
        rechargeBtn.backgroundColor = TINT_COLOR
        rechargeBtn.frame = CGRect(x: 15+60, y: 32, width: 120, height: 35)
        rechargeBtn.layer.masksToBounds = true
        rechargeBtn.layer.cornerRadius = 15.0
        rechargeBtn.setTitle("Recharge", for: .normal)
        rechargeBtn.tintColor = .white
        rechargeBtn.titleLabel?.font = UIFont(name: "System", size: 25.0)
        self.addSubview(rechargeBtn)
        
        let infoheight = Double(SCREEN_WIDTH)*(140.0/384.0)
        infoImage = UIImageView(frame: CGRect(x: 0, y: 80, width: SCREEN_WIDTH, height: CGFloat(infoheight)))
        infoImage.image = #imageLiteral(resourceName: "reInfo")
        self.addSubview(infoImage)
        
        buyNowBtn = UIButton(type: .system)
        buyNowBtn.frame = CGRect(x: Int(Double(SCREEN_WIDTH)/2.0 - 50.0), y: 80+Int(infoheight)+0, width: 100, height: 45)
        buyNowBtn.setTitle("Buy Now", for: .normal)
        buyNowBtn.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20.0)
        buyNowBtn.tintColor = .red
        self.addSubview(buyNowBtn)
        
        moreDis = UILabel(frame: CGRect(x: Int(Double(SCREEN_WIDTH)/2.0 - 120.0), y: 80+Int(infoheight)+40, width: 240, height: 45))
        moreDis.text = "More discount for VIP!!"
        moreDis.textColor = .red
        moreDis.textAlignment = .center
        moreDis.font = UIFont.boldSystemFont(ofSize: 20.0)
        self.addSubview(moreDis)
        
        recAmount = UIView(frame: CGRect(x: 15, y: 80, width: SCREEN_WIDTH-30, height: 30))
        recAmount.backgroundColor = .white
        recAmount.layer.masksToBounds = true
        recAmount.layer.cornerRadius = 15.0
        
        let recaLabel = UILabel(frame: CGRect(x: 20, y: 0, width: 190, height: 30))
        recaLabel.text = "Recharge Amount: ￥"
        recaLabel.font = UIFont.boldSystemFont(ofSize: 17.0)
        recAmount.addSubview(recaLabel)
        
        recaInput = UITextField(frame: CGRect(x: 200, y: 0, width: 100, height: 30))
        recaInput.placeholder = "0.00"
        recaInput.keyboardType = .decimalPad
        recaInput.addTarget(self, action: #selector(editDidChange), for: .editingChanged)
        recAmount.addSubview(recaInput)
        self.addSubview(recAmount)
        
        conAmount = UILabel(frame: CGRect(x: 0, y: 80+30+50, width: Int(SCREEN_WIDTH), height: 45))
        conAmount.text = "￥ 0.00"
        conAmount.textColor = .black
        conAmount.textAlignment = .center
        conAmount.font = UIFont.boldSystemFont(ofSize: 40.0)
        self.addSubview(conAmount)
        
        confirmBtn = UIButton(type: .system)
        confirmBtn.frame = CGRect(x: Int(SCREEN_WIDTH/2)-75, y: 250, width: 150, height: 40)
        confirmBtn.setTitle("Confirm", for: .normal)
        confirmBtn.backgroundColor = TINT_COLOR
        confirmBtn.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20.0)
        confirmBtn.tintColor = .white
        confirmBtn.layer.masksToBounds = true
        confirmBtn.layer.cornerRadius = 15.0
        confirmBtn.addTarget(self, action: #selector(btnClick(_:)), for: .touchUpInside)
        self.addSubview(confirmBtn)
        
        // ============================================
//        infoImage.isHidden = true
//        buyNowBtn.isHidden = true
//        moreDis.isHidden = true
        
        recAmount.isHidden = true
        confirmBtn.isHidden = true
        conAmount.isHidden = true
        
        // ============================================
        
        
        buyNowBtn.addTarget(self, action: #selector(btnClick(_:)), for: .touchUpInside)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.endEditing(true)
    }
    
    @objc func editDidChange() {
        var amount = recaInput.text!
        if amount == "" {
            amount = "0.00"
        }
        conAmount.text = "￥ " + amount
    }
    
    @objc func btnClick(_ sender: UIButton) {
        if sender == buyNowBtn {
            buyAction()
        }
        
        if delegate != nil {
            switch(sender) {
            case confirmBtn:
                delegate?.confirmAction(amount: Double(recaInput.text!) ?? 0)
            case rechargeImage:
                delegate?.dismissRechargeAction()
            default:
                break
            }
        } else {
            print("delegate is nil")
        }
    }
    
    func buyAction() {
        recAmount.isHidden = false
        confirmBtn.isHidden = false
        conAmount.isHidden = false
        
        self.recAmount.alpha = 0.0
        self.confirmBtn.alpha = 0.0
        self.conAmount.alpha = 0.0
        
        self.infoImage.alpha = 1.0
        self.buyNowBtn.alpha = 1.0
        self.moreDis.alpha = 1.0
        
        UIView.animate(withDuration: 0.5, animations: {
            self.infoImage.alpha = 0.0
            self.buyNowBtn.alpha = 0.0
            self.moreDis.alpha = 0.0
            
            self.recAmount.alpha = 1.0
            self.confirmBtn.alpha = 1.0
            self.conAmount.alpha = 1.0
        }) { (Bool) in
            self.infoImage.isHidden = true
            self.buyNowBtn.isHidden = true
            self.moreDis.isHidden = true
        }
    }
    
    func resetView() {
        recAmount.isHidden = true
        confirmBtn.isHidden = true
        conAmount.isHidden = true
        recaInput.text = ""
        conAmount.text = "￥ 0.00"
        
        infoImage.isHidden = false
        buyNowBtn.isHidden = false
        moreDis.isHidden = false
        
        self.infoImage.alpha = 1.0
        self.buyNowBtn.alpha = 1.0
        self.moreDis.alpha = 1.0
        
        self.recAmount.alpha = 1.0
        self.confirmBtn.alpha = 1.0
        self.conAmount.alpha = 1.0
        
    }

}

protocol RechargeViewDelegate {
    func confirmAction(amount: Double)
    func dismissRechargeAction()
}
