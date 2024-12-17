//
//  Date+Extensions.swift
//  MulticoreDatabase
//
//  Created by Dmitriy Permyakov on 17.12.2024.
//

import Foundation

extension Date {
    var currentTime: String {
        let currentDate = self
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm:ss"
        let timeString = dateFormatter.string(from: currentDate)
        return timeString
    }
}
