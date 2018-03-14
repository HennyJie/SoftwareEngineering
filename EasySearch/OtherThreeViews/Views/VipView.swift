//
//  VipView.swift
//  TestSettingPage
//
//  Created by l_yq on 2018/1/6.
//  Copyright © 2018年 l_yq. All rights reserved.
//

import UIKit

class VipView: UIView {
    
    var vipImage: UIButton!
    var vipBtn: UIButton!
    var infoImage: UIImageView!
    var buyNowBtn: UIButton!
    var vipMoreInfo: UIImageView!
    
    var delegate: VipViewDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupUI() {
        self.layer.masksToBounds = true
        self.layer.cornerRadius = 10.0
        self.backgroundColor = UIColor(displayP3Red: 252.0/255.0, green: 250.0/255.0, blue: 242.0/255.0, alpha: 1.0)
        
        vipImage = UIButton(type: .system)
        vipImage.frame = CGRect(x: 15, y: 30, width: 43, height: 38)
        vipImage.setBackgroundImage(#imageLiteral(resourceName: "vip.icon"), for: .normal)
        vipImage.addTarget(self, action: #selector(btnClick(_:)), for: .touchUpInside)
        self.addSubview(vipImage)
        
        
        vipBtn = UIButton(type: .system)
        vipBtn.backgroundColor = TINT_COLOR
        vipBtn.frame = CGRect(x: 15+60, y: 32, width: 120, height: 35)
        vipBtn.layer.masksToBounds = true
        vipBtn.layer.cornerRadius = 15.0
        vipBtn.setTitle("VIP", for: .normal)
        vipBtn.tintColor = .white
        vipBtn.titleLabel?.font = UIFont(name: "System", size: 25.0)
        self.addSubview(vipBtn)
        
        let infoheight = Double(SCREEN_WIDTH)*(140.0/384.0)
        infoImage = UIImageView(frame: CGRect(x: 0, y: 80, width: Int(SCREEN_WIDTH), height: Int(infoheight)))
        infoImage.image = #imageLiteral(resourceName: "vipinfo")
        self.addSubview(infoImage)
        
        buyNowBtn = UIButton(type: .system)
        buyNowBtn.frame = CGRect(x: Int(Double(SCREEN_WIDTH)/2.0 - 50.0), y: 80+Int(infoheight)+0, width: 100, height: 45)
        buyNowBtn.setTitle("Buy Now", for: .normal)
        buyNowBtn.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20.0)
        buyNowBtn.tintColor = .red
        buyNowBtn.addTarget(self, action: #selector(btnClick(_:)), for: .touchUpInside)
        self.addSubview(buyNowBtn)
        
        vipMoreInfo = UIImageView(frame: CGRect(x: 0, y: 80+Int(infoheight)+60, width: Int(189.0*1.2), height: Int(102.0*1.2)))
        vipMoreInfo.image = #imageLiteral(resourceName: "vipinfomore")
        self.addSubview(vipMoreInfo)
    }

    @objc func btnClick(_ sender: UIButton) {
        if sender == buyNowBtn && delegate != nil{
            delegate?.buyAction()
        }
        
        if delegate != nil {
            switch(sender) {
            case vipImage:
                delegate?.dismissVipAction()
            default:
                break
            }
        }
    }
}

protocol VipViewDelegate {
    func buyAction()
    func dismissVipAction()
}
