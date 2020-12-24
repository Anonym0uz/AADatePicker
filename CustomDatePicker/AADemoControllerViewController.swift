//
//  AADemoControllerViewController.swift
//  AACustomDatePicker
//
//  Created by sot on 24.12.2020.
//  Copyright © 2020 I'm IT. All rights reserved.
//

import UIKit

class AADemoControllerViewController: UIViewController {
    
    var picker: AADatePicker!
    
    let testLabel: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.font = .systemFont(ofSize: 18, weight: .bold)
        l.textColor = .black
        l.numberOfLines = 0
        l.text = "Sample!"
        return l
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        var comps = DateComponents()
        comps.month = 1
        picker = AADatePicker(minDate: Date(), maxDate: Calendar.current.date(byAdding: comps, to: Date())!, showOnlyValid: true)
        picker.delegate = self
        picker.backgroundColor = .white
        view.addSubview(picker)
        view.addSubview(testLabel)
        
        view.setNeedsUpdateConstraints()
    }
    
    override func updateViewConstraints() {
        super.updateViewConstraints()
        
        NSLayoutConstraint.activate([
            picker.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
            picker.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0),
            picker.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 0),
            picker.heightAnchor.constraint(equalToConstant: UIScreen.main.bounds.height / 3),
            
            // Label
            testLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 0),
            testLabel.topAnchor.constraint(equalTo: picker.bottomAnchor, constant: 10)
        ])
    }
}

extension AADemoControllerViewController: AADatePickerDelegate {
    func dateChanged(_ date: Date?) {
        guard let normalDate = date else {
            print("date is nil")
            return
        }
        let df = DateFormatter()
        df.calendar = .current
        df.timeZone = .current
        df.dateFormat = "dd MMM, EEE"
        testLabel.text = df.string(from: normalDate)
    }
}
