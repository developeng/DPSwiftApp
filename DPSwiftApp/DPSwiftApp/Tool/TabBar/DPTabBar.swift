//
//  DPTabBar.swift
//  DPSwiftApp
//
//  Created by developeng on 2021/8/9.
//

import UIKit

class DPTabBar: UITabBar {
    
    var centerBlock:(() -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(centerButton)
        addSubview(centerImgV)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    private lazy var centerImgV:UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "tabbar_contacts")
        imageView.contentMode = .scaleAspectFit
        imageView.sizeToFit()
        return imageView
    }()
    
    private lazy var centerButton:UIButton = {
        let button:UIButton = UIButton.init(type: .custom)
        button.addTarget(self, action: #selector(buttonClick), for: .touchUpInside)
        return button
    }()

    override func layoutSubviews() {
        
        super.layoutSubviews()
    
        guard let count = items?.count else {
            return
        }
        var index = 0
        let width = frame.size.width / CGFloat(count + 1)
        let height = frame.size.height
        
        centerImgV.center = CGPoint(x:frame.width * 0.5 , y: frame.height * 0.5 - 20)
        centerButton.frame = CGRect(x: 2 * width, y: 0, width: width, height: height)
        
        for subView in subviews {
            if NSStringFromClass(type(of: subView)) == "UITabBarButton" {
                if index == 2 {
                    index += 1
                }
                subView.frame = CGRect(x: CGFloat(index) * width, y: 0, width: width, height: height)
                index += 1
            }
        }
    }
    
    @objc func buttonClick() {
        
        if self.centerBlock != nil {
            self.centerBlock!()
        }
    }
    
}
