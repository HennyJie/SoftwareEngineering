//
//  ProposalViewController.swift
//  TestProposal
//
//  Created by l_yq on 2017/12/1.
//  Copyright © 2017年 linyiqun. All rights reserved.
//

import UIKit

// add a protocal, let last view to implement the 'return function'
let SCREEN_WIDTH = UIScreen.main.bounds.size.width
let SCREEN_HEIGHT = UIScreen.main.bounds.size.height

class ProposalViewController: UIViewController, FSPagerViewDataSource, FSPagerViewDelegate, UIGestureRecognizerDelegate {
    
    weak var delegate: ProposalViewControllerDelegate?
    
    let pagerViewHeight: CGFloat = SCREEN_HEIGHT * 0.85
    let pagerY: CGFloat = 30

    var testPagerView: FSPagerView!
    var pagerControl: FSPageControl!
    var returnBtn: UIButton!
    var selectBtn: UIButton!
    
    var imgCnt: Int = 0
    var imgSet: [UIImage]?
    var saveInfo: UIImageView?
    
    var fullScreenImage: UIImageView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        setupUI()
    }
    
    func setupUI() {

        // init and set frame
        testPagerView = FSPagerView(frame: CGRect(x: 0, y: pagerY, width: SCREEN_WIDTH, height: pagerViewHeight))
        
        // set transform type
        testPagerView.transformer = FSPagerViewTransformer(type: .overlap)
        
        // set frame size (cell)
        testPagerView.itemSize = testPagerView.frame.size.applying(CGAffineTransform(scaleX: 0.84, y: 0.84))
        
        // register cell
        testPagerView.register(FSPagerViewCell.self, forCellWithReuseIdentifier: "cell")
        
        // add delegate
        testPagerView.delegate = self
        testPagerView.dataSource = self
        
        // page control
        pagerControl = FSPageControl(frame: CGRect(x: 0, y: pagerViewHeight + pagerY - 35, width: SCREEN_WIDTH, height: 10))
        pagerControl.numberOfPages = imgCnt
        // set position
        pagerControl.contentHorizontalAlignment = .center
        pagerControl.contentInsets = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        // setStrokeColor
        // setFillColor
        // hide for single page
        // itemSpacing
        // interitemSpacing
        // for .normal/ selected
        
        
        // Buttons
        returnBtn = UIButton(type: .custom)// with a image
        returnBtn.frame = CGRect(x: 15, y: 27, width: 15, height: 15*1.74)
        returnBtn.addTarget(self, action: #selector(returnSearchResult), for: .touchUpInside)
        returnBtn.setImage(#imageLiteral(resourceName: "ReturnIcon"), for: .normal)
        
        selectBtn = UIButton(type: .custom)
        selectBtn.frame = CGRect(x: SCREEN_WIDTH / 2 - 40, y: pagerViewHeight + pagerY - 10, width: 80, height: 80/1.3944)
        selectBtn.setImage(#imageLiteral(resourceName: "OKCheck"), for: .normal)
        selectBtn.addTarget(self, action: #selector(selectImage), for: .touchUpInside)
        
        
        self.view.addSubview(testPagerView)
        self.view.addSubview(pagerControl)
        self.view.addSubview(selectBtn)
        self.view.addSubview(returnBtn)
        
        // BackGround Image
        let bgImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: SCREEN_HEIGHT))
        bgImageView.image = #imageLiteral(resourceName: "ProposalBg")
        self.view.insertSubview(bgImageView, at: 0)
        
        fullScreenImage = UIImageView(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: SCREEN_HEIGHT))
        self.view.addSubview(fullScreenImage!)
        fullScreenImage?.isHidden = true
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hideFullScreenImage))
        tapGesture.delegate = self
        fullScreenImage?.isUserInteractionEnabled = true
        fullScreenImage?.addGestureRecognizer(tapGesture)
        fullScreenImage?.contentMode = .scaleAspectFit
        fullScreenImage?.backgroundColor = .black
        
        let imageWidth:CGFloat = 150.0
        saveInfo = UIImageView(frame: CGRect(x: SCREEN_WIDTH/2 - imageWidth/2, y: SCREEN_HEIGHT/2 - imageWidth/2, width: imageWidth, height: imageWidth))
        self.view.addSubview(saveInfo!)
        saveInfo?.isHidden = true
        
        print("add gesture")
        let longpress = UILongPressGestureRecognizer.init(target: self, action: #selector(longpressAction))
        longpress.delegate = self
        fullScreenImage!.isUserInteractionEnabled = true
        fullScreenImage!.addGestureRecognizer(longpress)
        fullScreenImage!.addGestureRecognizer(longpress)
    }
    
    @objc func selectImage() {
        
        let alertController = UIAlertController(title: "You can find it in History Ablum.", message: nil, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true, completion: nil)
        
        DispatchQueue.global().async {
            if let image = self.imgSet?[self.pagerControl.currentPage] {
                HistoryImageModel.insertImage(image: image)
            } else {
                print("image is nil")
            }
        }
    }
    
    // MARK: delegate
    func numberOfItems(in pagerView: FSPagerView) -> Int {
        return imgCnt
    }
    
    public func pagerView(_ pagerView: FSPagerView, cellForItemAt index: Int) -> FSPagerViewCell {
        let cell = pagerView.dequeueReusableCell(withReuseIdentifier: "cell", at: index)
        
        // set image mode
//        cell.imageView?.image = index%2==0 ? #imageLiteral(resourceName: "Killua2") : #imageLiteral(resourceName: "Killua")
        cell.imageView?.image = imgSet?[index] ?? #imageLiteral(resourceName: "Killua")
        
        cell.imageView?.contentMode = .scaleAspectFill
        cell.imageView?.clipsToBounds = true
        // corner radius
        cell.imageView?.layer.cornerRadius = 5
        
        self.fullScreenImage?.image = #imageLiteral(resourceName: "Killua")
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(showFullScreenImage))
        tapGesture.delegate = self
        cell.addGestureRecognizer(tapGesture)
        
        return cell
    }
    
    func pagerView(_ pagerView: FSPagerView, didSelectItemAt index: Int) {
        pagerView.deselectItem(at: index, animated: true)
        pagerView.scrollToItem(at: index, animated: true)
        self.pagerControl.currentPage = index
    }
    
    func pagerViewDidScroll(_ pagerView: FSPagerView) {
        guard self.pagerControl.currentPage != pagerView.currentIndex else {
            return
        }
        self.pagerControl.currentPage = pagerView.currentIndex // Or Use KVO with property "currentIndex"
    }
    
    @objc func returnSearchResult() {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func showFullScreenImage() {
        self.fullScreenImage?.image = self.imgSet?[self.pagerControl.currentPage] ?? #imageLiteral(resourceName: "Killua")
        self.fullScreenImage?.alpha = 0.0
        self.fullScreenImage?.isHidden = false
        UIView.animate(withDuration: 0.5, animations: {
            self.fullScreenImage?.alpha = 1.0
        })
    }
    
    @objc func hideFullScreenImage() {
        self.fullScreenImage?.alpha = 1.0
        UIView.animate(withDuration: 0.5, animations: {
            self.fullScreenImage?.alpha = 0.0
        }) { (Bool) in
            self.fullScreenImage?.isHidden = true
        }
    }
    
    @objc func longpressAction(longpress: UILongPressGestureRecognizer) {
        if longpress.state == UIGestureRecognizerState.began {
            print("long press")
            let alertViewController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            
            let saveAction = UIAlertAction(title: "Save to photos", style: .default, handler: { (UIAlertAction) in
                UIImageWriteToSavedPhotosAlbum(self.fullScreenImage!.image!, self, #selector(self.saveAction(image:error:contextInfo:)), nil)
            })
            alertViewController.addAction(saveAction)
            let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
            alertViewController.addAction(cancelAction)
            
            self.present(alertViewController, animated: true, completion: nil)
        }
    }
    
    @objc func saveAction(image: UIImage, error: NSError?, contextInfo: Any) {
        if error != nil {
            saveInfo?.image = #imageLiteral(resourceName: "save.failed")
            print("SavingImage: \(error.debugDescription)")
        } else {
            saveInfo?.image = #imageLiteral(resourceName: "save.suc")
            print("SavingImage: saved successfully.")
        }
        
        saveInfo?.isHidden = false
        saveInfo?.alpha = 0.0
        
        UIView.animate(withDuration: 0.5, animations: {
            self.saveInfo?.alpha = 1.0
        }) { (Bool) in
            UIView.animate(withDuration: 2.0, animations: {
                self.saveInfo?.alpha = 0.0
            }, completion: { (Bool) in
                self.saveInfo?.isHidden = true
            })
        }
        
    }

}


@objc protocol ProposalViewControllerDelegate {
    func closeSearchResult() -> Void
}
