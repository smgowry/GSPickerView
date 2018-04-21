//
//  GSPickerViewController.swift
//  GSPickerView
//
//  Created by Gowrie Sammandhamoorthy on 4/21/18.
//  Copyright © 2018 Gowrie. All rights reserved.
//

import UIKit

struct pickerViewConstant {
    static let pickerViewHeight:CGFloat = 300.0
}

enum GSContact: String {
    case tokenValue
    case id
}


final class GSPickerViewController: UIViewController, GSPickerViewDelegate {
    
    @IBOutlet var tokenSelection: UILabel!
    @IBOutlet var touchView: UIView!
    
    var dataSourceArray:[[String:String]] = [[:]]
    var pickerView:GSPickerView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dataSourceArray = [[GSContact.tokenValue.rawValue:"vimal@gmail.com",
                            GSContact.id.rawValue:"4367573"],
                           [GSContact.tokenValue.rawValue:"(476) 444-4444",
                            GSContact.id.rawValue:"4567573"],
                           [GSContact.tokenValue.rawValue:"test@yahoo.com",
                            GSContact.id.rawValue:"4567353"]]
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(showPicker))
        touchView?.addGestureRecognizer(tap)
        tokenSelection?.text = dataSourceArray[0][GSContact.tokenValue.rawValue]
    }
    
    //Display picker when user taps sub view.
    func showPicker(sender:UITapGestureRecognizer){
        pickerView =  GSPickerView(viewController: self, dataSource:dataSourceArray, presentValue: tokenSelection?.text )
        pickerView?.delegate = self
    }
    
    //GSPickerViewDelegate methods
    func dismissPicker() {
        if let index = pickerView?.selectedIndex {
            tokenSelection.text = "\(dataSourceArray[index][GSContact.tokenValue.rawValue] ?? "") "
        }
    }
}
  
