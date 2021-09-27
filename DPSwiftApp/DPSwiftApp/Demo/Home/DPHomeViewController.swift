//
//  DPHomeViewController.swift
//  DPSwiftApp
//
//  Created by developeng on 2021/8/9.
//

import UIKit

class DPHomeViewController: UIViewController {
    
    
    var datePickerView:DPDatePickerView!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        let button:UIButton = {
            
            let btn:UIButton = UIButton.init(type: .custom)
            btn.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
            btn.setTitle("弹窗", for: .normal)
            btn.backgroundColor = UIColor.red
            btn.addTarget(self, action: #selector(tap), for: .touchUpInside)
            return btn
        }()
        self.view.addSubview(button)

    }
    
    @objc func tap(){
        
//        let pickerView:DPPickerView = DPPickerView()
//
//        pickerView.show()
        
        
        
        DPDatePicker.show( dataArr: ["1","2","3","4","5","6"],selectIndex: 3) { value in
            print(value)
        }
        
        
        
        
//        DPDatePicker.show(currentDate: nil, minLimitDate: Date(), maxLimitDate:nil)
    }

}
