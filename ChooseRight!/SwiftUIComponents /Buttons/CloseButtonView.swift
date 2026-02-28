//
//  CloseButtonView.swift
//  ChooseRight!
//
//  SwiftUI version of CloseButton
//

import SwiftUI

struct CloseButtonView: View {
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: "xmark.circle.fill")
                .font(.system(size: 22, weight: .medium))
                .symbolRenderingMode(.hierarchical)
                .foregroundStyle(.primary)
        }
        .frame(width: 29, height: 29)
    }
}

#Preview("Close Button") {
    HStack {
        CloseButtonView(action: {})
        Text("Close Button")
            .font(.caption)
    }
    .padding()
    .background(Color.specialColors.background)
}

#Preview("Close Button - Dark") {
    CloseButtonView(action: {})
        .padding()
        .background(Color.specialColors.background)
        .preferredColorScheme(.dark)
}

