//
//  ESTabBarController.swift
//  TestDesign
//
//  Created by l_yq on 2017/12/3.
//  Copyright © 2017年 linyiqun. All rights reserved.
//

import UIKit

class ESTabBarController: UITabBarController, UITabBarControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.addCenterButton(btnimage: #imageLiteral(resourceName: "Photo.icon"), view: self.view)
        self.tabBar.backgroundImage = #imageLiteral(resourceName: "Bar.bg")
        self.tabBar.contentMode = .scaleAspectFill
        
        self.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    //参数说明
    //btnimage 按钮图片
    //selectedbtnimg 点击时图片
    //selector 按钮方法名称
    //view 按钮添加到view  正常是 self.view就可以
    func addCenterButton(btnimage buttonImage:UIImage, view:UIView)
    {
        //创建一个自定义按钮
        let button:UIButton = UIButton(type: .system)
        //btn.autoresizingMask
        //button大小为适应图片
        button.frame = CGRect(x: 0, y: 0, width: buttonImage.size.width, height: buttonImage.size.height)
//        button.setImage(buttonImage, for: UIControlState.normal)
        button.setBackgroundImage(buttonImage, for: .normal)
        //去掉阴影
        button.adjustsImageWhenDisabled = true;
        //按钮的代理方法
        button.addTarget( self, action: #selector(addOrderView), for: UIControlEvents.touchUpInside )
        //高度差
        let heightDifference:CGFloat = buttonImage.size.height - self.tabBar.frame.size.height
        if (heightDifference < 0){
            button.center = self.tabBar.center;
        }
        else
        {
            var center:CGPoint = self.tabBar.center;
            center.y = center.y - heightDifference/2.0;
            button.center = center;
        }
        view.addSubview(button);
    }
    
    
    //按钮方法
    @objc func addOrderView()
    {
        print("photo")
        performSegue(withIdentifier: "col", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        print("miao")
        if segue.identifier == "col" {
            if let viewController: UINavigationController = segue.destination as? UINavigationController {
                if let controller: HistoryImageViewController =  viewController.topViewController as? HistoryImageViewController {
                    print("Segue: Load History Table")
                    controller.imageSet = HistoryImageModel.loadHistoryTable()
                }
            }
        } else {
            print("not a col")
        }
    }
    
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        NSLog("tabbar item 被点击")
        switch item.tag{
        case 0:
            //是退出按钮
            self.dismiss(animated: true, completion: nil)
        case 1:
            print("点击图表1")
        case 2:
            print("点击图表2")
        case 3:
            print("点击图表3")
        case 4:
            print("点击图表4")
        default:
            print("未知按钮")
        }
    }
    
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        print("miao~miao~")
        
        if selectedViewController == nil || viewController == selectedViewController {
            return false
        }
        
        let fromView = selectedViewController!.view
        let toView = viewController.view
        
        UIView.transition(from: fromView!, to: toView!, duration: 0.3, options: [.transitionCrossDissolve], completion: nil)
        
        return true
    }
}
