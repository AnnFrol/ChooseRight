//
//  MainView.swift
//  ChooseRight!
//
//  SwiftUI version of MainViewController
//

import SwiftUI
import CoreData

struct MainView: View {
    @StateObject private var viewModel = MainViewModel()
    @State private var showCreateAlert = false
    @State private var showDeleteAlert = false
    @State private var showRenameAlert = false
    @State private var selectedComparison: ComparisonEntity?
    @State private var newComparisonName = ""
    @State private var renameText = ""
    @State private var showErrorAlert = false
    @State private var errorMessage = ""
    
    // Callback for navigation
    var onComparisonSelected: ((ComparisonEntity) -> Void)?
    var onNewComparisonCreated: ((ComparisonEntity) -> Void)?
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.specialColors.background
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Header
                    HStack {
                        Text(NSLocalizedString("Choose Right", comment: ""))
                            .font(.sfProTextBold33())
                            .foregroundColor(Color.specialColors.text)
                            .kerning(-1.37)
                        
                        Spacer()
                        
                        Button(action: {
                            viewModel.showSettingsMenu()
                        }) {
                            Image(systemName: "ellipsis")
                                .font(.system(size: 26, weight: .regular))
                                .foregroundColor(Color.specialColors.text)
                        }
                        .frame(width: 33, height: 33)
                    }
                    .padding(.horizontal, 15)
                    .padding(.top, 10)
                    
                    // Content
                    if viewModel.comparisons.isEmpty {
                        // Placeholder
                        VStack(spacing: 40) {
                            Text(NSLocalizedString("Tap the button to create your first comparison", comment: ""))
                                .font(.sfProTextMedium24())
                                .foregroundColor(Color.specialColors.detailsOptionTableText)
                                .multilineTextAlignment(.leading)
                                .padding(.horizontal)
                            
                            Image("MainViewPlaceholder")
                                .renderingMode(.template)
                                .foregroundColor(Color.specialColors.detailsOptionTableText)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else {
                        // List of comparisons
                        ScrollView {
                            LazyVStack(spacing: 5) {
                                ForEach(Array(viewModel.comparisons.enumerated()), id: \.element.objectID) { index, comparison in
                                    MainComparisonRowView(comparison: comparison)
                                        .onTapGesture {
                                            onComparisonSelected?(comparison)
                                        }
                                        .contextMenu {
                                            Button(action: {
                                                selectedComparison = comparison
                                                renameText = comparison.unwrappedName
                                                showRenameAlert = true
                                            }) {
                                                Label(NSLocalizedString("Change name", comment: ""), systemImage: "pencil")
                                            }
                                            
                                            Button(action: {
                                                viewModel.changeColor(for: comparison)
                                            }) {
                                                Label(NSLocalizedString("Change color", comment: ""), systemImage: "paintpalette")
                                            }
                                            
                                            Button(role: .destructive, action: {
                                                selectedComparison = comparison
                                                showDeleteAlert = true
                                            }) {
                                                Label(NSLocalizedString("Delete", comment: ""), systemImage: "trash")
                                            }
                                        }
                                }
                            }
                            .padding(.horizontal, 15)
                            .padding(.top, 20)
                            .padding(.bottom, 100)
                        }
                    }
                }
                
                // Add Button
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button(action: { showCreateAlert = true }) {
                            Image(systemName: "plus")
                                .font(.system(size: 22, weight: .regular))
                                .foregroundColor(.black)
                                .frame(width: 64, height: 64)
                                .background(Color.specialColors.threeBlueLavender)
                                .clipShape(Circle())
                        }
                        .padding(.trailing, 24)
                        .padding(.bottom, 24)
                    }
                }
            }
            .navigationBarHidden(true)
            .onAppear {
                viewModel.loadData()
            }
            .alert(NSLocalizedString("Create new comparison", comment: ""), isPresented: $showCreateAlert) {
                TextField(NSLocalizedString("Comparison name", comment: ""), text: $newComparisonName)
                Button(NSLocalizedString("Cancel", comment: ""), role: .cancel) {
                    newComparisonName = ""
                }
                Button(NSLocalizedString("Start", comment: "")) {
                    viewModel.createComparison(name: newComparisonName) { result in
                        switch result {
                        case .success(let comparison):
                            newComparisonName = ""
                            onNewComparisonCreated?(comparison)
                        case .failure(let error):
                            errorMessage = error.localizedDescription
                            showErrorAlert = true
                        }
                    }
                }
                .disabled(newComparisonName.trimmingCharacters(in: .whitespaces).isEmpty)
            } message: {
                Text(NSLocalizedString("Enter a name for your comparison", comment: ""))
            }
            .alert(NSLocalizedString("Error", comment: ""), isPresented: $showErrorAlert) {
                Button(NSLocalizedString("OK", comment: ""), role: .cancel) {}
            } message: {
                Text(errorMessage)
            }
            .alert(NSLocalizedString("Delete comparison?", comment: ""), isPresented: $showDeleteAlert) {
                Button(NSLocalizedString("Cancel", comment: ""), role: .cancel) {}
                Button(NSLocalizedString("Delete", comment: ""), role: .destructive) {
                    if let comparison = selectedComparison {
                        viewModel.deleteComparison(comparison)
                    }
                }
            }
            .alert(NSLocalizedString("Rename your comparison", comment: ""), isPresented: $showRenameAlert) {
                TextField(NSLocalizedString("New name", comment: ""), text: $renameText)
                Button(NSLocalizedString("Cancel", comment: ""), role: .cancel) {
                    renameText = ""
                }
                Button(NSLocalizedString("Save", comment: "")) {
                    if let comparison = selectedComparison {
                        viewModel.renameComparison(comparison, newName: renameText)
                    }
                    renameText = ""
                }
                .disabled(renameText.trimmingCharacters(in: .whitespaces).isEmpty)
            }
        }
    }
}

// MARK: - Error Type
enum ComparisonError: Error, LocalizedError {
    case nameAlreadyInUse(String)
    case creationFailed
    
    var errorDescription: String? {
        switch self {
        case .nameAlreadyInUse(let name):
            let emoji = ["😉", "💁‍♂️", "👻", "🙀", "🥈", "🚧", "❣️", "🥸", "👯", "🙃", "🧐", "🤓", "🤔"].randomElement() ?? ""
            return "\(emoji) \"\(name)\" already in use"
        case .creationFailed:
            return "Failed to create comparison"
        }
    }
}

// MARK: - ViewModel
class MainViewModel: ObservableObject {
    @Published var comparisons: [ComparisonEntity] = []
    
    private let sharedDataBase = CoreDataManager.shared
    
    func loadData() {
        comparisons = sharedDataBase.fetchAllComparisons()
        comparisons.sort { $0.unwrappedDate > $1.unwrappedDate }
    }
    
    func createComparison(name: String, completion: @escaping (Result<ComparisonEntity, ComparisonError>) -> Void) {
        // Check if name is already used
        let comparisonsNames = comparisons.map { $0.unwrappedName }
        if comparisonsNames.contains(name) {
            completion(.failure(.nameAlreadyInUse(name)))
            return
        }
        
        var currentColor = specialColors[0]
        
        switch comparisons.count {
        case 0:
            currentColor = specialColors[0]
        case 1...:
            let lastColor = comparisons.first?.color ?? specialColors[0]
            if let currentColorIndex = specialColors.firstIndex(of: lastColor) {
                currentColor = specialColors[(currentColorIndex + 1) % specialColors.count]
            }
        default:
            currentColor = specialColors[0]
        }
        
        if let comparisonId = sharedDataBase.createComparison(name: name, color: currentColor),
           let comparison = sharedDataBase.fetchComparisonWithID(id: comparisonId) {
            loadData()
            completion(.success(comparison))
        } else {
            completion(.failure(.creationFailed))
        }
    }
    
    func deleteComparison(_ comparison: ComparisonEntity) {
        sharedDataBase.deleteComparison(comparison: comparison)
        loadData()
    }
    
    func renameComparison(_ comparison: ComparisonEntity, newName: String) {
        let comparisonsNames = comparisons.map { $0.unwrappedName }
        if !comparisonsNames.contains(newName) {
            _ = sharedDataBase.updateComparisonName(for: comparison, newName: newName)
            loadData()
        }
    }
    
    func changeColor(for comparison: ComparisonEntity) {
        guard let oldColor = comparison.color else {
            comparison.color = specialColors.first
            return
        }
        guard let oldColorIndex = specialColors.firstIndex(of: oldColor) else {
            comparison.color = specialColors.first
            return
        }
        let newColorIndex = (oldColorIndex + 1) % specialColors.count
        let newColorName = specialColors[newColorIndex]
        sharedDataBase.updateComparisonColor(for: comparison, color: newColorName)
        loadData()
    }
    
    func navigateToComparison(_ comparison: ComparisonEntity) {
        // This will be handled by the parent view controller
        // For now, we'll use a callback or notification
    }
    
    func showSettingsMenu() {
        // Implementation will be added
    }
}

#Preview("MainView - Empty State") {
    MainView()
        .preferredColorScheme(.light)
}

#Preview("MainView - Dark Mode") {
    MainView()
        .preferredColorScheme(.dark)
}

#Preview("MainView - With Data") {
    let viewModel = MainViewModel()
    // Note: This preview will show empty state unless you have data in your CoreData
    // To test with data, run the app first to create some comparisons
    MainView()
        .onAppear {
            viewModel.loadData()
        }
}

