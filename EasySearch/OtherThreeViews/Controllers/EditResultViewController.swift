//
//  EditResultViewController.swift
//  EasySearch
//
//  Created by l_yq on 2017/12/27.
//  Copyright © 2017年 l_yq. All rights reserved.
//

import UIKit
import Photos

class EditResultViewController: UIViewController, UIGestureRecognizerDelegate {
    
    var image: UIImage?
    
    var dismBtn: UIButton?
    
    var saveInfo: UIImageView?
    
    var delegate: EditResultViewControllerDelegate?
    

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        // Do any additional setup after loading the view.
    }
    
    func setupUI() {
        view.backgroundColor = .black
        
        guard image != nil else {
            print("image is nil.")
            return
        }
        
        let imageField = UIImageView(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: SCREEN_HEIGHT))
        imageField.contentMode = .scaleAspectFit
        imageField.image = image!
        self.view.addSubview(imageField)
        
        let imageWidth:CGFloat = 150.0
        saveInfo = UIImageView(frame: CGRect(x: SCREEN_WIDTH/2 - imageWidth/2, y: SCREEN_HEIGHT/2 - imageWidth/2, width: imageWidth, height: imageWidth))
        self.view.addSubview(saveInfo!)
        saveInfo?.isHidden = true
        
        longpressToSave(imageView: imageField)
        
        let gesture = UISwipeGestureRecognizer(target: self, action: #selector(popSelf))
        gesture.direction = .down
        imageField.addGestureRecognizer(gesture)
    }
    
    @objc func popSelf() {
        dismiss(animated: true) {
            if self.delegate != nil {
                self.delegate!.dismissAction()
            }
            DispatchQueue.global().async {
                if self.image != nil {
                    HistoryImageModel.insertImage(image: self.image!)
                }
            }
        }
    }
    
    func longpressToSave(imageView: UIImageView) {
        print("add gesture")
        let longpress = UILongPressGestureRecognizer.init(target: self, action: #selector(longpressAction))
        longpress.delegate = self
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(longpress)
        imageView.addGestureRecognizer(longpress)
    }
    
    @objc func longpressAction(longpress: UILongPressGestureRecognizer) {
        if longpress.state == UIGestureRecognizerState.began {
            print("long press")
            let alertViewController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            
            let saveAction = UIAlertAction(title: "Save to photos", style: .default, handler: { (UIAlertAction) in
                UIImageWriteToSavedPhotosAlbum(self.image!, self, #selector(self.saveAction(image:error:contextInfo:)), nil)
            })
            alertViewController.addAction(saveAction)
            let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
            alertViewController.addAction(cancelAction)
            
            self.present(alertViewController, animated: true, completion: nil)
        }
    }
    
    @objc func saveToPhotos() {
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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

@objc protocol EditResultViewControllerDelegate {
    func dismissAction()
}
