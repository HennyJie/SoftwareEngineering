//
//  UserSettingsViewController.swift
//  EasySearch
//
//  Created by l_yq on 2017/12/14.
//  Copyright © 2017年 l_yq. All rights reserved.
//

import UIKit

class UserSettingsViewController: UIViewController, RechargeViewDelegate, SettingViewDelegate, VipViewDelegate, AccountViewDelegate, PaymentViewControllerDelegate {
    
    
    
    
    // Image View from storyboard
    @IBOutlet weak var userPhoteImageViewField: UIImageView!
    var settingView: SettingView!
    var vipView: VipView!
    var accountView: AccountView!
    var rechargeView: RechargeView!
    // AccountView
    // VipView
    // RechargeView
    @IBOutlet weak var headpicField: UIView!
    
    @IBOutlet weak var vipIcon: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // if login?
        // set the labels and show ...
        // else hide the labels and buttons...
        // add the image view a action target to login
        // or add a 'login' button

        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let isLogin = UserDefaults.standard.bool(forKey: "isLogin")
        if !isLogin {
            settingView.logoutBtn.setTitle("Login  ", for: .normal)
            settingView.uname.text = "Name"
            settingView.uemail.text = "E-mail Address"
            self.userPhoteImageViewField.image = #imageLiteral(resourceName: "default.pic")
            self.vipIcon.isHidden = true
        } else {
            settingView.logoutBtn.setTitle("Logout", for: .normal)
            settingView.uname.text = UserDefaults.standard.object(forKey: "uname") as? String
            settingView.uemail.text = UserDefaults.standard.object(forKey: "uemail") as? String
            
            ApiCnfigModel().hasouCheckVIP(uemail: settingView.uemail.text!, complete: { (res, isVip, error) in
                if res {
                    self.vipIcon.isHidden = !isVip
                }
            })
            
            ApiCnfigModel().hasouGetPhoto(uemail: settingView.uemail.text!, complete: { (res, image, error) in
                if res {
                    self.userPhoteImageViewField.image = image
                } else {
                    print("Get Photo Error: res is false.")
                }
            })
        }
        
        showInfo()
    }
    
    func setupUI() {
        userPhoteImageViewField.layer.masksToBounds = true
        userPhoteImageViewField.layer.cornerRadius = userPhoteImageViewField.bounds.width / 2
        
        settingView = SettingView(frame: CGRect(x: 0, y: Int(headpicField.frame.maxY+20), width: Int(SCREEN_WIDTH), height: Int(SCREEN_HEIGHT)))
        vipView = VipView(frame: CGRect(x: 0, y: Int(headpicField.frame.maxY+20), width: Int(SCREEN_WIDTH), height: Int(SCREEN_HEIGHT)))
        accountView = AccountView(frame: CGRect(x: 0, y: Int(headpicField.frame.maxY+20), width: Int(SCREEN_WIDTH), height: Int(SCREEN_HEIGHT)))
        rechargeView = RechargeView(frame: CGRect(x: 0, y: Int(headpicField.frame.maxY+20), width: Int(SCREEN_WIDTH), height: Int(SCREEN_HEIGHT)))
        
        self.view.addSubview(settingView)
        self.view.addSubview(vipView)
        self.view.addSubview(accountView)
        self.view.addSubview(rechargeView)
        
        vipView.isHidden = true
        accountView.isHidden = true
        rechargeView.isHidden = true
        
        settingView.delegate = self
        vipView.delegate = self
        accountView.delegate = self
        rechargeView.delegate = self
        
        let rightSwipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(accountViewRightSwipe))
        rightSwipeGesture.direction = .right
        accountView.addGestureRecognizer(rightSwipeGesture)
    }
    
    func switchFrom(_ nowView: UIView, nextView: UIView, isPush: Bool){
        if nextView == rechargeView {
            rechargeView.resetView()
        }
        
        if nextView == accountView {
            accountView.resetView()
        }
        
        if isPush {
            nextView.center.x = SCREEN_WIDTH/CGFloat(2.0) + SCREEN_WIDTH
            nextView.isHidden = false
            nowView.alpha = 1.0
            nowView.alpha = 1.0
            
            UIView.animate(withDuration: 0.5, animations: {
                nextView.center.x -= SCREEN_WIDTH
                nowView.alpha = 0.0
            }) { (Bool) in
                nowView.isHidden = true
                nowView.alpha = 1.0
            }
        } else {
            nowView.center.x = SCREEN_WIDTH/CGFloat(2.0)
            nextView.isHidden = false
            nextView.alpha = 0.0
            
            UIView.animate(withDuration: 0.5, animations: {
                nowView.center.x += SCREEN_WIDTH
                nextView.alpha = 1.0
            }) { (Bool) in
                nowView.isHidden = true
            }
        }
    }
    
    @objc func accountViewRightSwipe() {
        print("swipe")
        switchFrom(accountView, nextView: settingView, isPush: false)
    }
    
    
    // need to login, hide the info
    func hideAll() {
    }
    
    func showInfo() {
    }
    
    // MARK: RechargeViewDelegate
    func confirmAction(amount: Double) {
        performSegue(withIdentifier: "topay", sender: rechargeView)
    }
    
    func dismissRechargeAction() {
        switchFrom(rechargeView, nextView: accountView, isPush: false)
        
        let uemail = UserDefaults.standard.object(forKey: "uemail") as? String
        ApiCnfigModel().hasouGetBalance(uemail: uemail ?? "Name", complete: { (res, balance, error) in
            if res {
                self.accountView.setAccount(balance: balance)
            } else {
                let alertController = UIAlertController(title: "Unknown Error", message: nil, preferredStyle: .alert)
                let cancelAction = UIAlertAction(title: "OK", style: .cancel, handler: { (UIAlertAction) in
                    self.accountViewRightSwipe()
                })
                alertController.addAction(cancelAction)
                self.present(alertController, animated: true, completion: nil)
            }
        })
    }
    
    // MARK: SettingViewDelegate
    func changePwdAction() {
        let isLogin = UserDefaults.standard.bool(forKey: "isLogin")
        if isLogin {
            performSegue(withIdentifier: "changePwd", sender: nil)
        } else {
            let alertController = UIAlertController(title: "Change Password", message: "Please login.", preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alertController.addAction(cancelAction)
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    func resetAction() {
//        UserDefaults.standard.removeObject(forKey: <#T##String#>)
        DispatchQueue.global().async {
            HistoryImageModel.clearImageTable()
        }
        
        let alertController = UIAlertController(title: "Reset", message: "Reset successfully.", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true, completion: nil)
        
//        let isLogin = UserDefaults.standard.bool(forKey: "isLogin")
//        if isLogin {
//            let alertController = UIAlertController(title: "Reset", message: "Reset successfully.", preferredStyle: .alert)
//            let cancelAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
//            alertController.addAction(cancelAction)
//            self.present(alertController, animated: true, completion: nil)
//        } else {
//            let alertController = UIAlertController(title: "Reset", message: "Please login.", preferredStyle: .alert)
//            let cancelAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
//            alertController.addAction(cancelAction)
//            self.present(alertController, animated: true, completion: nil)
//        }
    }
    
    func logoutAction() {
        let isLogin = UserDefaults.standard.bool(forKey: "isLogin")
        if isLogin {
            
            
            let alertController = UIAlertController(title: "Logout", message: "Are you sure to logout?", preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            let okAction = UIAlertAction(title: "Yes", style: .default, handler: { (UIAlertAction) in
                UserDefaults.standard.set(false, forKey: "isLogin")
                self.settingView.logoutBtn.setTitle("Login  ", for: .normal)
                self.settingView.uname.text = "Name"
                self.settingView.uemail.text = "E-mail Address"
                UserDefaults.standard.removeObject(forKey: "uname")
                UserDefaults.standard.removeObject(forKey: "uemail")
                UserDefaults.standard.removeObject(forKey: "upwd")
                self.userPhoteImageViewField.image = #imageLiteral(resourceName: "default.pic")
                self.vipIcon.isHidden = true
            })
            alertController.addAction(cancelAction)
            alertController.addAction(okAction)
            self.present(alertController, animated: true, completion: nil)

            // do something...
            // clear xxx
        } else {
            performSegue(withIdentifier: "settingToLogin", sender: nil)
        }
    }
    
    func accountAction() {
        let isLogin = UserDefaults.standard.bool(forKey: "isLogin")
        if isLogin {
            
            switchFrom(settingView, nextView: accountView, isPush: true)
            
            let uemail = UserDefaults.standard.object(forKey: "uemail") as? String
            ApiCnfigModel().hasouGetBalance(uemail: uemail ?? "Name", complete: { (res, balance, error) in
                if res {
                    self.accountView.setAccount(balance: balance)
                } else {
                    let alertController = UIAlertController(title: "Unknown Error", message: nil, preferredStyle: .alert)
                    let cancelAction = UIAlertAction(title: "OK", style: .cancel, handler: { (UIAlertAction) in
                        self.accountViewRightSwipe()
                    })
                    alertController.addAction(cancelAction)
                    self.present(alertController, animated: true, completion: nil)
                }
            })
            
            
        } else {
            let alertController = UIAlertController(title: "My Account", message: "Please login.", preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alertController.addAction(cancelAction)
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    // MARK: VipViewDelegate
    func buyAction() {
        print("buy now")
        performSegue(withIdentifier: "topay", sender: vipView)
    }
    
    func dismissVipAction() {
        switchFrom(vipView, nextView: accountView, isPush: false)
        
        let uemail = UserDefaults.standard.object(forKey: "uemail") as? String
        ApiCnfigModel().hasouGetBalance(uemail: uemail ?? "Name", complete: { (res, balance, error) in
            if res {
                self.accountView.setAccount(balance: balance)
            } else {
                let alertController = UIAlertController(title: "Unknown Error", message: nil, preferredStyle: .alert)
                let cancelAction = UIAlertAction(title: "OK", style: .cancel, handler: { (UIAlertAction) in
                    self.accountViewRightSwipe()
                })
                alertController.addAction(cancelAction)
                self.present(alertController, animated: true, completion: nil)
            }
        })
    }
    
    // MARK: AccountViewDelegate
    func rechargeAction() {
        switchFrom(accountView, nextView: rechargeView, isPush: true)
    }
    
    func vipAction() {
        switchFrom(accountView, nextView: vipView, isPush: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "topay" {
            print("topay")
            if sender == nil {
                return
            }
            var orderinfo: String = ""
            var paybyinfo: String = ""
            var amount: Double = 0.0
            if let viewSender: UIView = sender as? UIView {
                switch(viewSender) {
                case rechargeView:
                    orderinfo = "AdvIm Recharge order"
                    paybyinfo = "Alipay"
                    amount = Double(rechargeView.recaInput.text!) ?? 0.0
                case vipView:
                    orderinfo = "AdvIm VIP order"
                    paybyinfo = "Account balance"
                    amount = 9.9
                default:
                    break
                }
            }
            if let viewController: PaymentViewController = segue.destination as? PaymentViewController {
                viewController.delegate = self
                viewController.orderInfo = orderinfo
                viewController.paybyInfo = paybyinfo
                viewController.amount = amount
            }
        } else {
            print("not a tailer")
        }
    }
    
    func paySucAction() {
        let isLogin = UserDefaults.standard.bool(forKey: "isLogin")
        if !isLogin {
            settingView.logoutBtn.setTitle("Login  ", for: .normal)
            settingView.uname.text = "Name"
            settingView.uemail.text = "E-mail Address"
            self.userPhoteImageViewField.image = #imageLiteral(resourceName: "default.pic")
            self.vipIcon.isHidden = true
        } else {
            settingView.logoutBtn.setTitle("Logout", for: .normal)
            settingView.uname.text = UserDefaults.standard.object(forKey: "uname") as? String
            settingView.uemail.text = UserDefaults.standard.object(forKey: "uemail") as? String
            
            ApiCnfigModel().hasouCheckVIP(uemail: settingView.uemail.text!, complete: { (res, isVip, error) in
                if res {
                    self.vipIcon.isHidden = !isVip
                }
            })
        }
    }
}
