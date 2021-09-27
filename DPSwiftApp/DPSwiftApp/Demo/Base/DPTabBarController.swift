//
//  DPTabBarController.swift
//  DPSwiftApp
//
//  Created by developeng on 2021/8/9.
//

import UIKit

class DPTabBarController: UITabBarController,UITabBarControllerDelegate{

    override func viewDidLoad() {
        super.viewDidLoad()
        customIrregularityStyle()

    }
    
    // 加载底部tabbar样式
    func customIrregularityStyle() {
        
        let titleArr:Array = ["消息","大数据","管理","我"]
        let imageNamesArr:Array = ["tabbar_message",
                                   "tabbar_report",
                                   "tabbar_manage",
                                   "tabbar_mine"]
        let selImageNamesArr:Array = ["tabbar_message_sel",
                                      "tabbar_report_sel",
                                      "tabbar_manage_sel",
                                      "tabbar_mine_sel"]
        let VCArr:Array = [DPHomeViewController(),
                           DPReportViewController(),
                           DPManageViewController(),
                           DPMineViewController()]
        
        
        for (index, value) in titleArr.enumerated() {
            addChildController(ChildController: VCArr[index],
                               Title: value,
                               DefaultImage: UIImage(named: imageNamesArr[index])!,
                               SelectedImage: UIImage(named: selImageNamesArr[index])!,tag: index)
            
        }
        
        let tabbar:DPTabBar = DPTabBar()
        tabbar.centerBlock = {
            
            print("点击了中国南京爱你")
        }
        self.setValue(tabbar, forKeyPath: "tabBar")
        
        self.delegate = self
        self.tabBar.tintColor = .blue
        self.selectedIndex = 0
        self.tabBar.isTranslucent = true
        self.edgesForExtendedLayout = .init(rawValue: 0)
        
        
    }
    
    func addChildController(ChildController child:UIViewController,Title title:String,DefaultImage defaultImage:UIImage,SelectedImage selectedImage:UIImage,tag:Int) {
        
        child.tabBarItem = UITabBarItem.init(title: title, image: defaultImage.withRenderingMode(.alwaysOriginal), selectedImage: selectedImage.withRenderingMode(.alwaysOriginal))
        child.tabBarItem.setTitleTextAttributes([NSAttributedString.Key.foregroundColor:UIColor.blue], for: .selected)
        child.tabBarItem.tag = tag
        child.hidesBottomBarWhenPushed = false; child.tabBarItem.setTitleTextAttributes([NSAttributedString.Key.foregroundColor:UIColor.black], for: .normal)
        let nav = UINavigationController(rootViewController: child)
        nav.navigationBar.isTranslucent = false
        nav.navigationItem.title = title
        self.addChild(nav)
    }
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        
        
        
        
        
    }
    
    
    
}
