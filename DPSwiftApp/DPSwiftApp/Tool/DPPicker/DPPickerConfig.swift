//
//  DPPickerConfig.swift
//  DPSwiftApp
//
//  Created by developeng on 2021/8/9.
//

import UIKit

// MARK:- 屏幕
/// 当前屏幕状态 高度
public let DP_ScreenHeight = max(UIScreen.main.bounds.width, UIScreen.main.bounds.height)
/// 当前屏幕状态 宽度
public let DP_ScreenWidth = min(UIScreen.main.bounds.width, UIScreen.main.bounds.height)
/// 获取刘海屏底部home键高度,普通屏为0
public func BottomHomeHeight() ->CGFloat {
    if #available(iOS 11.0, *){
        return UIApplication.shared.windows[0].safeAreaInsets.bottom
    }else{
        return 0
    }
}


enum DoneSiteType {
    case Top
    case Bottom
}

public enum DPDatePickerType{
    //系统样式
    case Date
    case DateAndTime
    case Time
    case CountDownTimer
    //自定义样式
    case YMDHms
    case YMDHm
    case YMDH
    case MDHm
    case YMD
    case YM
    case Y
    case MD
    case Hms
    case Hm
    case ms
}


//选择器相关配置
class DPPickerConfig: NSObject {
    
    ///是否可点击背景关闭
    var isTapClose: Bool = true
    ///确定按钮显示位置
    var doneType: DoneSiteType = .Top
    ///时间样式
    var type: DPDatePickerType = .YMD
    ///左右两边的间隔
    var margin:CGFloat = 0
    ///圆角
    var cornerRadius:CGFloat = 0
    ///背景色
    var backgroundColor:UIColor = UIColor.white
    ///是否隐藏背景字 （不适用于系统样式）
    var isHiddenBackLabel:Bool = false
    ///背景字颜色
    var BackLabelColor:UIColor = UIColor(red: 233/255.0, green: 237/255.0, blue: 242/255.0, alpha: 1)
    ///背景字大小
    var BackLabelFont:UIFont = UIFont.boldSystemFont(ofSize: 120)
    ///底部按钮字体颜色
    var bottomBtnColor:UIColor = UIColor.white
    ///底部按钮字体大小
    var bottomBtnFont:UIFont = UIFont.boldSystemFont(ofSize: 17)
    ///底部按钮背景色
    var bottomBtnBackColor:UIColor = UIColor.orange
    ///顶部取消按钮字体颜色
    var topCancelBtnColor:UIColor = UIColor(red: 153/255.0, green: 153/255.0, blue: 153/255.0, alpha: 1)
    ///顶部取消按钮字体大小
    var topCancelBtnFont:UIFont = UIFont.systemFont(ofSize: 15)
    
    ///顶部确定按钮字体颜色
    var topDoneBtnColor:UIColor = UIColor(red: 87/255.0, green: 146/255.0, blue: 249/255.0, alpha: 1)
    ///顶部确定按钮字体大小
    var topDoneBtnFont:UIFont = UIFont.systemFont(ofSize: 15)
    
    ///顶部标题字体颜色
    var titleColor:UIColor = UIColor(red: 0/255.0, green: 0/255.0, blue: 0/255.0, alpha: 1)
    ///顶部标题字体大小
    var titleFont:UIFont = UIFont.systemFont(ofSize: 15)
    
    
    

}
