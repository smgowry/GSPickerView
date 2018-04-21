//
//  GSPickerView.swift
//  GSPickerView
//
//  Created by Navaneethan Sammandhamoorthy on 4/21/18.
//  Copyright © 2018 Gowrie. All rights reserved.
//

import Foundation
import UIKit

@objc protocol GSPickerViewDelegate : class{
    func dismissPicker()
}

class GSPickerView: UIView{
    
    weak var delegate: GSPickerViewDelegate?
    
    var dataSourceArray: [[String:String]] = [[:]]
    var selectedIndex:Int = 0
    var selectedValue:String = ""
    var presentAddress:String?
    
    private var picker:UIPickerView?
    private var pickerView:UIView?
    private var parentView:UIView
    
    
    required init(viewController vc:UIViewController, dataSource:[[String:String]], presentValue:String?) {
        parentView = vc.view
        dataSourceArray = dataSource
        presentAddress = presentValue
        super.init(frame: .zero)
        configurePickerView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configurePickerView() {
        self.frame =  CGRect(x: 0, y: parentView.bounds.size.height-pickerViewConstant.pickerViewHeight, width: parentView.bounds.size.width, height: pickerViewConstant.pickerViewHeight)
        
        pickerView = self
        let toolBar = configurePickerToolBar()
        picker =  UIPickerView(frame: CGRect(x: 0, y: toolBar.frame.size.height, width: parentView.frame.size.width, height: pickerViewConstant.pickerViewHeight))
        
        picker?.backgroundColor = .white
        picker?.showsSelectionIndicator = true
        
        picker?.delegate = self
        picker?.dataSource = self
        
        pickerView?.addSubview(toolBar)
        pickerView?.addSubview(picker!)
        
        let trimmed = presentAddress?.replacingOccurrences(of: "\\s+$", with: "", options: .regularExpression)
        if let index = dataSourceArray.index(where: {$0[GSContact.tokenValue.rawValue] == trimmed}) {
            selectedIndex = index
            self.picker?.selectRow(index, inComponent: 0, animated: true)
        }
        parentView.addSubview(pickerView!)
    }
    
    //Picker view tool bar with previous, next and done bar button.
    func configurePickerToolBar() -> UIToolbar {
        let toolBar = UIToolbar()
        toolBar.barStyle = UIBarStyle.default
        toolBar.isTranslucent = true
        toolBar.tintColor = .lightGray
        toolBar.sizeToFit()
        
        let FixedSpaceBtn = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let FlexibleSpaceBtn = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(donePicker))
        
        let preBtn = configureButtonWithImage(left: true, title: "Prev", image: "rightArrow")
        preBtn.addTarget(self, action: #selector(scrollUpPicker), for: .touchUpInside)
        let previousBtn = UIBarButtonItem(customView: preBtn)
        
        let btn = configureButtonWithImage(left: false, title: "Next", image: "leftArrow")
        btn.addTarget(self, action: #selector(scrollDownPicker), for: .touchUpInside)
        let nextBtn = UIBarButtonItem(customView: btn)
        
        toolBar.setItems([previousBtn, FlexibleSpaceBtn, nextBtn, FixedSpaceBtn, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        return toolBar
    }
    
    /*
     //MARK: UIButton with image
     func configureButtonWithImage(left:Bool = false, title:String, image:String) -> UIButton {
     let button = UIButton(type: .roundedRect)
     let availableSpace = UIEdgeInsetsInsetRect(button.bounds, button.contentEdgeInsets)
     
     button.contentHorizontalAlignment = left ? .left : .right
     button.semanticContentAttribute = left ? .forceLeftToRight : .forceRightToLeft
     let imageEdgeInset:CGFloat = left ? button.imageEdgeInsets.left : button.imageEdgeInsets.right
     let availableWidth = availableSpace.width - imageEdgeInset - (button.imageView?.frame.width ?? 0) - (button.titleLabel?.frame.width ?? 0)
     
     let leftSpace = left ? availableWidth/2: 0.0
     let rightSpace = left ? 0.0: availableWidth/2
     button.titleEdgeInsets = UIEdgeInsets(top: 0, left: leftSpace, bottom: 0, right: rightSpace)
     
     button.setImage(UIImage(named: image), for: .normal)
     button.setTitle(title, for: .normal)
     
     button.sizeToFit()
     
     return button
     }
     */
    
    //MARK: UIButton with attributedText
    func configureButtonWithImage(left:Bool = false, title:String, image:String) -> UIButton {
        let button = UIButton(type: .roundedRect)
        let attributedString = NSMutableAttributedString()
        button.contentHorizontalAlignment = .center
        
        let attachment = NSTextAttachment()
        attachment.image = UIImage(named: image)
        let attachmentString:NSAttributedString = NSAttributedString(attachment: attachment)
        
        if left{
            attributedString.append(attachmentString)
            attributedString.append(NSAttributedString(string: " \(title)"))
        }else{
            attributedString.append(NSAttributedString(string: "\(title) "))
            attributedString.append(attachmentString)
        }
        
        button.setAttributedTitle(attributedString, for: .normal)
        button.sizeToFit()
        return button
    }
    
    
    //MARK: Picker Action
    func donePicker() {
        delegate?.dismissPicker()
        pickerView?.removeFromSuperview()
    }
    
    //Move scroll up by default
    func scrollUpPicker()  {
        let desiredRow = (selectedIndex != 0) ? selectedIndex-1 : 0
        self.picker?.selectRow(desiredRow, inComponent: 0, animated: true)
        selectedValue = dataSourceArray[desiredRow][GSContact.tokenValue.rawValue]!
        selectedIndex = desiredRow
    }
    
    //Move scroll down by default
    func scrollDownPicker()  {
        let desiredRow = (selectedIndex != dataSourceArray.count-1) ? selectedIndex+1 : dataSourceArray.count-1
        self.picker?.selectRow(desiredRow, inComponent: 0, animated: true)
        selectedValue = dataSourceArray[desiredRow][GSContact.tokenValue.rawValue]!
        selectedIndex = desiredRow
    }
}


//MARK:- PickerView Delegate & DataSource
extension GSPickerView: UIPickerViewDataSource, UIPickerViewDelegate {
    
    //DataSource
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return dataSourceArray.count
    }
    
    //Delegate
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return dataSourceArray[row][GSContact.tokenValue.rawValue]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedValue = dataSourceArray[row][GSContact.tokenValue.rawValue] ?? ""
        selectedIndex = row
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        
        var pickerLbl : UILabel
        if let label = view as? UILabel {
            pickerLbl = label
        } else {
            pickerLbl = UILabel()
            pickerLbl.textColor = UIColor.black
            pickerLbl.textAlignment = NSTextAlignment.center
        }
        pickerLbl.text = dataSourceArray[row][GSContact.tokenValue.rawValue]
        pickerLbl.sizeToFit()
        
        return pickerLbl
    }
    
}





