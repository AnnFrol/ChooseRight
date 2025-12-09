////
////extension ComparisonListViewController {
////    private func setConstraints() {
////        
////        attributesCVLeadingAnchor = attributesCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 240)
////        
////        NSLayoutConstraint.activate([
////            
////     addAttributeButton.heightAnchor.constraint(equalToConstant: 45),
////CollectionView.bottomAnchor),
////            
////            backButton.widthAnchor.constraint(equalToConstant: 33),
////            settingsButton.widthAnchor.constraint(equalToConstant: 33),
////            
////            titleStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
////            titleStackView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.9),
////            titleStackView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.05),
////            titleStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
////            
////            attributesCVLeadingAnchor!,
////            attributesCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
////            attributesCollectionView.heightAnchor.constraint(equalToConstant: 40),
////            attributesCollectionView.topAnchor.constraint(equalTo: titleStackView.bottomAnchor, constant: 10),
////            
////            valuesCollectionView.topAnchor.constraint(equalTo: attributesCollectionView.bottomAnchor, constant: 0),
////            valuesCollectionView.leadingAnchor.constraint(equalTo: attributesCollectionView.leadingAnchor),
////            valuesCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
////            valuesCollectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 0),
////            
////            objectTableView.topAnchor.constraint(equalTo: valuesCollectionView.topAnchor),
////            objectTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 15),
////            objectTableView.bottomAnchor.constraint(equalTo: valuesCollectionView.bottomAnchor),
////            objectTableView.trailingAnchor.constraint(equalTo: valuesCollectionView.leadingAnchor, constant: -10),
////     
////            addAttributeButton.centerYAnchor.constraint(equalTo: attributesCollectionView.centerYAnchor),
////            addAttributeButton.trailingAnchor.constraint(equalTo: objectTableView.trailingAnchor),
////            addAttributeButton.heightAnchor.constraint(equalToConstant: 33),
////            addAttributeButton.widthAnchor.constraint(equalToConstant: 33),
////            
////            addButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -24),
////            addButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
////            addButton.heightAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.17),
////            addButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.17),
////        ])
////    }
////}
//
////MARK: - Constraints
//extension ComparisonListViewController {
//     func setConstraints() {
//        
//        minConstraintConstant = view.frame.width * 0.25
//        midleConstraintConstant = view.frame.width * 0.5
//        maxConstraintConstant = view.frame.width * 0.7
//        
//        animatedConstraint = valuesCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: maxConstraintConstant)
//        
//        NSLayoutConstraint.activate([
//                        
//            backButton.widthAnchor.constraint(equalToConstant: 33),
//            settingsButton.widthAnchor.constraint(equalToConstant: 33),
//            
//            titleStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
//            titleStackView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.9),
//            titleStackView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.05),
//            titleStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
//            
//            addAttributeButton.topAnchor.constraint(equalTo: titleStackView.bottomAnchor, constant: 10),
//            addAttributeButton.heightAnchor.constraint(equalToConstant: 50),
//            addAttributeButton.trailingAnchor.constraint(equalTo: objectTableView.trailingAnchor),
////            addAttributeButton.bottomAnchor.constraint(equalTo: objectTableView.topAnchor),
//            
//            objectTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 15),
//            objectTableView.topAnchor.constraint(equalTo: addAttributeButton.bottomAnchor),
//            objectTableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 0),
//            objectTableView.trailingAnchor.constraint(equalTo: valuesCollectionView.leadingAnchor),
//            
//            attributesCollectionView.topAnchor.constraint(equalTo: addAttributeButton.topAnchor),
//            attributesCollectionView.heightAnchor.constraint(equalToConstant: 50),
//            attributesCollectionView.leadingAnchor.constraint(equalTo: valuesCollectionView.leadingAnchor),
//            attributesCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
//            
//            animatedConstraint!,
//            valuesCollectionView.topAnchor.constraint(equalTo: addAttributeButton.bottomAnchor),
//            valuesCollectionView.trailingAnchor.constraint(equalTo: attributesCollectionView.trailingAnchor),
//            valuesCollectionView.bottomAnchor.constraint(equalTo: objectTableView.bottomAnchor),
//            
//            addButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -24),
//            addButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
//            addButton.heightAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.17),
//            addButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.17),
//            
//            editingDoneButton.leadingAnchor.constraint(equalTo: objectTableView.leadingAnchor, constant: 5),
//            editingDoneButton.bottomAnchor.constraint(equalTo: objectTableView.topAnchor),
//            editingDoneButton.heightAnchor.constraint(equalTo: addAttributeButton.heightAnchor, multiplier: 1),
////            editingDoneButton.widthAnchor.constraint(equalToConstant: valueCVCellWidth)
////            editingDoneButton.centerYAnchor.constraint(equalTo: addAttributeButton.centerYAnchor)
//            
//            shadowTop.topAnchor.constraint(equalTo: view.topAnchor),
//            shadowTop.bottomAnchor.constraint(equalTo: attributesCollectionView.topAnchor, constant: -5),
//            shadowTop.leadingAnchor.constraint(equalTo: view.leadingAnchor),
//            shadowTop.trailingAnchor.constraint(equalTo: view.trailingAnchor),
//            
//            shadowBottom.topAnchor.constraint(equalTo: attributesCollectionView.bottomAnchor),
//            shadowBottom.bottomAnchor.constraint(equalTo: view.bottomAnchor),
//            shadowBottom.leadingAnchor.constraint(equalTo: view.leadingAnchor),
//            shadowBottom.trailingAnchor.constraint(equalTo: view.trailingAnchor)
//        ])
//    }
//}
//
