//
//  ImageCodeModel.swift
//  EasySearch
//
//  Created by l_yq on 2017/12/24.
//  Copyright © 2017年 l_yq. All rights reserved.
//

import UIKit

class ImageCodeModel: NSObject {
    
    var resTable: [ImageCode]?
    
    func loadTable() {
        print("IMAGE CODE MODEL: load table ...")
        let data = UserDefaults.standard.data(forKey: "image-code-table")
        
        guard data != nil else {
            print("IMAGE CODE MODEL: guard: table is nil")
            return
        }
        
        resTable = NSKeyedUnarchiver.unarchiveObject(with: data!) as? [ImageCode]
        print("IMAGE CODE MODEL: table is not nil, load table suc")
    }
    
    func saveTable() {
        print("IMAGE CODE MODEL: save table ...")
        
        guard resTable != nil else {
            print("IMAGE CODE MODEL: table is nil, save table failed.")
            return
        }
        
        let data:Data = NSKeyedArchiver.archivedData(withRootObject: resTable!)
        UserDefaults.standard.setValue(data, forKey: "image-code-table")
        
        print("IMAGE CODE MODEL: save table suc.")
    }
    
    func search(code: Int64) -> ImageCode? {
        print("IMAGE CODE MODEL: image code search from the table.")
        
        guard resTable != nil else {
            print("IMAGE CODE MODEL: guard: table is nil")
            return nil
        }
        
        print("IMAGE CODE MODEL: table is loaded, begin search...")
        let table = resTable!
        
        for item in table {
            if item.code == code {
                print("IMAGE CODE MODEL: find code \(code)")
                return item
            }
        }
        
        print("IMAGE CODE MODEL: can't find code \(code)")
        
        return nil
    }
    
    func insert(code: ImageCode) {
        print("IMAGE CODE MODEL: image code insert.")
        
        if self.search(code: code.code) != nil {
            print("IMAGE CODE MODEL: this code exists in this table. insert code failed")
            return
        }
        
        guard resTable != nil else {
            print("IMAGE CODE MODEL: table is nil, create a empty table and insert.")
            resTable = [code]
            print("IMAGE CODE MODEL: table count: \(resTable!.count)")
            return
        }
        
        resTable?.append(code)
        print("IMAGE CODE MODEL: insert suc, table count: \(resTable!.count)")
    }
    
}
