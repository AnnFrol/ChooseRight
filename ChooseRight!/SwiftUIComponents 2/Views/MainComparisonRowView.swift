//
//  MainComparisonRowView.swift
//  ChooseRight!
//
//  SwiftUI version of MainTableViewCell
//

import SwiftUI

struct MainComparisonRowView: View {
    let comparison: ComparisonEntity
    
    var body: some View {
        HStack(spacing: 16) {
            Image("elipseIcon")
                .renderingMode(.template)
                .foregroundColor(Color(comparison.color ?? "specialOne"))
                .frame(width: 29, height: 29)
            
            Text(comparison.unwrappedName)
                .font(.sfProTextRegular16())
                .foregroundColor(Color.specialColors.text)
            
            Spacer()
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 12)
        .background(Color.specialColors.subviewBackground)
        .cornerRadius(10)
    }
}

#Preview("Comparison Row - Light") {
    VStack(spacing: 10) {
        // Note: These previews use empty ComparisonEntity
        // For better previews, create test data in your CoreData
        MainComparisonRowView(comparison: ComparisonEntity())
        MainComparisonRowView(comparison: ComparisonEntity())
        MainComparisonRowView(comparison: ComparisonEntity())
    }
    .padding()
    .background(Color.specialColors.background)
    .preferredColorScheme(.light)
}

#Preview("Comparison Row - Dark") {
    VStack(spacing: 10) {
        MainComparisonRowView(comparison: ComparisonEntity())
        MainComparisonRowView(comparison: ComparisonEntity())
    }
    .padding()
    .background(Color.specialColors.background)
    .preferredColorScheme(.dark)
}

