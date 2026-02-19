//
//  PlusMinusButtonView.swift
//  ChooseRight!
//
//  SwiftUI version of PlusMinusButton
//

import SwiftUI

struct PlusMinusButtonView: View {
    let isValueTrue: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(isValueTrue ? "+" : "-")
                .font(.sfProTextRegular23())
                .foregroundColor(Color.specialColors.text.opacity(0.6))
        }
    }
}

#Preview("Plus/Minus Buttons") {
    HStack(spacing: 30) {
        VStack {
            PlusMinusButtonView(isValueTrue: true, action: {})
            Text("Plus")
                .font(.caption)
        }
        VStack {
            PlusMinusButtonView(isValueTrue: false, action: {})
            Text("Minus")
                .font(.caption)
        }
    }
    .padding()
    .background(Color.specialColors.background)
}

#Preview("Plus/Minus - Dark") {
    HStack(spacing: 30) {
        PlusMinusButtonView(isValueTrue: true, action: {})
        PlusMinusButtonView(isValueTrue: false, action: {})
    }
    .padding()
    .background(Color.specialColors.background)
    .preferredColorScheme(.dark)
}

