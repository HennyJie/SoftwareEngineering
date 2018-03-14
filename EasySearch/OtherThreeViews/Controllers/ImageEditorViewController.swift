//
//  ImageEditorViewController.swift
//  EasySearch
//
//  Created by l_yq on 2017/12/14.
//  Copyright © 2017年 l_yq. All rights reserved.
//

import UIKit
import Photos
import SVProgressHUD
import UICircularProgressRing

class ImageEditorViewController: UIViewController, EditResultViewControllerDelegate, TailerResultViewControllerDelegate, UICircularProgressRingDelegate, FeatureMapDelegate {
    
//    var resultTailedImage: UIImage!
    
    var labelImageField: UIImageView!
    @IBOutlet weak var backgroundImageField: UIImageView!
    
    @IBOutlet weak var dFogBtn: UIButton!
    @IBOutlet weak var liBtn: UIButton!
    @IBOutlet weak var rmBlurBtn: UIButton!
    @IBOutlet weak var tailerBtn: UIButton!
    
    var bgWaitingView: UIView!
    
    var btn: [UIButton]?
    let bgSet: [UIImage] = [#imageLiteral(resourceName: "dfog.bg"), #imageLiteral(resourceName: "lighting.bg"), #imageLiteral(resourceName: "rmblur.bg"), #imageLiteral(resourceName: "tailor.bg")]
    
    var nowSelected: Int = 3
    let scaleRatio: CGFloat = 1.5
    
    var isAni: Bool = false
    
    var resultImage: UIImage?
    var tipInfo: UIImageView!
    
    
    var waitingView: UIView!
    var ring: UICircularProgressRingView!
    
    var resultImageSet: [UIImage]?
    
    var rtToStop: Bool = false
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        // Do any additional setup after loading the view.
    }
    
    func setupUI() {
        navigationController?.navigationBar.setBackgroundImage(#imageLiteral(resourceName: "Nav.bg"), for: .default)
        tailerBtn.transform = CGAffineTransform(scaleX: scaleRatio, y: scaleRatio)
        btn = [dFogBtn, liBtn, rmBlurBtn, tailerBtn]
        
        labelImageField = UIImageView(frame: CGRect(x: 0, y: 64 + 70, width: SCREEN_WIDTH, height: SCREEN_WIDTH / 2))
        labelImageField.image = bgSet[nowSelected]
        backgroundImageField.image = #imageLiteral(resourceName: "Edit.bg")
        view.addSubview(labelImageField)
        
        bgWaitingView = UIView(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: SCREEN_HEIGHT))
        bgWaitingView.backgroundColor = UIColor(displayP3Red: 0, green: 0, blue: 0, alpha: 0.5);
        self.tabBarController?.view.addSubview(self.bgWaitingView)
        bgWaitingView.isHidden = true
        tipInfo = UIImageView(frame: CGRect(x: Int(SCREEN_WIDTH)/2-217/2, y: Int(SCREEN_HEIGHT) - 100, width: 217, height: 44))
        tipInfo.image = #imageLiteral(resourceName: "tipinfo.savesuc")
        tipInfo.isHidden = true
        view.addSubview(tipInfo)
        
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
    }
    
    func getUIImage(asset: PHAsset) -> UIImage? {
        
        var img: UIImage?
        let manager = PHImageManager.default()
        let options = PHImageRequestOptions()
        options.version = .original
        options.isSynchronous = true
        manager.requestImageData(for: asset, options: options) { data, _, _, _ in
            
            if let data = data {
                img = UIImage(data: data)
            }
        }
        return img
    }
    
    func tailerFromAlbum() {
        
        print("select photos")
        
        // 限制选取的图片的数量
        _ = self.presentHGImagePicker(maxSelected: 10) { (assets) in
            // 结果处理
            // 开始调用接口进行拼接
            // ...
            
            SVProgressHUD.show()
            self.bgWaitingView.isHidden = false
            
            DispatchQueue.global().async {
                var imageArray: [UIImage] = []

                print("共选择了\(assets.count)张图片，分别如下：")
                for asset in assets {
                    imageArray.append(self.getUIImage(asset: asset)!)
                }

                // 拼接后的图片
                //            self.resultTailedImage = OpenCVWrapper.tailerImage(imageArray)!
                self.resultImage = ImageProcModel().cvTailor(imageArray)

                DispatchQueue.main.async {
                    SVProgressHUD.dismiss()
                    self.bgWaitingView.isHidden = true
                    self.performSegue(withIdentifier: "tailer", sender: self)
                }
            }
        }
    }
    
    func lightFromAblum() {
        print("select photos")
        
        _ = self.presentHGImagePicker(maxSelected:1) { (assets) in
            // 结果处理
            // 开始调用接口进行拼接
            // ...
            
            var image: UIImage? = nil
            
            print("共选择了\(assets.count)张图片，分别如下：")
            for asset in assets {
                image = self.getUIImage(asset: asset)
                print(image?.size ?? "image is nil")
            }
            
            if image != nil {
                
                SVProgressHUD.show()
                
                self.bgWaitingView.isHidden = false
                
                DispatchQueue.global().async {
                    image = image?.fixOrientation()
                    self.resultImage = ImageProcModel().cvLighting(image!)

                    let imageController = EditResultViewController()

                    DispatchQueue.main.async {
                        SVProgressHUD.dismiss()
                        self.bgWaitingView.isHidden = true
                        imageController.image = self.resultImage
                        imageController.delegate = self
                        self.present(imageController, animated: true, completion: nil)
                    }
                }
                
                
            } else {
                print("Lighting: image is nil.")
                return
            }
        }
        
    }
    
    func defoggingFromAlbum() {
        print("select photos")
        
        _ = self.presentHGImagePicker(maxSelected:1) { (assets) in
            // 结果处理
            // 开始调用接口进行拼接
            // ...
            
            var image: UIImage? = nil
            
            print("共选择了\(assets.count)张图片，分别如下：")
            for asset in assets {
                image = self.getUIImage(asset: asset)
                print(image?.size ?? "image is nil")
            }
            
            if image != nil {
                
                SVProgressHUD.show()
                self.bgWaitingView.isHidden = false
                
                DispatchQueue.global().async {
                    image = image?.fixOrientation()
                    self.resultImage = ImageProcModel().cvDefog(image!)

                    let imageController = EditResultViewController()

                    DispatchQueue.main.async {
                        SVProgressHUD.dismiss()
                        self.bgWaitingView.isHidden = true
                        
                        imageController.image = self.resultImage
                        imageController.delegate = self
                        self.present(imageController, animated: true, completion: nil)
                    }
                }
                
            } else {
                print("Defog: image is nil.")
                return
            }
        }
    }
    
    func siftsearchFromAlbum() {
        print("select photos")

        _ = self.presentHGImagePicker(maxSelected:1) { (assets) in
            // 结果处理
            // 开始调用接口进行拼接
            // ...
            
            var image: UIImage? = nil
            
            print("共选择了\(assets.count)张图片，分别如下：")
            for asset in assets {
                image = self.getUIImage(asset: asset)
                print(image?.size ?? "image is nil")
            }
            
            if image != nil {
                self.searchFromDescription(image: image!)
            } else {
                print("sift search: image is nil.")
                return
            }
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        print("miao prepare")
        
        if segue.identifier == "tailer" {
            print("a tailer")
            if let viewController: TailerResultViewController = segue.destination as? TailerResultViewController {
                viewController.resultImage = self.resultImage
                viewController.delegate = self
            }
        } else {
            print("not a tailer")
        }
    }
    
    
    
    // MARK: Action
    // Note(solved): there is a BUG: when the animation is perform, the button should be disabled
    @IBAction func clickEditBtn(_ sender: UIButton) {
        
        if isAni {
            return
        }
        
        // lock this function
        isAni = true
        
        print("now selected btn's tag is \(nowSelected)")
        print("now click \(sender.tag)")
        
        if nowSelected == sender.tag { // open the album
            print("do something with the ... method")
            // Note: asyn op
            if nowSelected == 3 { // "tailor"
                print("EDITOR VIEW: tailor")
                tailerFromAlbum()
            } else if nowSelected == 0 { // "defogging"
                print("EDITOR VIEW: defog")
                defoggingFromAlbum()
            } else if nowSelected == 1 { // "lighting"
                print("EDITOR VIEW: lighting")
                lightFromAblum()
            } else if nowSelected == 2 { // "rm blur"
                siftsearchFromAlbum()
            }
            isAni = false
            return
        }
        
        
        
        // times of animation to perform
        let dp = (self.nowSelected - sender.tag + 4) % 4
        
        let dpa = [0.3, 0.3, 0.3]
        // adjust animation duration time
        let dt = dpa[dp - 1]
        
        // the size of center btn(now selected)
        let tmpScale = btn![nowSelected].bounds.size
        
        // transfrom ratio ( > 1.0 )
        let scaleTransRatio = scaleRatio
        
        // the scale = 1 means that trans to its original size
        let rscaleTransRatio = CGFloat(1)
        
        // move to next pos
        func anim() {
            let centerSet = [btn![0].center,btn![1].center,btn![2].center,btn![3].center]
            for i in 0...3 {
                btn![i].center = centerSet[(i+1)%4]
            }
        }
        
        UIView.animate(withDuration: 0.45, animations: {
            self.labelImageField.alpha = 0
        }) { (Bool) in
            self.labelImageField.image = self.bgSet[sender.tag]
            UIView.animate(withDuration: 0.45, animations: {
                self.labelImageField.alpha = 1
            })
        }
        
        
        // animations
        UIView.animate(withDuration: 0.3, animations: {
            // narrow the selected button
            self.btn![self.nowSelected].transform = CGAffineTransform(scaleX: rscaleTransRatio, y: rscaleTransRatio)
        }) { (Bool) in
            // after that, move
            UIView.animate(withDuration: dt, animations: anim) { (Bool) in
                
                if(dp == 1) {
                    // move once, and enlarge the new selected button
                    print("anim finish")
                    self.nowSelected = sender.tag
//                    self.labelImageField.image = self.bgSet[self.nowSelected]
                    
                    UIView.animate(withDuration: 0.3, animations: {
                        print(sender.tag)
                        self.btn![sender.tag].transform = CGAffineTransform(scaleX: scaleTransRatio, y: scaleTransRatio)
                    }){ (Bool) in
                        self.isAni = false
                    }
                    
                    return
                }
                
                // move ... (same...)
                UIView.animate(withDuration: dt, animations: anim) { (Bool) in
                    if(dp == 2) {
                        print("anim finish")
                        self.nowSelected = sender.tag
//                        self.labelImageField.image = self.bgSet[self.nowSelected]
                        
                        UIView.animate(withDuration: 0.3, animations: {
                            print(sender.tag)
                            self.btn![sender.tag].transform = CGAffineTransform(scaleX: scaleTransRatio, y: scaleTransRatio)
                        }){ (Bool) in
                            self.isAni = false
                        }
                        
                        return
                    }
                    
                    UIView.animate(withDuration: dt, animations: anim) { (Bool) in
                        print("anim finish")
                        self.nowSelected = sender.tag
//                        self.labelImageField.image = self.bgSet[self.nowSelected]
                        
                        UIView.animate(withDuration: 0.3, animations: {
                            self.btn![sender.tag].transform = CGAffineTransform(scaleX: scaleTransRatio, y: scaleTransRatio)
                        }){ (Bool) in
                            self.isAni = false
                        }
                        
                    }
                }
            }
        }
    }
    
    func dismissAction() {
        tipInfo.center.y += 20
        tipInfo.isHidden = false
        UIView.animate(withDuration: 0.3, animations: {
            self.tipInfo.center.y -= 20
        }) { (Bool) in
            UIView.animate(withDuration: 0.5, animations: {
                self.tipInfo.alpha = 0.0
            }, completion: { (Bool) in
                self.tipInfo.isHidden = true
                self.tipInfo.alpha = 1.0
            })
        }
    }
    
    // MARK: delegate
    // when the ring finished, call this function
    func finishedUpdatingProgress(forRing ring: UICircularProgressRingView) {
        //        isAni = false
        
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
    
    // MARK: FeatureMapDelegate
    func progressOfSearch(now: Int, total: Int) {
        if self.ring.isAnimating == false {
            self.ring.setProgress(value: CGFloat(100 * now / total), animationDuration: 0.1)
        }
    }
    
    func isStopped() -> Bool {
        return rtToStop
    }
    
    func showProposal() {
        let proposalController = ProposalViewController()
        proposalController.imgCnt = resultImageSet?.count ?? 0
        proposalController.imgSet = self.resultImageSet
        present(proposalController, animated: true, completion: nil)
        self.waitingView.isHidden = true
        self.waitingView.alpha = 1
        self.ring.setProgress(value: 0, animationDuration: 0)
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
    
}
