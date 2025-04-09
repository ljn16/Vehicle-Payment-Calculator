//
//  iOSStyledSlider.swift
//  Vehicle Payment Calculator
//
//  Created by Logan Nelsen on 4/9/25.
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
                    .opacity(0.7)
                    .frame(height: 60)

                RoundedRectangle(cornerRadius: 12)
                    .fill(fillColor)
                    .frame(width: fillWidth, height: 60)
                    .animation(.easeInOut(duration: 0.15), value: value)

                VStack(alignment: .leading, spacing: 2) {
                    Text(label)
                        .font(.system(size: 14, weight: .medium, design: .monospaced))
                        .foregroundColor(.white)
                    Text(formatCurrency(value))
                        .font(.system(size: 18, weight: .bold, design: .monospaced))
                        .foregroundColor(.white)
                }
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
}
