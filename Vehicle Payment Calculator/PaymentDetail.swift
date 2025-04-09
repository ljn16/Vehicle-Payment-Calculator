//
//  PaymentDetail.swift
//  Vehicle Payment Calculator
//
//  Created by Logan Nelsen on 4/9/25.
//

import Foundation

struct PaymentDetail: Identifiable {
    let id = UUID()
    let term: Int
    let cashDown: Double
    let total: Double
    let taxRate: Double
    let financeRate: Double
    let monthly: Double
}
