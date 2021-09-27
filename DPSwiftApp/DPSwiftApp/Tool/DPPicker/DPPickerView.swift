//
//  DPPickerView.swift
//  DPSwiftApp
//
//  Created by developeng on 2021/9/2.
//

import UIKit

fileprivate var DatePickerH:CGFloat = 270

typealias DoneBlock = ((_ dataStr:String) -> ())

class DPPickerView: UIView {
    
    var dataArray = [String]()
    private var dateComponentOrder = [String]()
    private var dataRecord: String!

    private var doneBlock:DoneBlock?

    private var backWindow:UIWindow = {
        let backWindow = UIWindow(frame: UIScreen.main.bounds)
        backWindow.windowLevel = UIWindow.Level.statusBar
        backWindow.backgroundColor = UIColor(white: 0, alpha: 0.3)
        backWindow.isHidden = true
        return backWindow
    }()
    
    private var backLabel:UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        return label
    }()
    
    private var pickerView:UIPickerView = {
        let datePicker = UIPickerView()
        datePicker.showsSelectionIndicator = false
        return datePicker
    }()
    
    private var doneBtn:UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle("确定", for: .normal)
        button.addTarget(self, action: #selector(doneBtnClick), for: .touchUpInside)
        return button
    }()
    
    private var cancelBtn:UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle("取消", for: .normal)
        button.addTarget(self, action: #selector(dismiss), for: .touchUpInside)
        return button
    }()
    
    private var bottomDoneBtn:UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle("确定", for: .normal)
        button.addTarget(self, action: #selector(doneBtnClick), for: .touchUpInside)
        return button
    }()
    
    private var titleLab:UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        return label
    }()
    
    private var line:UILabel = {
        let label = UILabel()
        label.backgroundColor =  UIColor(red: 222/255.0, green: 222/255.0, blue: 222/255.0, alpha: 1)
        return label
    }()
    
    private var config:DPPickerConfig = DPPickerConfig()
    
    private var title:String?
    private var selectIndex:Int = 0
    
    
    convenience init(title:String? = nil,dataArr:Array<String>,selectIndex:Int = 0,block:DoneBlock?){
        self.init()
        self.doneBlock = block
        self.title = title
        self.selectIndex = selectIndex
        self.dataArray = dataArr
        setupUI()
        setPickerConfig()
        loadData()
    }
    
    func setPickerConfig() {
        backgroundColor = config.backgroundColor
        layer.cornerRadius = config.cornerRadius
        
        backLabel.isHidden = config.isHiddenBackLabel
        backLabel.textColor = config.BackLabelColor
        backLabel.font = config.BackLabelFont
        
        cancelBtn.setTitleColor(config.topCancelBtnColor, for: .normal)
        cancelBtn.titleLabel?.font = config.topCancelBtnFont
        
        doneBtn.setTitleColor(config.topDoneBtnColor, for: .normal)
        doneBtn.titleLabel?.font = config.topDoneBtnFont
        
        
        titleLab.textColor = config.titleColor
        titleLab.font = config.titleFont
        titleLab.text = self.title
        
        
        bottomDoneBtn.setTitleColor(config.bottomBtnColor, for: .normal)
        bottomDoneBtn.backgroundColor = config.bottomBtnBackColor
        bottomDoneBtn.titleLabel?.font = config.bottomBtnFont
        
        if config.isTapClose {
            backWindow.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(dismiss)))
        }
    }
    
    func setupUI() {
        clipsToBounds = true
        //背景文字
        addSubview(backLabel)
        //时间控件
        setCustomPicker()
        
        if config.doneType == .Bottom {
            addSubview(bottomDoneBtn)
            backLabel.frame = CGRect(x: 0, y: 0, width: backWindow.frame.width - config.margin * 2, height: 250)
            bottomDoneBtn.frame = CGRect(x: 0, y: 250, width: backWindow.frame.width - config.margin * 2, height: 50)
        } else {
            addSubview(doneBtn)
            addSubview(cancelBtn)
            addSubview(self.titleLab)
            addSubview(self.line)
            cancelBtn.frame = CGRect(x: 0, y: 0, width: 70, height: 50)
            doneBtn.frame = CGRect(x: (backWindow.frame.width - config.margin * 2) - 70, y: 0, width: 70, height: 50)
            backLabel.frame = CGRect(x: 0, y: 50, width: backWindow.frame.width - config.margin * 2, height: 250)
            titleLab.frame = CGRect(x: 70, y: 0, width: backWindow.frame.width - config.margin * 2 - 70*2, height: 50)
            line.frame = CGRect(x: config.margin, y: 50, width: backWindow.frame.width - config.margin, height: 1)
        }
        DatePickerH = 300 + BottomHomeHeight()
    }
    
    private func setCustomPicker() {
        pickerView.delegate = self
        pickerView.dataSource = self
        pickerView.backgroundColor = UIColor.clear
        addSubview(pickerView)
        if config.doneType == .Bottom {
            pickerView.frame = CGRect(x: 0, y: 0, width: backWindow.frame.width - config.margin * 2, height: 250)
        } else {
            pickerView.frame = CGRect(x: 0, y: 50, width: backWindow.frame.width - config.margin * 2, height: 250)
        }
    }

    func loadData() {
        if self.selectIndex >= self.dataArray.count {
            self.selectIndex = self.dataArray.count - 1
        }
        dataRecord = self.dataArray[self.selectIndex]
        pickerView.selectRow(self.selectIndex, inComponent: 0, animated: true)
    }
    
    
    func show() {
        backWindow.addSubview(self)
        backWindow.isHidden = false
        
        self.pickerView.reloadAllComponents()
        
        frame = CGRect(x: config.margin, y: backWindow.frame.height, width: backWindow.frame.width - config.margin * 2, height: DatePickerH)
        
        UIView.animate(withDuration: 0.3) {
            self.frame = CGRect.init(x: self.config.margin, y: self.backWindow.frame.height - DatePickerH, width: self.backWindow.frame.width - self.config.margin*2, height: DatePickerH)
        }
    }
    
    
   @objc func dismiss() {
        UIView.animate(withDuration: 0.3, animations: {
            self.frame = CGRect.init(x: self.config.margin, y: self.backWindow.frame.height, width: self.backWindow.frame.width - self.config.margin*2, height: DatePickerH)
        }) { (_) in
            self.removeFromSuperview()
            self.backWindow.resignKey()
            self.backWindow.isHidden = true
        }
    }
    
    @objc func doneBtnClick() {
        if self.doneBlock != nil {
            self.doneBlock!(dataRecord)
        }
        self.dismiss()
    }
}


extension DPPickerView : UIPickerViewDelegate,UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1;
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return dataArray.count;
    }
    
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let title: String = self.dataArray[row]
        let label = UILabel()
        label.textAlignment = .right
        label.font = UIFont.systemFont(ofSize: 20)
        label.text = title
        label.sizeToFit()
        return label
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        dataRecord = self.dataArray[row]
    }
    
}
