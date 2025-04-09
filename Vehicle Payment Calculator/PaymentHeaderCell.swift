//
//  PaymentHeaderCell.swift
//  Vehicle Payment Calculator
//
//  Created by Logan Nelsen on 4/9/25.
//

import SwiftUI

struct PaymentHeaderCell: View {
    let term: Int
    @Binding var rate: Double
    @Binding var editingTerm: Int?

    var body: some View {
        VStack(spacing: 4) {
            if editingTerm == term {
                TextField("Rate", value: $rate, formatter: {
                    let formatter = NumberFormatter()
                    formatter.minimumFractionDigits = 1
                    formatter.maximumFractionDigits = 3
                    return formatter
                }())
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .keyboardType(.decimalPad)
                .frame(width: 60)
                .toolbar {
                    ToolbarItemGroup(placement: .keyboard) {
                        Spacer()
                        Button("Done") {
                            editingTerm = nil
                            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                        }
                    }
                }
            } else {
                Text("\(rate, specifier: "%.1f")%")
                    .font(.footnote)
                    .onTapGesture {
                        editingTerm = term
                    }
            }
            Text("\(term)m")
                .fontWeight(.bold)
        }
    }
}
