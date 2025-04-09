//
//  Formatters.swift
//  Vehicle Payment Calculator
//
//  Created by Logan Nelsen on 4/9/25.
//

import Foundation

func formatCurrency(_ value: Double) -> String {
    let formatter = NumberFormatter()
    formatter.numberStyle = .decimal
    formatter.groupingSeparator = ","
    formatter.maximumFractionDigits = 0
    return "$\(formatter.string(from: NSNumber(value: value)) ?? "\(Int(value))")"
}

func formatNumber(_ value: Double) -> String {
    if value < 1000 {
        return String(format: "%.0f", value)
    } else {
        let valueInK = value / 1000.0
        return valueInK == floor(valueInK)
            ? String(format: "%.0fk", valueInK)
            : String(format: "%.1fk", valueInK)
    }
}
