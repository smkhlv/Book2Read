//
//  DateFormatter+Ext.swift
//
//
//  Created by Igoryok on 01.02.2024.
//

import Foundation

extension DateFormatter {
    static let bookDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
}
