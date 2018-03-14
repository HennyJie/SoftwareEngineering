//
//  PaymentViewController.swift
//  EasySearch
//
//  Created by l_yq on 2018/1/7.
//  Copyright © 2018年 l_yq. All rights reserved.
//

import UIKit
import SVProgressHUD

class PaymentViewController: UIViewController {

    @IBOutlet weak var payAmountLabel: UILabel!
    @IBOutlet weak var orderInfoLabel: UILabel!
    @IBOutlet weak var paybyInfoLabel: UILabel!
    @IBOutlet weak var payBtn: UIButton!
    @IBOutlet weak var bgView: UIView!
    
    var waitingView: UIView!
    var resInfo: UIImageView!
    
    var orderInfo: String?
    var paybyInfo: String?
    var amount: Double?
    var delegate: PaymentViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        setupUI()
    }
    
    func setupUI() {
        payBtn.layer.masksToBounds = true
        payBtn.layer.cornerRadius = 10
        
        bgView.layer.masksToBounds = true
        bgView.layer.cornerRadius = 10
        
        if orderInfo == nil || paybyInfo == nil || amount == nil {
            print("payment error")
            payBtn.isEnabled = false
            payBtn.backgroundColor = TINT_DISABLE_COLOR
            orderInfo = "Unknown"
            paybyInfo = "Unknown"
            amount = 0.0
        }
        
        orderInfoLabel.text = orderInfo!
        paybyInfoLabel.text = paybyInfo!
        payAmountLabel.text = "￥ " + String(describing: amount!)
        
        waitingView = UIView(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: SCREEN_HEIGHT))
        waitingView.backgroundColor = .gray
        waitingView.alpha = 0.1
        waitingView.isHidden = true
        
        resInfo = UIImageView(frame: CGRect(x: Int(SCREEN_WIDTH)/2-75, y: Int(SCREEN_HEIGHT)/2-75, width: 150, height: 150))
        resInfo.image = #imageLiteral(resourceName: "Killua")
        resInfo.isHidden = true
        
        self.view.addSubview(waitingView)
        self.view.addSubview(resInfo)
    }
    
    @IBAction func closePayment(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func payAmount(_ sender: UIButton) {
        let uemail = UserDefaults.standard.object(forKey: "uemail") as? String
        let upwd = UserDefaults.standard.object(forKey: "upwd") as? String
        
        if orderInfoLabel.text! == "AdvIm Recharge order" {
            print("Payment: recharge")
            SVProgressHUD.show()
            waitingView.isHidden = false
            ApiCnfigModel().hasouPay(uemail: uemail ?? "", upwd: upwd ?? "", account: amount ?? 0.0, pcase: .Recharge, complete: { (res, account, error) in
                SVProgressHUD.dismiss()
                self.waitingView.isHidden = true
                if res {
                    self.paySucAction()
                    return
                } else {
                    // roll back and parse error info
                    let alertController = UIAlertController(title: "Payment Error", message: nil, preferredStyle: .alert)
                    let cancelAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                    alertController.addAction(cancelAction)
                    self.present(alertController, animated: true, completion: nil)
                }
                
            })
            
        } else if orderInfoLabel.text! == "AdvIm VIP order"{
            print("buy VIP")
            
            SVProgressHUD.show()
            waitingView.isHidden = false
            ApiCnfigModel().hasouPay(uemail: uemail ?? "", upwd: upwd ?? "", account: amount ?? 0.0, pcase: .BuyVIP, complete: { (res, account, error) in
                SVProgressHUD.dismiss()
                self.waitingView.isHidden = true
                if res {
                    self.paySucAction()
                    return
                } else {
                    // roll back and parse error info
                    let alertController = UIAlertController(title: "Payment Error", message: nil, preferredStyle: .alert)
                    let cancelAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                    alertController.addAction(cancelAction)
                    self.present(alertController, animated: true, completion: nil)
                }
            })
        } else{
            let alertController = UIAlertController(title: "Payment Error", message: nil, preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alertController.addAction(cancelAction)
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    func paySucAction() {
        waitingView.isHidden = false
        resInfo.isHidden = false
        resInfo.image = #imageLiteral(resourceName: "paysuc")
        resInfo.alpha = 1.0
        UIView.animate(withDuration: 0.3, animations: {
            self.resInfo.alpha = 0.0
        }) { (Bool) in
            self.waitingView.isHidden = true
            self.resInfo.isHidden = true
            self.dismiss(animated: true, completion: {
                if self.delegate != nil {
                    self.delegate!.paySucAction()
                }
            })
        }
    }
    
}

protocol PaymentViewControllerDelegate {
    func paySucAction()
}
