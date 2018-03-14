//
//  OCRSearchViewController.swift
//  EasySearch
//
//  Created by l_yq on 2017/12/14.
//  Copyright © 2017年 l_yq. All rights reserved.
//

import UIKit
import UICircularProgressRing
import TesseractOCR
import SVProgressHUD

class OCRSearchViewController: UIViewController, UITextFieldDelegate, UICircularProgressRingDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate , UIGestureRecognizerDelegate, OCRModelDelegate, FeatureMapDelegate {
    
    
    @IBOutlet weak var searchTextField: UITextField!
    var loginSkip: Bool = false
    
    var waitingView: UIView!
    var ring: UICircularProgressRingView!
    var resultImageSet: [UIImage]?
    
    var isAni:Bool = false
    
    var rtToStop: Bool = false
    
    var waitingView2: UIView!
    var queryFailed: Bool = false
    var setImageNowIndex: Int = 1
    @IBOutlet weak var desSearch: UISwitch!
    @IBOutlet weak var queryResult: UIView!
    @IBOutlet weak var imageView1: UIImageView!
    @IBOutlet weak var imageView2: UIImageView!
    @IBOutlet weak var imageView3: UIImageView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    func setupUI() {
        searchTextField.delegate = self
        
        // init waitting view
        // ring view
        ring = UICircularProgressRingView(frame: CGRect(x: SCREEN_WIDTH/2 - 90, y: SCREEN_HEIGHT/2 - 90, width: 180, height: 180))
        ring.delegate = self
        ring.viewStyle = 4
        ring.fontColor = UIColor.white
        ring.innerRingColor = UIColor(displayP3Red: 168/255, green: 222/255, blue: 228/255, alpha: 1)
        ring.outerRingColor = UIColor(displayP3Red: 168/255, green: 222/255, blue: 228/255, alpha: 1)
        ring.font = UIFont.systemFont(ofSize: 50)
        ring.innerRingWidth = 10
        ring.outerRingWidth = 10
        
        let returnBtn = UIButton(type: .custom)// with a image
        returnBtn.frame = CGRect(x: 15, y: 27, width: 15, height: 15*1.74)
        returnBtn.addTarget(self, action: #selector(removeWaitingView), for: .touchUpInside)
        returnBtn.setImage(#imageLiteral(resourceName: "ReturnIcon"), for: .normal)
        
        // waiting view
        waitingView = UIView(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: SCREEN_HEIGHT))
        waitingView.backgroundColor = UIColor(displayP3Red: 0, green: 0, blue: 0, alpha: 0.5);
        waitingView.addSubview(returnBtn)
        waitingView.addSubview(ring)
        self.tabBarController?.view.addSubview(self.waitingView)
        waitingView.isHidden = true
        
        waitingView2 = UIView(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: SCREEN_HEIGHT))
        waitingView2.backgroundColor = UIColor(displayP3Red: 0, green: 0, blue: 0, alpha: 0.5);
        self.tabBarController?.view.addSubview(self.waitingView2)
        waitingView2.isHidden = true
        queryResult.layer.masksToBounds = true
        queryResult.layer.cornerRadius = 10.0
        queryResult.isHidden = true
        
        let gesture = UISwipeGestureRecognizer(target: self, action: #selector(dismissProposalView))
        gesture.direction = .down
        queryResult.addGestureRecognizer(gesture)
        
        imageView1.isUserInteractionEnabled = true
        imageView2.isUserInteractionEnabled = true
        imageView3.isUserInteractionEnabled = true
        
        imageView1.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(selectImage1)))
        imageView2.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(selectImage2)))
        imageView3.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(selectImage3)))
        
        
        
    }
    
    @objc func selectImage1() {
        if let image = imageView1.image {
            searchFromDescription(image: image)
        }
    }
    
    @objc func selectImage2() {
        if let image = imageView2.image {
            searchFromDescription(image: image)
        }
    }
    
    @objc func selectImage3() {
        if let image = imageView3.image {
            searchFromDescription(image: image)
        }
    }
    
    func searchFromDescription(image: UIImage) {
        var newImage: UIImage = image
        
        let areaOfImage:Double = Double(image.size.width * image.size.height)
        if areaOfImage > (500*500) {
            let ratio = sqrt(areaOfImage / (500.0*500.0))
            newImage = image.scaleImage(scaleSize: CGFloat(1.0/ratio))
            print(newImage.size)
        }
        
        waitingView.isHidden = false
        let featureMap = FeatureMap()
        featureMap.delegate = self
        
        rtToStop = false
        
        DispatchQueue.global().async {
            self.resultImageSet = featureMap.searchFromConvasImage(newImage)
            
            DispatchQueue.main.async {
                // show ...
                
                if self.ring.value != 100 && !(self.rtToStop) {
                    self.ring.setProgress(value: 100, animationDuration: 1)
                }
                print("search finished, show the result. count: \(self.resultImageSet?.count ?? 0)")
            }
        }
    }
    
    @objc func dismissProposalView() {
        self.queryResult.alpha = 1.0
        self.queryResult.isHidden = false
        UIView.animate(withDuration: 0.3, animations: {
            self.queryResult.alpha = 0.0
            self.queryResult.center.y += 30
        }) { (Bool) in
            self.queryResult.isHidden = true
            self.queryResult.center.y -= 30
        }
    }
    
    // MARK: UITextFieldDelegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // Hide the keyboard.
        
        
        
        if desSearch.isOn {
            self.view.endEditing(true)
            waitingView2.isHidden = false
            SVProgressHUD.show()
            
            setImageNowIndex = 1
            imageView1.image = nil
            imageView2.image = nil
            imageView3.image = nil
            
            ApiCnfigModel().hasouQueryImage(word: searchTextField.text!) { (image, res, res2, error) in
                if !res {
                    print("unhandled error")
                    if self.queryFailed == false {
                        self.queryFailed = true
                        // alert
                    }
                    // alert
                    SVProgressHUD.dismiss()
                    self.waitingView2.isHidden = true
                    let alertController = UIAlertController(title: "Connect Error", message: nil, preferredStyle: .alert)
                    let cancelAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                    alertController.addAction(cancelAction)
                    self.present(alertController, animated: true, completion: nil)
                    
                } else {
                    if res2  {
                        print("get image")
                        let index = self.setImageNowIndex
                        self.setImageNowIndex += 1
                        if index == 1 {
                            self.imageView1.image = image!
                        } else if index == 2 {
                            self.imageView2.image = image!
                        } else if index == 3 {
                            SVProgressHUD.dismiss()
                            self.waitingView2.isHidden = true
                            self.imageView3.image = image!
                            self.queryResult.alpha = 0.0
                            self.queryResult.isHidden = false
                            self.queryResult.center.y += 30
                            
                            UIView.animate(withDuration: 0.3, animations: {
                                self.queryResult.alpha = 1.0
                                self.queryResult.center.y -= 30
                            })
                        }
                    } else {
                        if self.queryFailed == false {
                            SVProgressHUD.dismiss()
                            self.waitingView2.isHidden = true
                            self.queryFailed = true
                            // alert
                            let alertController = UIAlertController(title: "Connect Error", message: nil, preferredStyle: .alert)
                            let cancelAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                            alertController.addAction(cancelAction)
                            self.present(alertController, animated: true, completion: nil)
                        }
                        print("image missing")
                    }
                }
            }
            return false
        }
        
        guard searchTextField.text != "" else {
            self.view.endEditing(true)
            print("search content is empty.")
            return true
        }
        
        print("ocr searching.....")
        self.view.endEditing(true)
        waitingView.isHidden = false
//        self.ring.setProgress(value: 100, animationDuration: 2)
        
        
        
        // Seaarch
        // ================================================================
        
        
        let ocrModel = OCRModel()
        ocrModel.delegate = self
        rtToStop = false

        DispatchQueue.global().async {

            // self.result = ...
            // delegate ...
            self.resultImageSet = ocrModel.searchFromTheAlbum(self.searchTextField.text!)

            DispatchQueue.main.async {
                // show ...
                
                if self.ring.value != 100 && !(self.rtToStop) {
                    self.ring.setProgress(value: 100, animationDuration: 1)
                }
                print("search finished, show the result.")
            }
        }
        
        
        
        // ================================================================
        // END Search
        
        return true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if !loginSkip {
            loginSkip = true
            guard UserDefaults.standard.bool(forKey: "isLogin") else {
                self.performSegue(withIdentifier: "login", sender: nil)
                return
            }
        }
    }
    
    @objc func removeWaitingView() {
        rtToStop = true
        func anim(){
            waitingView.alpha = 0
        }
        UIView.animate(withDuration: 1, animations: anim, completion: { (Bool) -> Void in
            self.waitingView.isHidden = true
            self.waitingView.alpha = 1
            self.ring.setProgress(value: 0, animationDuration: 0)
            
        })
        
    }
    
    
    // MARK: UICircleProgressRingDelegate
    func finishedUpdatingProgress(forRing ring: UICircularProgressRingView) {
        isAni = false
        
        if ring.currentValue == 100 {
            print("ring 100% finished.")
            let proposalController = ProposalViewController()
            proposalController.imgCnt = self.resultImageSet?.count ?? 0
            proposalController.imgSet = self.resultImageSet
            present(proposalController, animated: true, completion: nil)
            self.waitingView.isHidden = true
            self.waitingView.alpha = 1
            self.ring.setProgress(value: 0, animationDuration: 0)
        }
    }
    
    // MARK: OCRModelDelegate
    func progressOfSearch(now: Int, total: Int) {
        if !isAni {
            isAni = true
            self.ring.setProgress(value: CGFloat(100 * now / total), animationDuration: 0.2)
        }
    }
    
    func isStopped() -> Bool {
        return rtToStop
    }
    
}
