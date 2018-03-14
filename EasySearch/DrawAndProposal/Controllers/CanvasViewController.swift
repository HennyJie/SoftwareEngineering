//
//  ViewController.swift
//  TestDesign
//
//  Created by l_yq on 2017/12/3.
//  Copyright © 2017年 linyiqun. All rights reserved.
//

import UIKit
import UICircularProgressRing

class CanvasViewController: UIViewController, UICircularProgressRingDelegate, FeatureMapDelegate {
    
    @IBOutlet weak var drawBtn: UIButton!
    @IBOutlet weak var eraserBtn: UIButton!
    var canvasView: DrawView!
    var waitingView: UIView!
    var ring: UICircularProgressRingView!
    
    var resultImageSet: [UIImage]?
    
//    var isAni:Bool = false
    
    var rtToStop: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        setupUI()
        
    }
    
    func setupUI() {
        navigationController?.navigationBar.setBackgroundImage(#imageLiteral(resourceName: "Nav.bg"), for: .default)
        navigationItem.title = "Draw it for search!"
        
        drawBtn.setImage(#imageLiteral(resourceName: "Draw_selected.draw"), for: .selected)
        eraserBtn.setImage(#imageLiteral(resourceName: "Draw_selected.eraser"), for: .selected)
        
        drawBtn.isSelected = true
        // set draw mode
        
        // canvas view
        canvasView = DrawView(frame: CGRect(x: 0, y: 0, width: view.bounds.size.width, height: view.bounds.size.height))
        canvasView.setDrawingView(frame: CGRect(x: 0, y: 64, width: view.bounds.size.width, height: view.bounds.height - (self.tabBarController?.tabBar.bounds.height)! - 64))
        canvasView.drawingView.drawMode = .draw
        canvasView.drawingView.backgroundColor = .white
        
        print((self.tabBarController?.tabBar.bounds.height)!)
        print((self.tabBarController?.tabBar.bounds.width)!)
        view.insertSubview(canvasView, at: 0)
        
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

    @IBAction func setDrawMode(_ sender: UIButton) {
        if !drawBtn.isSelected {
            drawBtn.isSelected = true
            eraserBtn.isSelected = false
            // set draw mode
            canvasView.drawingView.drawMode = .draw
        }
    }
    
    @IBAction func setEraserMode(_ sender: UIButton) {
        if !eraserBtn.isSelected {
            drawBtn.isSelected = false
            eraserBtn.isSelected = true
            // set eraser mode
            canvasView.drawingView.drawMode = .earse
        }
    }
    
    @IBAction func searchFor(_ sender: UIButton) {
        print("draw search......")
        
        waitingView.isHidden = false
//        self.ring.setProgress(value: 1, animationDuration: 0.1)
        
        // catch the canvas and search
        let drawImage: UIImage = canvasView.drawingView.screenShot()!
        
        
        // do something with draw image and search
        
        
        // Seaarch
        // ================================================================
        
        let featureMap = FeatureMap()
        featureMap.delegate = self

        rtToStop = false

        DispatchQueue.global().async {
            self.resultImageSet = featureMap.searchFromConvasImage(drawImage)

            DispatchQueue.main.async {
                // show ...

                if self.ring.value != 100 && !(self.rtToStop) {
                    self.ring.setProgress(value: 100, animationDuration: 1)
                }
                print("search finished, show the result. count: \(self.resultImageSet?.count ?? 0)")
            }
        }
        
        // ================================================================
        // END Search
        
    }
    
    @IBAction func clearCanvas(_ sender: UIButton) {
        print("clear canvas...")
        canvasView.drawingView.clearScreen()
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
    
    func showProposal() {
        let proposalController = ProposalViewController()
        proposalController.imgCnt = resultImageSet?.count ?? 0
        proposalController.imgSet = self.resultImageSet
        present(proposalController, animated: true, completion: nil)
        self.waitingView.isHidden = true
        self.waitingView.alpha = 1
        self.ring.setProgress(value: 0, animationDuration: 0)
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
    
}

