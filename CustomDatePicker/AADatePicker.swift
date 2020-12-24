//
//  AADatePicker.swift
//  AACustomDatePicker
//
//  Created by sot on 24.12.2020.
//  Copyright © 2020 I'm IT. All rights reserved.
//

import UIKit

protocol AADatePickerDelegate: class {
    func dateChanged(_ date: Date?)
}

final class AADatePicker: UIView {
    let picker: UIPickerView = {
        let p = UIPickerView()
        p.translatesAutoresizingMaskIntoConstraints = false
        return p
    }()
    private var nDays: Int!
    private let calendar: Calendar = Calendar.current
    private var minDate: Date!
    private var maxDate: Date!
    private var previousDate: Date {
        get {
            return (showOnlyValid) ? minDate : Date(timeIntervalSince1970: 0)
        }
    }
    private var date: Date!
    private var showOnlyValid: Bool = false
    
    var delegate: AADatePickerDelegate?
    
    init(frame: CGRect = .zero, minDate: Date, maxDate: Date, showOnlyValid: Bool = false) {
        super.init(frame: frame)
        if frame == .zero {
            translatesAutoresizingMaskIntoConstraints = false
        }
        self.minDate = minDate
        self.maxDate = maxDate
        self.showOnlyValid = showOnlyValid
        
        createMainElements()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func updateConstraints() {
        super.updateConstraints()
        
        NSLayoutConstraint.activate([
            picker.topAnchor.constraint(equalTo: topAnchor, constant: 0),
            picker.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 0),
            picker.leftAnchor.constraint(equalTo: leftAnchor, constant: 0),
            picker.rightAnchor.constraint(equalTo: rightAnchor, constant: 0),
        ])
    }
}

private extension AADatePicker {
    func createMainElements() {
        picker.delegate = self
        picker.dataSource = self
        addSubview(picker)
        
        initDate()
        
        showDateOnPicker(date)
        
        setNeedsUpdateConstraints()
    }
    
    func initDate() {
        if showOnlyValid {
            let components = calendar.dateComponents([.day],
                                                     from: minDate,
                                                     to: maxDate)
            
            nDays = components.day! + 1
        } else {
            nDays = Int(INT16_MAX)
        }
        
        var dateToPresent = Date()
        
        if minDate.compare(Date()) == .orderedDescending {
            dateToPresent = minDate
        } else if maxDate.compare(Date()) == .orderedAscending {
            dateToPresent = maxDate
        } else {
            dateToPresent = Date()
        }
        
        let todayComps = calendar.dateComponents([.day, .hour, .minute],
                                                 from: previousDate,
                                                 to: dateToPresent)
        let dayIndex: TimeInterval = TimeInterval(todayComps.day! * 24 * 60 * 60)
        let hourIndex: TimeInterval = TimeInterval(todayComps.hour! * 60 * 60)
        let minuteIndex: TimeInterval = TimeInterval(todayComps.minute! * 60)
        date = Date(timeInterval: dayIndex + hourIndex + minuteIndex, since: previousDate)
    }
    
    func showDateOnPicker(_ d: Date) {
        date = d
        
        var components = calendar.dateComponents([.year, .month, .day],
                                                 from: previousDate)
        let fromDate: Date = calendar.date(from: components)!
        
        components = calendar.dateComponents([.day, .hour, .minute],
                                             from: fromDate,
                                             to: date)
        
        picker.selectRow(components.day!, inComponent: 0, animated: true)
        picker.selectRow(components.hour! + 24 * (Int(INT16_MAX) / 120), inComponent: 1, animated: true)
        picker.selectRow(components.minute! + 60 * (Int(INT16_MAX) / 120), inComponent: 2, animated: true)
    }
}

extension AADatePicker: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int { 3 }
    func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        switch component {
        case 0:
            return 150
        case 1:
            return 60
        case 2:
            return 60
        default:
            return 0
        }
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch component {
        case 0:
            return nDays
        case 1:
            return Int(INT16_MAX)
        case 2:
            return Int(INT16_MAX)
        default:
            return 0
        }
    }
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat { 35 }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let lblDate: UILabel = UILabel()
        lblDate.font = UIFont.systemFont(ofSize: 25.0)
        lblDate.textColor = UIColor.black
        lblDate.backgroundColor = UIColor.clear
        
        if component == 0 // Date
        {
            let aDate: Date = Date(timeInterval: TimeInterval(row * 24 * 60 * 60), since: previousDate)
            
            var components: DateComponents! = calendar.dateComponents([.era, .year, .month, .day], from: Date())
            let today: Date! = calendar.date(from: components)
            components = calendar.dateComponents([.era, .year, .month, .day], from: aDate)
            let otherDate: Date! = calendar.date(from: components)
            
            if today == otherDate {
                lblDate.text = "Today"
            } else {
                let formatter: DateFormatter = DateFormatter()
                formatter.locale = .current
                formatter.timeZone = TimeZone.current
                formatter.calendar = calendar
                formatter.dateFormat = "dd MMM, EEE"
                
                lblDate.text = formatter.string(from: aDate)
            }
            lblDate.textAlignment = .right
        }
        else if component == 1 // Hour
        {
            let max: Int = calendar.maximumRange(of: .hour)!.count
            lblDate.text = String(format:"%02ld",(row % max)) // 02d = pad with leading zeros to 2 digits
            lblDate.textAlignment = .center
        }
        else if component == 2 // Minutes
        {
            let max: Int = calendar.maximumRange(of: .minute)!.count
            lblDate.text = String(format:"%02ld",(row % max))
            lblDate.textAlignment = .left
        }
        
        return lblDate
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let choosenDate: Date = Date(timeInterval: TimeInterval(pickerView.selectedRow(inComponent: 0) * 24 * 60 * 60), since: previousDate)
        
        var components = calendar.dateComponents([.day, .month, .year], from: choosenDate)
        
        components.hour = picker.selectedRow(inComponent: 1) % 24
        components.minute = picker.selectedRow(inComponent: 2) % 60
        
        date = calendar.date(from: components)
        
        if date.compare(minDate) == .orderedAscending {
            showDateOnPicker(minDate)
        } else if date.compare(maxDate) == .orderedDescending {
            showDateOnPicker(maxDate)
        }
        let formatter:DateFormatter! = DateFormatter()
        formatter.locale = .current
        formatter.timeZone = TimeZone.current
        formatter.calendar = calendar
        formatter.dateFormat = "dd.MM.yyyy"
        print(formatter.string(from: date))
        
        delegate?.dateChanged(date)
    }
}
