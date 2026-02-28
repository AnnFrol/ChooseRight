//
//  AllComponentsPreview.swift
//  ChooseRight!
//
//  Comprehensive preview showing all SwiftUI components together
//

import SwiftUI

struct AllComponentsPreview: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 30) {
                // Header
                Text("SwiftUI Components Preview")
                    .font(.sfProTextBold33())
                    .padding()
                
                // Buttons Section
                VStack(alignment: .leading, spacing: 15) {
                    Text("Buttons")
                        .font(.sfProTextMedium24())
                        .padding(.horizontal)
                    
                    HStack(spacing: 20) {
                        Button(action: {}) {
                            Image(systemName: "plus")
                                .font(.system(size: 22, weight: .regular))
                                .foregroundColor(.black)
                                .frame(width: 64, height: 64)
                                .background(Color.specialColors.threeBlueLavender)
                                .clipShape(Circle())
                        }
                        
                        CloseButtonView(action: {})
                        
                        VStack {
                            PlusMinusButtonView(isValueTrue: true, action: {})
                            PlusMinusButtonView(isValueTrue: false, action: {})
                        }
                    }
                    .padding()
                    
                    DeleteItemButtonView(title: "Delete item", action: {})
                        .padding(.horizontal)
                    
                    AddAttributeButtonView(title: "+ Add attribute", action: {})
                        .padding(.horizontal)
                }
                .padding()
                .background(Color.specialColors.subviewBackground)
                .cornerRadius(10)
                
                // Comparison Row Section
                VStack(alignment: .leading, spacing: 15) {
                    Text("Comparison Rows")
                        .font(.sfProTextMedium24())
                        .padding(.horizontal)
                    
                    VStack(spacing: 5) {
                        MainComparisonRowView(comparison: ComparisonEntity())
                        MainComparisonRowView(comparison: ComparisonEntity())
                        MainComparisonRowView(comparison: ComparisonEntity())
                    }
                }
                .padding()
                .background(Color.specialColors.subviewBackground)
                .cornerRadius(10)
            }
            .padding()
        }
        .background(Color.specialColors.background)
    }
}

#Preview("All Components - Light") {
    AllComponentsPreview()
        .preferredColorScheme(.light)
}

#Preview("All Components - Dark") {
    AllComponentsPreview()
        .preferredColorScheme(.dark)
}

