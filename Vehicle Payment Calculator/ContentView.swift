//
//  ContentView.swift
//  Vehicle Payment Calculator
//
//  Created by Logan Nelsen on 3/28/25.
//
import SwiftUI

struct ContentView: View {
    
    @Environment(\.colorScheme) var colorScheme
    
    // MARK: - States
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
    
// MARK: - Views
    var body: some View {
        NavigationView {
            ZStack {
                
                // MARK: - Background
                LinearGradient(
                    gradient: Gradient(colors:
                        colorScheme == .dark
                        ? [Color.blue.opacity(0.5), Color.black]
                        : [Color.white, Color.blue.opacity(0.7)]
                    ),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()

                ScrollView {
                    
                    VStack(spacing: 10) {
//                        Text("Vehicle Payment Calculator")
//                            .font(.title)

                        VStack(spacing: -15){
                            
                            // MARK: - Advanced
                            DisclosureGroup("Advanced", isExpanded: $advancedSettingsExpanded) {
                                VStack(spacing: 12) {
                                    iOSStyledSlider(value: $serviceContractCost, range: 0...5000, step: 100, label: "Service Contract Cost")
                                    iOSStyledSlider(value: $gapCost, range: 0...5000, step: 100, label: "GAP Cost")
                                    iOSStyledSlider(
                                        value: $stateTaxRate,
                                        range: 0...7.5,
                                        step: 0.1,
                                        label: "State Tax Rate \(stateTaxRate == 6.875 ? "(MN)" : "(Custom)")",
                                        valueFormatter: { String(format: "%.2f%%", $0) }
                                    )
                                    iOSStyledSlider(value: $titleLicenseCost, range: 0...2000, step: 50, label: "Title & License")
                                }
                            }
                            .padding()
                            
                            // MARK: - Table
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

                        
                        Spacer()
                        Spacer()
                        Spacer()

                    // MARK: - Sliders

                        
                        // MARK: - (-)
                        ZStack {
                            VStack {
                                iOSStyledSlider(value: $carPrice, range: 0...100000, step: 100, label: "Vehicle Price", fillColor: .red)
                                iOSStyledSlider(value: $accessories, range: 0...10000, step: 100, label: "Accessories", fillColor: .red)

                                // Toggles
                                HStack {
                                    Toggle("Service Contract", isOn: $serviceContract)
                                        .padding(.horizontal)
                                        .tint(Color.red)
                                        .shadow(color: Color.red.opacity(0.5), radius: 20, x: 0, y: 4)

                                    Toggle("GAP", isOn: $gap)
                                        .padding(.horizontal)
                                        .tint(Color.red)
                                        .shadow(color: Color.red.opacity(0.5), radius: 20, x: 0, y: 4)
                                }
                                .shadow(color: Color.red.opacity(0.5), radius: 20, x: 0, y: 4)
                            }
                            .padding(6)
                            .cornerRadius(12)
                            .shadow(color: Color.red.opacity(0.5), radius: 20, x: 0, y: 4)

                            // Combined
                            Capsule()
                                .fill(Color.red.opacity(0.5))
                                .frame(width: 85, height: 25)
                                .overlay(
                                    Text("+  \(Int(carPrice + accessories).formatted(.number.grouping(.automatic)))")
                                        .foregroundColor(.white)
                                        .font(.caption)
                                        .opacity(0.8)

                                )
                                .offset(y: -27) // Adjust based on visual alignment
                                .shadow(radius: 5)

                        }
                        .padding(6)
//                        .background(Color.red.opacity(0.01))
//                        .overlay(
//                            RoundedRectangle(cornerRadius: 12)
//                                .stroke(Color.red.opacity(0.2), lineWidth: 1)
//                        )
                        .cornerRadius(12)
                        .shadow(color: Color.red.opacity(0.5), radius: 20, x: 0, y: 4)

                        // MARK: - (+)
                        // Green Sliders
                        ZStack{
                            VStack{
                                iOSStyledSlider(value: $cashDown, range: 0...20000, step: 100, label: "Cash Down", fillColor: .green)
                                iOSStyledSlider(value: $tradeIn, range: 0...50000, step: 100, label: "Trade-In", fillColor: .green)
                            }
                            .padding(6)
    //                        .background(Color.green.opacity(0.01))
    //                        .overlay(
    //                            RoundedRectangle(cornerRadius: 12)
    //                                .stroke(Color.red.opacity(0.2), lineWidth: 1)
    //                        )
                            .cornerRadius(12)
                            .shadow(color: Color.green.opacity(0.5), radius: 20, x: 0, y: 4)
                            
                            // Combined value
                            Capsule()
                                .fill(Color.green.opacity(0.2))
                                .frame(width: 80, height: 25)
                                .overlay(
                                    Text("-  \((cashDown + tradeIn).formatted(.number.grouping(.automatic)))")
                                        .foregroundColor(.white)
                                        .font(.caption)
                                        .opacity(0.8)
                                    
                                )
                                .offset(y: 0) // Slight overlap
                                .shadow(radius: 5)
                        }
                    }
                    
                    // Budget Slider
                    Spacer()
                    Spacer()
                    Spacer()
                    Spacer()
                    Spacer()

                    HStack {
                        Spacer()
                        
                        VStack(alignment: .center, spacing: 15) {
                            // Centered value capsule
                            Text(budget.formatted(.currency(code: "USD").precision(.fractionLength(0))))
                                .font(.title3)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(Color.blue)
                                .clipShape(Capsule())

                            // Slider
                            Slider(value: $budget, in: 0...1000, step: 10)
                                .accentColor(.blue)
                                .frame(height: 22)
                                .shadow(color: .blue.opacity(0.5), radius: 10)

                            // Centered label
                            Text("Monthly Budget")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.8))
                                .frame(maxWidth: .infinity, alignment: .center)

                        }
                        .frame(maxWidth: 250)
                        
                        Spacer()
                    }
                }
            }
        }
    }
}




// MARK: - ********************************************* PREVIEW *********************************************
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
