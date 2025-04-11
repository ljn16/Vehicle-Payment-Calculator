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
    
    @State private var isExpanded = true


    var dynamicCashDownOptions: [Double] {
        let middle = cashDownValue
        let (lowerOffset, upperOffset): (Double, Double)

        switch cashDownValue {
        case ...10_000:
            lowerOffset = 1_000
            upperOffset = 1_000
        case ...20_000:
            lowerOffset = 2_000
            upperOffset = 2_000
        default:
            lowerOffset = 5_000
            upperOffset = 5_000
        }

        let lower = max(0, middle - lowerOffset)
        let upper = middle + upperOffset

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
//                    Spacer()
                    Text("• Factors •")
                        .frame(maxWidth: .infinity, alignment: .center).foregroundStyle(.secondary)
                    VStack(alignment: .leading, spacing: 4) {
                        // Header (clickable)
                        Button(action: {
                            withAnimation {
                                isExpanded.toggle()
                            }
                        }) {
                            Text(isExpanded ? "+ " : "+ ")
                                .foregroundColor(.red)
                            + Text("Base Total: ")
                            + Text("\(formatCurrency(baseTotal))").foregroundStyle(.red)
                        }
                        .buttonStyle(PlainButtonStyle()) // Removes default button styling

                        // Expanded content
                        if isExpanded {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("includes: vehicle price, accessories, warrenties, license/registration").foregroundStyle(.secondary)
//                                if serviceContract {
//                                    Text("• Service Contract: \(formatCurrency(serviceContractCost))")
//                                }
//                                if gap {
//                                    Text("• GAP Insurance: \(formatCurrency(gapCost))")
//                                }
                            }
                            .font(.caption)
                            .padding(.leading, 20)
                        }
                    }
//                    Text("+ ").foregroundColor(.red) + Text("Base Total: \(formatCurrency(baseTotal))
                    
                    Text("- ").foregroundColor(.green)
                    + Text("Cash Down: ")
                    + Text("\(formatCurrency(payment.cashDown))").foregroundStyle(.green)
                    Text("- ").foregroundColor(.green)
                    + Text("Trade-In Value: ")
                    + Text("\(formatCurrency(tradeIn))").foregroundStyle(.green)
                    Text("• Total Amount Financed: \(formatCurrency(baseTotal - tradeIn - payment.cashDown))")
//                    Spacer()
                    Text("• Tax •")
                        .frame(maxWidth: .infinity, alignment: .center).foregroundStyle(.secondary)
                    Text("× ").foregroundColor(.red)
                    + Text("State Tax Rate (MN): \(payment.taxRate, specifier: "%.2f")%")
                    Text("× ").foregroundColor(.red)
                    + Text("Finance Rate: ")
                    + Text("\(payment.financeRate, specifier: "%.2f")%").foregroundStyle(.red)
//                    Text("• Finance Rate: \(payment.financeRate, specifier: "%.2f")% (\((payment.financeRate * (baseTotal - tradeIn - payment.cashDown), specifier: "%.2f"))")

                    
                    Spacer()
                    Spacer()

                    Divider()
                    

                    VStack(alignment: .center, spacing: 0) {
                        Group {
                            Text("(")
                            + Text("\(formatCurrency(baseTotal)) ").foregroundStyle(.red)
                            + Text("- ")
                            + Text("\(formatCurrency(payment.cashDown))").foregroundStyle(.green)
                            + Text(" - ")
                            + Text("\(formatCurrency(tradeIn)) ").foregroundStyle(.green)
                            + Text(") × ")
                            + Text("(\(100 + payment.taxRate, specifier: "%.2f")% + ")
                            + Text("\(payment.financeRate, specifier: "%.2f")%").foregroundStyle(.red)
                            + Text(")")
                            Text("—————————————————————————————————————————————————")
                            Text("\(payment.term) months")
                        }
                        .font(.system(size: 11, design: .monospaced)) // 👈 try 10–13 if it's still too large
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
