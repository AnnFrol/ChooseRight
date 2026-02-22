//
//  AddAttributeButtonView.swift
//  ChooseRight!
//
//  SwiftUI version of AddAttributeButton
//

import SwiftUI

struct AddAttributeButtonView: View {
    let title: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.sfProTextRegular14())
                .foregroundColor(Color.specialColors.detailsOptionTableText.opacity(0.6))
                .frame(maxWidth: .infinity, alignment: .trailing)
        }
    }
}

#Preview("Add Attribute Button") {
    VStack(spacing: 20) {
        AddAttributeButtonView(title: "+ Add attribute", action: {})
    }
    .padding()
    .background(Color.specialColors.background)
    .frame(width: 200)
}

#Preview("Add Attribute - Dark") {
    AddAttributeButtonView(title: "+ Add attribute", action: {})
        .padding()
        .background(Color.specialColors.background)
        .preferredColorScheme(.dark)
        .frame(width: 200)
}

