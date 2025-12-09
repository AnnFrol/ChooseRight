//
//  AddButtonView.swift
//  ChooseRight!
//
//  SwiftUI version of AddButton
//

import SwiftUI

struct AddButtonView: View {
    let action: () -> Void
    @State private var isRotating = false
    
    var body: some View {
        Button(action: {
            withAnimation(.easeInOut(duration: 0.3)) {
                isRotating.toggle()
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                withAnimation(.easeInOut(duration: 0.3)) {
                    isRotating.toggle()
                }
            }
            action()
        }) {
            Image("addButton")
                .resizable()
                .scaledToFit()
                .rotationEffect(.degrees(isRotating ? 180 : 0))
        }
    }
    
    func animateButton(delay: TimeInterval = 0) {
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            withAnimation(.easeInOut(duration: 0.3)) {
                isRotating = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                withAnimation(.easeInOut(duration: 0.3)) {
                    isRotating = false
                }
            }
        }
    }
}

#Preview("Add Button") {
    VStack(spacing: 20) {
        AddButtonView(action: {})
            .frame(width: 64, height: 64)
        
        Text("Tap to test animation")
            .font(.caption)
    }
    .padding()
    .background(Color.specialColors.background)
}

#Preview("Add Button - Dark") {
    VStack(spacing: 20) {
        AddButtonView(action: {})
            .frame(width: 64, height: 64)
    }
    .padding()
    .background(Color.specialColors.background)
    .preferredColorScheme(.dark)
}

