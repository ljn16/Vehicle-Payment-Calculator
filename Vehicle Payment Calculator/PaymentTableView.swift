//
//  PaymentTableView.swift
//  Vehicle Payment Calculator
//
//  Created by Logan Nelsen on 4/9/25.
//

import SwiftUI

struct PaymentTableView: View {
    let baseTotal: Double
    let tradeIn: Double
    let stateTaxRate: Double
    let termOptions: [Int]
    let cashDownValue: Double
    let monthlyBudget: Double
    @Binding var termFinanceTaxRates: [Int: Double]

    @State private var editingTerm: Int? = nil
    @State private var selectedPayment: PaymentDetail? = nil
    @State private var showBreakdown = false

    var dynamicCashDownOptions: [Double] {
        let lower = max(0, cashDownValue - 1000)
        let middle = cashDownValue
        let upper = cashDownValue + 1000
        return [lower, middle, upper]
    }

    func monthlyPayment(for cashDownOption: Double, term: Int) -> Double {
        let adjustedTotal = baseTotal - cashDownOption - tradeIn
        let financeRate = termFinanceTaxRates[term] ?? 0
        return (adjustedTotal * (1 + ((financeRate + stateTaxRate) / 100))) / Double(term)
    }

    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Text("")
                    .frame(width: 80)
                ForEach(termOptions, id: \.self) { term in
                    PaymentHeaderCell(
                        term: term,
                        rate: Binding(
                            get: { termFinanceTaxRates[term] ?? 0 },
                            set: { termFinanceTaxRates[term] = $0 }
                        ),
                        editingTerm: $editingTerm
                    )
                    .frame(maxWidth: .infinity)
                }
            }

            Divider()

            ForEach(dynamicCashDownOptions, id: \.self) { cash in
                HStack {
                    Text("$\(formatNumber(cash))")
                        .fontWeight(.bold)
                        .frame(width: 80, alignment: .leading)
                    ForEach(termOptions, id: \.self) { term in
                        let payment = monthlyPayment(for: cash, term: term)
                        Text("$\(payment, specifier: "%.0f")")
                            .foregroundColor(payment < monthlyBudget ? .green : .red)
                            .bold(payment < monthlyBudget)
                            .font(.footnote)
                            .frame(maxWidth: .infinity)
                            .onTapGesture {
                                selectedPayment = PaymentDetail(
                                    term: term,
                                    cashDown: cash,
                                    total: baseTotal - tradeIn,
                                    taxRate: stateTaxRate,
                                    financeRate: termFinanceTaxRates[term] ?? 0,
                                    monthly: payment
                                )
                            }
                    }
                }
            }
        }
        .padding(.horizontal)
        .sheet(item: $selectedPayment) { payment in
            VStack(spacing: 20) {
                Text("Payment Breakdown")
                    .font(.title2)
                    .bold()

                VStack(alignment: .leading, spacing: 12) {
                    Text("• Term: \(payment.term) months")
                    Text("• Cash Down: \(formatCurrency(payment.cashDown))")
                    Text("• Total Before Tax: \(formatCurrency(payment.total))")
                    Text("• Tax Rate: \(payment.taxRate, specifier: "%.2f")%")
                    Text("• Finance Rate: \(payment.financeRate, specifier: "%.2f")%")
                    
                    Spacer()
                    Spacer()

                    Divider()
                    

                    VStack(alignment: .center, spacing: 0) {
//                        Text("🧮 Monthly Payment Formula")
//                            .font(.headline)
//                            .padding(.bottom, 4)
//
//                        // General formula
//                        Group {
//                            Text("total × (tax + finance)")
////                            Text("Monthly =")
//                            Text("————————————————————————————————")
//                            Text("term")
//                        }
//                        .font(.system(.body, design: .monospaced))
//                        .multilineTextAlignment(.center)
//
//                        Divider().padding(.vertical)

                        // Plugged-in values
                        Group {
                            Text("(\(formatCurrency(payment.total)) - \(formatCurrency(payment.cashDown)) - \(formatCurrency(tradeIn)))  × (\(100 + payment.taxRate, specifier: "%.2f")% + \(payment.financeRate, specifier: "%.2f")%)")
                            Text("————————————————————————————————")
                            Text("\(payment.term)")
                        }
                        .font(.system(.body, design: .monospaced))
                        .multilineTextAlignment(.center)

                        Divider().padding(.vertical)

                        Spacer()
                        Spacer()

                        Text("↓")
//                            .font(.title3)
//                            .bold()
                        Spacer()
                        Text("\(formatCurrency(payment.monthly))")
                            .font(.title3)
                            .bold()
                        Text("per month")
//                            .font(.title3)
//                            .bold()
                        Spacer()
                        Spacer()
                        Spacer()
                        Spacer()
                        Spacer()

                    }
                }

                Spacer()
            }
            .padding()
        }
        
    }
}
