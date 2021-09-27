//
//  DPDatePicker.swift
//  DPSwiftApp
//
//  Created by developeng on 2021/8/9.
//

import UIKit

fileprivate var DatePickerH:CGFloat = 270

/// 记录
struct DPDateRecord {
    var year: String
    var month: String
    var day: String
    var hour: String
    var minute: String
    var second: String
}

enum DPDateComponent {
    case year
    case month
    case day
    case hour
    case minute
    case second
}

class DPDatePicker: NSObject {
    
    static func show(currentDate:Date? = nil,minLimitDate:Date? = nil,maxLimitDate: Date? = nil) {
        let view:DPDatePickerView = DPDatePickerView(currentDate: currentDate, minLimitDate: minLimitDate, maxLimitDate: maxLimitDate)
        view.show()
    }
    
    static func show(title:String? = nil,dataArr:Array<String>,selectIndex:Int = 0,block:DoneBlock?) {
        let view:DPPickerView = DPPickerView(title: title, dataArr: dataArr,selectIndex: selectIndex,block:block)
        view.show()
    }
    
}

class DPDatePickerView: UIView {
    
    private var dataArray = [DPDateComponent:Array<String>]()
    private var dateComponentOrder = [DPDateComponent]()
    private var dateRecord: DPDateRecord!

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
    
    private var datePicker:UIPickerView = {
        let datePicker = UIPickerView()
        datePicker.showsSelectionIndicator = false
        return datePicker
    }()
    
    private var systemDatePicker:UIDatePicker = {
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        datePicker.locale = Locale.init(identifier: "zh_Hans_CN")
        if #available(iOS 13.4, *) {
            datePicker.preferredDatePickerStyle = .wheels
        }
        return datePicker
    }()
    
    private var doneBtn:UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle("确定", for: .normal)
        button.addTarget(self, action: #selector(dismiss), for: .touchUpInside)
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
        button.addTarget(self, action: #selector(dismiss), for: .touchUpInside)
        return button
    }()
    
    
    private var minLimitDate = Date.init(timeIntervalSince1970: TimeInterval(0))
    private var maxLimitDate = Date.init(timeIntervalSince1970: TimeInterval(9999999999))
    private var config:DPPickerConfig = DPPickerConfig()
    
    
    convenience init(currentDate:Date?,minLimitDate:Date?,maxLimitDate: Date?){
        self.init()
        
        let currentDate = currentDate ?? Date()
        let year = String(currentDate.getComponent(component: .year))
        let month = addZero(currentDate.getComponent(component: .month))
        let day = addZero(currentDate.getComponent(component: .day))
        let hour = addZero(currentDate.getComponent(component: .hour))
        let minute = addZero(currentDate.getComponent(component: .minute))
        let second = addZero(currentDate.getComponent(component: .second))
        
        dateRecord = DPDateRecord(year: year, month: month, day: day, hour: hour, minute: minute, second: second)
        
        if let minLimitDate = minLimitDate {
            self.minLimitDate = minLimitDate
        }
        if let maxLimitDate = maxLimitDate {
            self.maxLimitDate = maxLimitDate
        }
        setupUI()
        setPickerConfig()
        switch config.type {
        case .Date,.DateAndTime,.CountDownTimer,.Time:
            setSystemPicker()
        default:
            loadData()
        }
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
        switch config.type {
        case .Date,.DateAndTime,.CountDownTimer,.Time:
            setSystemPicker()
        default:
            setCustomPicker()
        }
        
        if config.doneType == .Bottom {
            addSubview(bottomDoneBtn)
            backLabel.frame = CGRect(x: 0, y: 0, width: backWindow.frame.width - config.margin * 2, height: 250)
            bottomDoneBtn.frame = CGRect(x: 0, y: 250, width: backWindow.frame.width - config.margin * 2, height: 50)
        } else {
            addSubview(doneBtn)
            addSubview(cancelBtn)
            cancelBtn.frame = CGRect(x: 0, y: 0, width: 70, height: 50)
            doneBtn.frame = CGRect(x: (backWindow.frame.width - config.margin * 2) - 70, y: 0, width: 70, height: 50)
            backLabel.frame = CGRect(x: 0, y: 50, width: backWindow.frame.width - config.margin * 2, height: 250)
        }
        DatePickerH = 300 + BottomHomeHeight()
    }
    
    private func setSystemPicker() {
        addSubview(systemDatePicker)
        if config.doneType == .Bottom {
            systemDatePicker.frame = CGRect(x: 0, y: 0, width: backWindow.frame.width - config.margin * 2, height: 250)
        } else {
            systemDatePicker.frame = CGRect(x: 0, y: 50, width: backWindow.frame.width - config.margin * 2, height: 250)
        }
        
        switch config.type {
        case .Date:
            systemDatePicker.datePickerMode = .date
        case .DateAndTime:
            systemDatePicker.datePickerMode = .dateAndTime
        case .Time:
            systemDatePicker.datePickerMode = .time
        case .CountDownTimer:
            systemDatePicker.datePickerMode = .countDownTimer
        default:
            systemDatePicker.datePickerMode = .date
        }
    }
    
    private func setCustomPicker() {
        datePicker.delegate = self
        datePicker.dataSource = self
        datePicker.backgroundColor = UIColor.clear
        addSubview(datePicker)
        if config.doneType == .Bottom {
            datePicker.frame = CGRect(x: 0, y: 0, width: backWindow.frame.width - config.margin * 2, height: 250)
        } else {
            datePicker.frame = CGRect(x: 0, y: 50, width: backWindow.frame.width - config.margin * 2, height: 250)
        }
    }

    func loadData() {
        
        // 获取对应数据
        for char in String(describing: config.type) {
            switch char {
            case "Y":
                dataArray[.year] = getYears()
                dateComponentOrder.append(.year)
            case "M":
                dataArray[.month] = getMonths()
                dateComponentOrder.append(.month)
            case "D":
                dataArray[.day] = getDays()
                dateComponentOrder.append(.day)
            case "H":
                dataArray[.hour] = getHours()
                dateComponentOrder.append(.hour)
            case "m":
                dataArray[.minute] = getMinute()
                dateComponentOrder.append(.minute)
            case "s":
                dataArray[.second] = getMinute()
                dateComponentOrder.append(.second)
            default:
                break
            }
        }

        // 刷新数据
        datePicker.reloadAllComponents()
        backLabel.text = dateRecord.year
        
        // 滚动到指定时间
        scrollToDate(components: dateComponentOrder, animated: false)
        
    }
    
    
    func show() {
        backWindow.addSubview(self)
        backWindow.isHidden = false
        
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
}


extension DPDatePickerView : UIPickerViewDelegate,UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return dataArray.count
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        let dateComponent = dateComponentOrder[component]
        return dataArray[dateComponent]?.count ?? 0
    }
    
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        
        var title: String = " "
        let dateComponent = dateComponentOrder[component]
        
        switch dateComponent {
        case .year:
            title = (dataArray[dateComponent]?[row])! + "年"
        case .month:
            title = (dataArray[dateComponent]?[row])! + "月"
        case .day:
            title = (dataArray[dateComponent]?[row])! + "日"
        case .hour:
            title = (dataArray[dateComponent]?[row])! + "时"
        case .minute:
            title = (dataArray[dateComponent]?[row])! + "分"
        case .second:
            title = (dataArray[dateComponent]?[row])! + "秒"
        }
        let label = UILabel()
        label.textAlignment = .right
        label.font = UIFont.systemFont(ofSize: 20)
        label.text = title
        label.sizeToFit()
        return label
    }
    
    //适配YMDHms 年显示被遮挡问题
    public func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        let dateComponent = dateComponentOrder[component]
        
        if dateComponent == .year {
            return datePicker.frame.width / CGFloat(self.dataArray.count + 1) * 1.5
        }
        return datePicker.frame.width / CGFloat(self.dataArray.count + 1)
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let dateComponent = dateComponentOrder[component]
        
        switch dateComponent {
        case .year:
            dateRecord.year = dataArray[.year]![row]
            backLabel.text = dateRecord.year
        case .month:
            dateRecord.month = dataArray[.month]![row]
        case .day:
            dateRecord.day = dataArray[.day]![row]
        case .hour:
            dateRecord.hour = dataArray[.hour]![row]
        case .minute:
            dateRecord.minute = dataArray[.minute]![row]
        case .second:
            dateRecord.second = dataArray[.second]![row]
        }
        reload(dateComponent: dateComponent)
        
    }
    
}

extension DPDatePickerView{
    
    func addZero(_ num:Int) -> String {
        return num < 10 ? ("0" + String(num)) : String(num)
    }
    
    //获取年份
    func getYears() -> Array<String> {
        var years = [String]()
        for year in minLimitDate.getComponent(component: .year)...maxLimitDate.getComponent(component: .year) {
            years.append(String(year))
        }
        return years
    }
    
    // 获取月份
    func getMonths() -> Array<String> {
        var months = [String]()
        
        var minMonth = 1
        if Int(dateRecord.year) == minLimitDate.getComponent(component: .year) {
            minMonth = minLimitDate.getComponent(component: .month)
        }
        var maxMonth = 12
        if Int(dateRecord.year) == maxLimitDate.getComponent(component: .year) {
            maxMonth = maxLimitDate.getComponent(component: .month)
        }
        
        for month in minMonth...maxMonth {
            months.append(month < 10 ? ("0" + String(month)):String(month))
        }
        return months
    }
    // 获取天数
    func getDays() -> Array<String> {
        var days = [String]()
        
        var minDay = 1
        if Int(dateRecord.year) == minLimitDate.getComponent(component: .year) && Int(dateRecord.month) == minLimitDate.getComponent(component: .month) {
            minDay = minLimitDate.getComponent(component: .day)
        }
        var maxDay = getMaxDays(year: Int(dateRecord.year)!, month: Int(dateRecord.month)!)
        if Int(dateRecord.year) == maxLimitDate.getComponent(component: .year) && Int(dateRecord.month) == maxLimitDate.getComponent(component: .month) {
            maxDay = maxLimitDate.getComponent(component: .day)
        }
        
        for day in minDay...maxDay {
            days.append(day < 10 ? ("0" + String(day)):String(day))
        }
        return days
    }
    
    // 获取小时
    func getHours() -> Array<String> {
        var hours = [String]()
        
        var minHour = 0
        if Int(dateRecord.year) == minLimitDate.getComponent(component: .year) && Int(dateRecord.month) == minLimitDate.getComponent(component: .month) &&
            Int(dateRecord.day) == minLimitDate.getComponent(component: .day) {
            minHour = minLimitDate.getComponent(component: .hour)
        }
        var maxHour = 23
        if Int(dateRecord.year) == maxLimitDate.getComponent(component: .year) && Int(dateRecord.month) == maxLimitDate.getComponent(component: .month) &&
            Int(dateRecord.day) == maxLimitDate.getComponent(component: .day) {
            maxHour = maxLimitDate.getComponent(component: .hour)
        }
        
        for hour in minHour...maxHour {
            hours.append(hour < 10 ? ("0" + String(hour)):String(hour))
        }
        return hours
    }
    
    // 获取分钟
    func getMinute() -> Array<String> {
        var minutes = [String]()
        
        var minMinute = 0
        if Int(dateRecord.year) == minLimitDate.getComponent(component: .year) && Int(dateRecord.month) == minLimitDate.getComponent(component: .month) &&
            Int(dateRecord.day) == minLimitDate.getComponent(component: .day) &&
            Int(dateRecord.hour) == minLimitDate.getComponent(component: .hour) {
            minMinute = minLimitDate.getComponent(component: .minute)
        }
        var maxMinute = 59
        if Int(dateRecord.year) == maxLimitDate.getComponent(component: .year) && Int(dateRecord.month) == maxLimitDate.getComponent(component: .month) &&
            Int(dateRecord.day) == maxLimitDate.getComponent(component: .day) &&
            Int(dateRecord.hour) == maxLimitDate.getComponent(component: .hour) {
            maxMinute = maxLimitDate.getComponent(component: .minute)
        }
        
        for minute in minMinute...maxMinute {
            minutes.append(minute < 10 ? ("0" + String(minute)):String(minute))
        }
        return minutes
    }
    
    // 获取秒
    func getSecond() -> Array<String> {
        var seconds = [String]()
        
        var minSecond = 0
        if Int(dateRecord.year) == minLimitDate.getComponent(component: .year) && Int(dateRecord.month) == minLimitDate.getComponent(component: .month) &&
            Int(dateRecord.day) == minLimitDate.getComponent(component: .day) &&
            Int(dateRecord.hour) == minLimitDate.getComponent(component: .hour) &&
            Int(dateRecord.minute) == minLimitDate.getComponent(component: .minute) {
            minSecond = minLimitDate.getComponent(component: .second)
        }
        var maxSecond = 59
        if Int(dateRecord.year) == maxLimitDate.getComponent(component: .year) && Int(dateRecord.month) == maxLimitDate.getComponent(component: .month) &&
            Int(dateRecord.day) == maxLimitDate.getComponent(component: .day) &&
            Int(dateRecord.hour) == maxLimitDate.getComponent(component: .hour) &&
            Int(dateRecord.minute) == maxLimitDate.getComponent(component: .minute){
            maxSecond = maxLimitDate.getComponent(component: .second)
        }
        
        for second in minSecond...maxSecond {
            seconds.append(second < 10 ? ("0" + String(second)):String(second))
        }
        return seconds
    }
    
    
    
    // 获取对应年月的天数
    func getMaxDays(year: Int, month: Int) -> Int {
        
        let isLeapYear = year % 4 == 0 ? (year % 100 == 0 ? (year % 400 == 0 ? true:false):true):false
        switch month {
        case 1,3,5,7,8,10,12:
            return 31
        case 4,6,9,11:
            return 30
        case 2:
            return isLeapYear ? 29 : 28
        default:
            return 30
        }
    }
    // 滚动到指定时间
    func scrollToDate(components:[DPDateComponent], animated: Bool) {
        
        for c in components {
            
            var timeString: String?
            
            switch c {
            case .year:
                timeString = dateRecord.year
            case .month:
                timeString = dateRecord.month
            case .day:
                timeString = dateRecord.day
            case .hour:
                timeString = dateRecord.hour
            case .minute:
                timeString = dateRecord.minute
            case .second:
                timeString = dateRecord.second
            }
            
            guard let component = dateComponentOrder.firstIndex(of: c),
                let timeStr = timeString,
                let row = dataArray[c]?.firstIndex(of: timeStr)
                else {return}
            
            datePicker.selectRow(row, inComponent: component, animated: animated)
        }
    }
    
    // 刷新数据
    func reload(dateComponent:DPDateComponent) {
        
        guard let index = dateComponentOrder.firstIndex(of: dateComponent) else {return}
        
        var components = [DPDateComponent]()
        
        for (i,c) in dateComponentOrder.enumerated() {
            if i > index {
                components.append(c)
                switch c {
                case .month:
                    dataArray[.month]?.removeAll()
                    dataArray[.month] = getMonths()
                    datePicker.reloadComponent(dateComponentOrder.firstIndex(of: .month)!)
                    if Int(dateRecord.month)! < Int(dataArray[.month]!.first!)! {
                        dateRecord.month = dataArray[.month]!.first!
                    }else if Int(dateRecord!.month)! > Int(dataArray[.month]!.last!)! {
                        dateRecord.month = dataArray[.month]!.last!
                    }
                case .day:
                    dataArray[.day]?.removeAll()
                    dataArray[.day] = getDays()
                    datePicker.reloadComponent(dateComponentOrder.firstIndex(of: .day)!)
                    if Int(dateRecord.day)! < Int(dataArray[.day]!.first!)! {
                        dateRecord.day = dataArray[.day]!.first!
                    }else if Int(dateRecord.day)! > Int(dataArray[.day]!.last!)! {
                        dateRecord.day = dataArray[.day]!.last!
                    }
                case .hour:
                    dataArray[.hour]?.removeAll()
                    dataArray[.hour] = getHours()
                    datePicker.reloadComponent(dateComponentOrder.firstIndex(of: .hour)!)
                    if Int(dateRecord.hour)! < Int(dataArray[.hour]!.first!)! {
                        dateRecord.hour = dataArray[.hour]!.first!
                    }else if Int(dateRecord.hour)! > Int(dataArray[.hour]!.last!)! {
                        dateRecord.hour = dataArray[.hour]!.last!
                    }
                case .minute:
                    dataArray[.minute]?.removeAll()
                    dataArray[.minute] = getMinute()
                    datePicker.reloadComponent(dateComponentOrder.firstIndex(of: .minute)!)
                    if Int(dateRecord.minute)! < Int(dataArray[.minute]!.first!)! {
                        dateRecord.minute = dataArray[.minute]!.first!
                    }else if Int(dateRecord.minute)! > Int(dataArray[.minute]!.last!)! {
                        dateRecord.minute = dataArray[.minute]!.last!
                    }
                default:
                    break
                }
            }
        }
        
        scrollToDate(components: components, animated: false)
    }
}
