//
//  DrawView.swift
//  DrawTest
//
//  Created by l_yq on 2017/11/27.
//  Copyright © 2017年 linyiqun. All rights reserved.
//

import UIKit

class DrawView: UIView {

    var drawingView: QLDrawView!
    
    var emptyViewUp: UIView!
    var emptyViewDown: UIView!
    var emptyViewLeft: UIView!
    var emptyViewRight: UIView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setDrawingView(frame: CGRect) {
        drawingView = QLDrawView(frame: frame)
        emptyViewUp = UIView(frame: CGRect(x: 0, y: 0, width: bounds.size.width, height: frame.minY))
        emptyViewLeft = UIView(frame: CGRect(x: 0, y: frame.minY, width: frame.minX, height: frame.height))
        emptyViewRight = UIView(frame: CGRect(x: frame.maxX, y: frame.minY, width: bounds.size.width - frame.maxX, height: frame.height))
        emptyViewDown = UIView(frame: CGRect(x: 0, y: frame.maxY, width: bounds.size.width, height: bounds.size.height - frame.height))
        
        emptyViewLeft.backgroundColor = UIColor.white
        emptyViewRight.backgroundColor = UIColor.white
        emptyViewUp.backgroundColor = UIColor.white
        emptyViewDown.backgroundColor = UIColor.white
        
        self.insertSubview(drawingView, at: 0)
        self.insertSubview(emptyViewUp, at: 1)
        self.insertSubview(emptyViewDown, at: 1)
        self.insertSubview(emptyViewLeft, at: 1)
        self.insertSubview(emptyViewRight, at: 1)
    }
    
}
