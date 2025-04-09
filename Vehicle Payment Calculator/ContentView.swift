//
//  ContentView.swift
//  Vehicle Payment Calculator
//
//  Created by Logan Nelsen on 3/28/25.
//

import SwiftUI

// MARK: - iOS-Style Slider
struct iOSStyledSlider: View {
    @Binding var value: Double
    var range: ClosedRange<Double>
    var step: Double
    var label: String
    var fillColor: Color = Color.accentColor

    @State private var initialDragX: CGFloat? = nil
    @State private var initialValue: Double = 0

    var body: some View {
        GeometryReader { geometry in
            let width = geometry.size.width
            let percentage = CGFloat((value - range.lowerBound) / (range.upperBound - range.lowerBound))
            let fillWidth = width * percentage

            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(UIColor.systemGray5))
                    .frame(height: 60)

                RoundedRectangle(cornerRadius: 12)
                    .fill(fillColor)
                    .frame(width: fillWidth, height: 60)
                    .animation(.easeInOut(duration: 0.15), value: value)

                Text("\(label): \(formatCurrency(value))")
                    .font(.system(size: 18, weight: .bold, design: .monospaced))
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .frame(height: 60, alignment: .leading)
            }
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { gesture in
                        if initialDragX == nil {
                            initialDragX = gesture.startLocation.x
                            initialValue = value
                        }

                        let deltaX = gesture.translation.width
                        let ratioDelta = deltaX / width
                        let valueDelta = Double(ratioDelta) * (range.upperBound - range.lowerBound)
                        let rawNewValue = initialValue + valueDelta
                        let steppedValue = (rawNewValue / step).rounded() * step
                        self.value = min(max(range.lowerBound, steppedValue), range.upperBound)
                    }
                    .onEnded { _ in
                        initialDragX = nil
                    }
            )
        }
        .frame(height: 60)
        .cornerRadius(12)
        .padding(.horizontal)
    }

    private func formatCurrency(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = ","
        formatter.maximumFractionDigits = 0
        return "$\(formatter.string(from: NSNumber(value: value)) ?? "\(Int(value))")"
    }
}

// MARK: - ContentView
struct ContentView: View {
    @State private var carPrice: Double = 30000
    @State private var accessories: Double = 5000
    @State private var serviceContract: Bool = false
    @State private var gap: Bool = false
    @State private var cashDown: Double = 2000
    @State private var tradeIn: Double = 0
    @State private var budget: Double = 500

    @State private var advancedSettingsExpanded: Bool = false
    @State private var gapCost: Double = 1000
    @State private var serviceContractCost: Double = 3000
    @State private var stateTaxRate: Double = 6.875
    @State private var titleLicenseCost: Double = 500

    @State private var termFinanceTaxRates: [Int: Double] = [36: 3.5, 48: 4.0, 60: 4.5, 72: 5.0, 84: 5.5]

    let termOptions: [Int] = [36, 48, 60, 72, 84]

    var baseTotal: Double {
        carPrice + accessories + (serviceContract ? serviceContractCost : 0) + (gap ? gapCost : 0) + titleLicenseCost
    }

    var body: some View {
        NavigationView {
            ScrollView {
                // Advanced Settings
                Group {
                    DisclosureGroup("Advanced", isExpanded: $advancedSettingsExpanded) {
                        VStack(spacing: 12) {
                            iOSStyledSlider(value: $serviceContractCost, range: 0...5000, step: 100, label: "Service Contract Cost")
                            iOSStyledSlider(value: $gapCost, range: 0...5000, step: 100, label: "GAP Cost")
                            iOSStyledSlider(value: $stateTaxRate, range: 0...20, step: 0.125, label: "State Tax Rate")
                            iOSStyledSlider(value: $titleLicenseCost, range: 0...2000, step: 50, label: "Title & License")
                        }
                        .padding(.top, 4)
                    }
                    .padding(.horizontal)
                }
                // Payment Options
                ZStack {
                    Color.gray.opacity(0.15)
                    VStack {
                        Group {
                            Text("Payment Options")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .padding(.horizontal)

                            PaymentTableView(
                                baseTotal: baseTotal,
                                tradeIn: tradeIn,
                                stateTaxRate: stateTaxRate,
                                termOptions: termOptions,
                                cashDownValue: cashDown,
                                monthlyBudget: budget,
                                termFinanceTaxRates: $termFinanceTaxRates
                            )
                        }
                    }
                    .padding(.vertical, 8)
                    

                }


                // Budget (no background)
                Group {
//                        Text("Budget")
//                            .font(.subheadline)
//                            .fontWeight(.semibold)
//                            .padding(.horizontal)
                    iOSStyledSlider(value: $budget, range: 0...1000, step: 10, label: "Monthly Budget")
                }
                .padding(.top, 75)
                .padding(.bottom, 25)
                .padding(.horizontal, 50)

                    // Payment Details with light green background
                    ZStack {
                        Color.green.opacity(0.15)
//                            .cornerRadius(12)
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Payment Details")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .padding(.horizontal)

                            iOSStyledSlider(value: $cashDown, range: 0...20000, step: 100, label: "Cash Down", fillColor: .green)
                            iOSStyledSlider(value: $tradeIn, range: 0...50000, step: 100, label: "Trade-In", fillColor: .green)
                        }
                        .padding(.vertical, 6)
                    }
//                    .padding(.horizontal)
//                    .padding(.vertical, 0)


                VStack(alignment: .leading, spacing: 10) {
                    // Vehicle Details with light red background
                    ZStack {
                        Color.red.opacity(0.15)
//                            .cornerRadius(12)
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Vehicle Details")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .padding(.horizontal)

                            iOSStyledSlider(value: $carPrice, range: 0...100000, step: 100, label: "Vehicle", fillColor: .red)
                            iOSStyledSlider(value: $accessories, range: 0...10000, step: 100, label: "Accessories", fillColor: .red)

                            HStack {
                                Toggle("Service Contract", isOn: $serviceContract).padding(.horizontal, 20)
                                Spacer()
                                Toggle("GAP", isOn: $gap).padding(.horizontal, 35)
                            }
                            .padding(.horizontal)
                        }
                        .padding(.vertical, 4)
                    }
//                    .padding(.horizontal)
//                    .padding(.vertical, 0)






                    Spacer()
                }
                .padding(.bottom)
            }
//            .navigationTitle("Payment Calculator")
        }
    }
}

// MARK: - Format Helper
func formatNumber(_ value: Double) -> String {
    if value < 1000 {
        return String(format: "%.0f", value)
    } else {
        let valueInK = value / 1000.0
        if valueInK == floor(valueInK) {
            return String(format: "%.0fk", valueInK)
        } else {
            return String(format: "%.1fk", valueInK)
        }
    }
}

// MARK: - Payment Table View
struct PaymentTableView: View {
    let baseTotal: Double
    let tradeIn: Double
    let stateTaxRate: Double
    let termOptions: [Int]
    let cashDownValue: Double
    let monthlyBudget: Double
    @Binding var termFinanceTaxRates: [Int: Double]

    @State private var editingTerm: Int? = nil

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
                        Group {
                            if payment < monthlyBudget {
                                Text("$\(payment, specifier: "%.0f")")
                                    .foregroundColor(.green)
                                    .bold()
                            } else {
                                Text("$\(payment, specifier: "%.0f")")
                                    .foregroundColor(.red)
                            }
                        }
                        .font(.footnote)
                        .frame(maxWidth: .infinity)
                    }
                }
            }
        }
        .padding(.horizontal)
    }
}

// MARK: - Payment Header Cell
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

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
