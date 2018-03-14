//
//  HistoryImageViewController.swift
//  TestAlamofire
//
//  Created by l_yq on 2018/1/11.
//  Copyright © 2018年 l_yq. All rights reserved.
//

import UIKit

class HistoryImageViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout, UIGestureRecognizerDelegate {
    
    var fullScreenImage: UIImageView?
    var imageSet: [UIImage]?
    var saveInfo: UIImageView?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupUI()
    }
    
    func setupUI() {
        self.navigationItem.title = "History Album"
        navigationController?.navigationBar.tintColor = .black
        navigationController?.navigationBar.setBackgroundImage(#imageLiteral(resourceName: "Nav.bg"), for: .default)
        
        let leftBtn = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelAlbum))
        navigationItem.leftBarButtonItem = leftBtn
        
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
    
    @objc func hideFullScreenImage() {
        self.fullScreenImage?.alpha = 1.0
        UIView.animate(withDuration: 0.5, animations: {
            self.fullScreenImage?.alpha = 0.0
        }) { (Bool) in
            self.fullScreenImage?.isHidden = true
        }
    }
    
    @objc func cancelAlbum() {
        dismiss(animated: true, completion: nil)
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageSet?.count ?? 0
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let identify: String = "hid"
        
        let cell = (self.collectionView?.dequeueReusableCell(
            withReuseIdentifier: identify, for: indexPath))! as UICollectionViewCell
        // 从界面查找到控件元素并设置属性
        let imageview = (cell.contentView.viewWithTag(1) as! UIImageView)
        imageview.contentMode = .scaleAspectFill
        imageview.image = imageSet?[indexPath.row] ?? #imageLiteral(resourceName: "killua")
        
        return cell
    }
    
    @objc func showFullScreenImage(image: UIImage) {
        print("miao")
        self.fullScreenImage?.image = image
        self.fullScreenImage?.alpha = 0.0
        self.fullScreenImage?.isHidden = false
        UIView.animate(withDuration: 0.5, animations: {
            self.fullScreenImage?.alpha = 1.0
        })
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: (SCREEN_WIDTH - CGFloat(3)) / CGFloat(4), height: (SCREEN_WIDTH - CGFloat(3)) / CGFloat(4))
    }
    
    override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
        print(indexPath)
        let cell = collectionView.cellForItem(at: indexPath)
        let imageview = (cell?.contentView.viewWithTag(1) as! UIImageView)
        showFullScreenImage(image: imageview.image!)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
