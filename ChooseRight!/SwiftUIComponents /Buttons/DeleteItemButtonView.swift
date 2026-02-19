//
//  DeleteItemButtonView.swift
//  ChooseRight!
//
//  SwiftUI version of DeleteItemButton
//

import SwiftUI

struct DeleteItemButtonView: View {
    let title: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.sfProTextRegular16())
                .foregroundColor(.red)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.specialColors.subviewBackground)
                .cornerRadius(10)
        }
    }
}

#Preview("Delete Button") {
    VStack(spacing: 20) {
        DeleteItemButtonView(title: "Delete item", action: {})
        DeleteItemButtonView(title: "Удалить элемент", action: {})
    }
    .padding()
    .background(Color.specialColors.background)
    .frame(width: 300)
}

#Preview("Delete Button - Dark") {
    DeleteItemButtonView(title: "Delete item", action: {})
        .padding()
        .background(Color.specialColors.background)
        .preferredColorScheme(.dark)
        .frame(width: 300)
}

