//
//  PreviewHelpers.swift
//  ChooseRight!
//
//  Helper functions and mocks for SwiftUI Previews
//

import SwiftUI
import CoreData

// MARK: - Mock ComparisonEntity for Previews
extension ComparisonEntity {
    static func previewMock(name: String = "Test Comparison", color: String = "specialOne") -> ComparisonEntity {
        // Create a mock entity for preview purposes
        // Note: This won't work with real CoreData, but helps with previews
        let entity = ComparisonEntity()
        // Since we can't easily create NSManagedObject without context in preview,
        // we'll use a different approach
        return entity
    }
}

// MARK: - Preview Container
struct PreviewContainer<Content: View>: View {
    let content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        content
            .preferredColorScheme(.light)
    }
}

// MARK: - Dark Mode Preview
struct DarkPreviewContainer<Content: View>: View {
    let content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        content
            .preferredColorScheme(.dark)
    }
}

