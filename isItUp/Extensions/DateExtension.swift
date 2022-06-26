//
//  DateExtension.swift
//  isItUp
//
//  Created by Paul van Woensel on 6/25/22.
//

import Foundation

extension Date {
    public var dayTime: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        return formatter.string(from: self)
    }
}
