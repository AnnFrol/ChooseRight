//
//  AlertsConfiguration.swift
//  ChooseRight!
//
//  Created by Александр Фрольцов on 22.07.2023.
//

import Foundation
import UIKit
import CoreData
//MARK: - Alerts configuration

extension MainViewController: UITextFieldDelegate {
    
    @objc private func textFieldChanged(_ sender: Any) {
        let textfield = sender as! UITextField
        guard let textfieldText = textfield.text else { return }
        let comparisonsNames: [String] = comparisonsArray.map { $0.unwrappedName }
        self.saveButtonInAlertChanged?.isEnabled = !textfieldText.trimmingCharacters(in: .whitespaces).isEmpty && !comparisonsNames.contains(textfieldText)
    }
    
    @objc private func aiTextFieldChanged(_ sender: Any) {
        let textfield = sender as! UITextField
        guard let textfieldText = textfield.text else { return }
        self.saveButtonInAlertChanged?.isEnabled = !textfieldText.trimmingCharacters(in: .whitespaces).isEmpty
    }
    
//MARK: alertsConfigurationForCreate
    func alertConfigurationForCreate() {

        //New comparison configuration
        let examplesMessage = """
        For example:
        • Compare New York and London by cost of living, technology, price.
        • Compare Apples, Pears, and Peaches.
        """
        self.createNewComparisonListAlert? = UIAlertController(
            title: "Create new comparison",
            message: examplesMessage,
            preferredStyle: .alert)
        
        createNewComparisonListAlert?.addTextField { alertTextfield in
            alertTextfield.autocapitalizationType = .sentences
            alertTextfield.clearButtonMode = .always
            alertTextfield.delegate = self
            alertTextfield.placeholder = "e.g. Compare 5 cities"
            alertTextfield.addTarget(self, action: #selector(self.textFieldChanged), for: .editingChanged)
        }
        
        let saveNewComparisonButton = UIAlertAction(title: "Start", style: .default) { [self, weak createNewComparisonListAlert] (_) in
                        
            // Check purchase status
            Task {
                await SubscriptionManager.shared.updatePurchasedStatus()
                
                let canCreate = SubscriptionManager.shared.canCreateComparison(freeComparisonsCount: self.comparisonsArray.count)
                
                await MainActor.run {
                    if !canCreate {
                        // Show subscription screen
                        createNewComparisonListAlert?.dismiss(animated: true) {
                            let subscriptionVC = SubscriptionViewController()
                            subscriptionVC.modalPresentationStyle = .pageSheet
                            if #available(iOS 15.0, *) {
                                if let sheet = subscriptionVC.sheetPresentationController {
                                    sheet.detents = [.large()]
                                    sheet.prefersGrabberVisible = true
                                }
                            }
                            self.present(subscriptionVC, animated: true)
                        }
                        return
                    }
                    
                    // Proceed with creation
                    var currentColor = specialColors[0]
            
                    switch self.comparisonsArray.count {
                
            case 0: currentColor = specialColors[0]
                
            case 1...:
                
                        let lastColor = self.comparisonsArray.first?.color ?? specialColors[0]
                let currentcolorindexis = specialColors.firstIndex(of: lastColor)
                currentColor = specialColors[(currentcolorindexis! + 1) % specialColors.count]
                
            default:
                currentColor = specialColors[0]
            }
            
            let textfieldText = createNewComparisonListAlert?.textFields?[0].text ?? "NoText"
                let trimmed = textfieldText.trimmingCharacters(in: .whitespacesAndNewlines)

                // Smart Import: Check if the text (or clipboard) contains a table
                if let _ = TableImportService.parseTableFromClipboard(textfieldText) {
                    createNewComparisonListAlert?.dismiss(animated: true) {
                        self.processTableImport(textfieldText)
                    }
                    return
                }

                // Если введён запрос на сравнение — отправляем в AI (в т.ч. "Compare 5 cities", "Compare X and Y by ...")
                let lower = trimmed.lowercased()
                let hasCompareKeyword = lower.contains("compare") || lower.contains("comparar") || lower.contains("comparer") || lower.contains("сравн")
                let hasExplicitList = lower.contains(" by ") || lower.contains(" по ") || lower.contains(" and ") || lower.contains(" и ") || lower.contains(" vs ")
                let hasGroupPrefix = lower.hasPrefix("compare ") && trimmed.count > 8
                    || lower.hasPrefix("comparar ") && trimmed.count > 9
                    || lower.hasPrefix("comparer ") && trimmed.count > 9
                    || lower.hasPrefix("сравни ") && trimmed.count > 7
                    || lower.hasPrefix("сравнить ") && trimmed.count > 9
                let looksLikeCompareRequest = hasCompareKeyword && (hasExplicitList || hasGroupPrefix)
                if looksLikeCompareRequest {
                    createNewComparisonListAlert?.dismiss(animated: true) {
                        self.processAIRequest(trimmed)
                    }
                    return
                }

                let savingResult = self.sharedDataBase.createComparison(name: trimmed, color: currentColor)
                
                if savingResult == nil {
                            let emoji = self.warningMessageEmoji.randomElement() ?? ""
                    createNewComparisonListAlert?.message =
                    "\(emoji) \"\(textfieldText)\" already in use"
                    
                    let generator = UINotificationFeedbackGenerator()
                    generator.notificationOccurred(.error)
                    
                            self.present(createNewComparisonListAlert ?? UIAlertController(), animated: true)
                } else {
                    
                    
                    let destination = ComparisonListViewController()
                            let comparison = self.sharedDataBase.fetchComparisonWithID(id: savingResult ?? "") ?? ComparisonEntity()
                    destination.setComparisonEntity(comparison: comparison)
                            self.navigationController?.pushViewController(destination, animation: true) {
                        destination.openDetailsForNewComparison()
                            }
                        }
                    }
                }
        }
        let cancelNewComparisonButton = UIAlertAction(title: "Cancel", style: .cancel)
        { _ in
            self.createNewComparisonListAlert?.dismiss(animated: true)

            self.createNewComparisonListAlert? = UIAlertController()
        }
        
        createNewComparisonListAlert?.addAction(saveNewComparisonButton)
        createNewComparisonListAlert?.addAction(cancelNewComparisonButton)
        saveButtonInAlertChanged = saveNewComparisonButton
        saveNewComparisonButton.isEnabled = false
    }
    
//MARK: alertsConfigurationForChangeName
    func alertConfigurationForChangeName(comparison: ComparisonEntity) {
        
        //New comparison configuration
        self.createNameChangingAlert? = UIAlertController(
            title: "The old name is no good?",
            message: "",
            preferredStyle: .alert)
        
        createNameChangingAlert?.addTextField { alertTextfield in
            alertTextfield.delegate = self
            alertTextfield.autocapitalizationType = .sentences
            alertTextfield.clearButtonMode = .always
            alertTextfield.text = comparison.unwrappedName
            alertTextfield.placeholder = "Rename your comparison!"
            alertTextfield.addTarget(self, action: #selector(self.textFieldChanged), for: .editingChanged)
        }
        
        let saveNewComparisonButton = UIAlertAction(title: "Save", style: .default) { [self, weak createNameChangingAlert] (_) in
            
            let textfieldText = createNameChangingAlert?.textFields?[0].text ?? "NoText"
            let savingResult = self.sharedDataBase.updateComparisonName(for: comparison, newName: textfieldText)
            
            if savingResult == true {
                self.tableView.reloadData()
            }
        }
        let cancelNewComparisonButton = UIAlertAction(title: "Cancel", style: .cancel)
        { _ in
            
            self.createNameChangingAlert?.view.window?.removeGestureRecognizer(self.dismissGesture)
            self.createNameChangingAlert?.dismiss(animated: true) {
                self.createNameChangingAlert?.view.window?.removeGestureRecognizer(self.dismissGesture)
            }
            self.createNameChangingAlert? = UIAlertController()
        }
        
        createNameChangingAlert?.addAction(saveNewComparisonButton)
        createNameChangingAlert?.addAction(cancelNewComparisonButton)
        saveButtonInAlertChanged = saveNewComparisonButton
        saveNewComparisonButton.isEnabled = false
    }
    
    func alertConfigurationForDeleteConfirmation(comparison: ComparisonEntity, index: Int ) {
        self.deleteComparisonConfirmationAlert? = UIAlertController(
            title: "Delete comparison?",
            message: "",
            preferredStyle: .actionSheet)
        
        let deleteButton = UIAlertAction(
            title: "Delete",
            style: .destructive) { [self] _ in
                self.deleteComparisonFromTable(comparison: comparison, index: index)
            }
        
        let cancelButton = UIAlertAction(
            title: "Cancel",
            style: .default)
        
        deleteComparisonConfirmationAlert?.addAction(deleteButton)
        deleteComparisonConfirmationAlert?.addAction(cancelButton)
        
        // Configure popover for iPad
        if let popover = deleteComparisonConfirmationAlert?.popoverPresentationController {
            popover.sourceView = view
            popover.sourceRect = CGRect(x: view.bounds.midX, y: view.bounds.midY, width: 0, height: 0)
            popover.permittedArrowDirections = []
        }
    }
    
    //MARK: AI Assistant Alert Configuration
    func alertConfigurationForAIAssistant() {
        let aiAlert = UIAlertController(
            title: "Generate",
            message: "Describe what you want to compare. For example: \"Compare New York and London by cost of living, technology, price, education opportunities\"",
            preferredStyle: .alert
        )
        
        aiAlert.addTextField { textField in
            textField.autocapitalizationType = .sentences
            textField.clearButtonMode = .always
            textField.delegate = self
            textField.placeholder = "e.g. Compare 5 cities"
            textField.addTarget(self, action: #selector(self.aiTextFieldChanged), for: .editingChanged)
        }
        
        let createButton = UIAlertAction(title: "Create", style: .default) { [weak self, weak aiAlert] _ in
            guard let self = self,
                  let textField = aiAlert?.textFields?.first,
                  let userRequest = textField.text?.trimmingCharacters(in: .whitespaces),
                  !userRequest.isEmpty else {
                return
            }
            
            self.processAIRequest(userRequest)
        }
        
        let cancelButton = UIAlertAction(title: "Cancel", style: .cancel)
        
        aiAlert.addAction(createButton)
        aiAlert.addAction(cancelButton)
        saveButtonInAlertChanged = createButton
        createButton.isEnabled = false
        
        present(aiAlert, animated: true)
    }
    
    private func processAIRequest(_ userRequest: String) {
        // Проверяем, является ли запрос таблицей (компактный формат или с разделителями)
        if isTableFormat(userRequest) {
            // Обрабатываем как таблицу через TableImportService
            processTableImport(userRequest)
            return
        }
        
        // Show loading indicator
        let loadingAlert = UIAlertController(
            title: "Processing Request",
            message: "Generating comparison...",
            preferredStyle: .alert
        )
        
        present(loadingAlert, animated: true)
        
        Task {
            do {
                let result = try await AIAssistantService.shared.processComparisonRequest(userRequest)
                
                await MainActor.run {
                    loadingAlert.dismiss(animated: true) {
                        self.createComparisonFromAIResult(result, userRequest: userRequest)
                    }
                }
            } catch {
                await MainActor.run {
                    loadingAlert.dismiss(animated: true) {
                        // Если ошибка парсинга JSON, все равно создаем сравнение с базовыми значениями
                        if error.localizedDescription.contains("couldn't be read") || 
                           error.localizedDescription.contains("correct format") {
                            // Пытаемся создать сравнение с базовыми значениями
                            self.createComparisonWithFallback(userRequest: userRequest, error: error)
                        } else {
                            self.showAIError(error)
                        }
                    }
                }
            }
        }
    }
    
    /// Проверяет, является ли запрос таблицей (компактный формат или с разделителями)
    private func isTableFormat(_ text: String) -> Bool {
        // Нормализуем текст
        let normalized = text.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Разбиваем на строки
        let lines = normalized.components(separatedBy: .newlines)
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }
        
        // Если есть несколько строк (2+), проверяем CSV/TSV формат
        if lines.count >= 2 {
            // Проверяем первую строку на наличие разделителей
            let firstLine = lines[0]
            
            // Подсчитываем запятые, точки с запятой, табуляции в первой строке
            let commaCount = firstLine.filter { $0 == "," }.count
            let semicolonCount = firstLine.filter { $0 == ";" }.count
            let tabCount = firstLine.filter { $0 == "\t" }.count
            
            // Если в первой строке много разделителей (3+), это похоже на CSV/TSV таблицу
            if commaCount >= 3 || semicolonCount >= 3 || tabCount >= 3 {
                // Проверяем, что во второй строке тоже есть разделители
                if lines.count > 1 {
                    let secondLine = lines[1]
                    let secondCommaCount = secondLine.filter { $0 == "," }.count
                    let secondSemicolonCount = secondLine.filter { $0 == ";" }.count
                    let secondTabCount = secondLine.filter { $0 == "\t" }.count
                    
                    // Если во второй строке тоже есть разделители, это таблица
                    if secondCommaCount >= 1 || secondSemicolonCount >= 1 || secondTabCount >= 1 {
                        return true
                    }
                }
            }
            
            // Проверяем наличие "+" и "-" в нескольких строках (признак таблицы с значениями)
            let plusCount = normalized.filter { $0 == "+" }.count
            let minusCount = normalized.filter { $0 == "-" }.count
            let totalValues = plusCount + minusCount
            
            // Если есть много "+" и "-" и несколько строк, это таблица
            if totalValues >= 4 && lines.count >= 2 {
                return true
            }
        }
        
        // Проверяем наличие множества "+" и "-" (признак таблицы с значениями)
        let plusCount = normalized.filter { $0 == "+" }.count
        let minusCount = normalized.filter { $0 == "-" }.count
        let totalValues = plusCount + minusCount
        
        // Если есть много "+" и "-" (больше 3), это похоже на таблицу
        if totalValues >= 4 {
            // Проверяем, есть ли переносы строк (многострочная таблица)
            if lines.count >= 2 {
                return true
            }
            
            // Или если в одной строке много значений (компактный формат без переносов)
            // Например: "ФруктНизкий сахарМного клетчаткиЯблоко+++++Банан---+-..."
            if totalValues >= 5 {
                // Дополнительная проверка: есть ли слова с заглавной буквы перед значениями
                // Это указывает на заголовки и названия объектов
                let wordsWithCapital = normalized.components(separatedBy: CharacterSet(charactersIn: " \n\t"))
                    .filter { !$0.isEmpty && $0.first?.isUppercase == true }
                
                // Если есть несколько слов с заглавной буквы, это таблица
                if wordsWithCapital.count >= 2 {
                    return true
                }
                
                // Или если есть паттерн: слово с заглавной буквы, затем последовательность "+"/"-"
                // Это указывает на компактный формат: "Яблоко+++++"
                let pattern = #"[А-ЯЁA-Z][а-яёa-z\s]*[+\-]+"#
                if let regex = try? NSRegularExpression(pattern: pattern, options: []) {
                    let matches = regex.matches(in: normalized, options: [], range: NSRange(location: 0, length: normalized.count))
                    if matches.count >= 2 {
                        return true
                    }
                }
                
                return true
            }
        }
        
        // Проверяем наличие разделителей таблицы (табуляция)
        if normalized.contains("\t") {
            return true
        }
        
        // Проверяем паттерн: заголовок с заглавной буквы, затем значения
        // Например: "ФруктНизкий сахарМного клетчаткиЯблоко+++++"
        let wordsWithCapital = normalized.components(separatedBy: CharacterSet(charactersIn: " \n\t"))
            .filter { !$0.isEmpty && $0.first?.isUppercase == true }
        
        // Если есть несколько слов с заглавной буквы и много "+"/"-", это таблица
        if wordsWithCapital.count >= 3 && totalValues >= 3 {
            return true
        }
        
        return false
    }
    
    /// Обрабатывает импорт таблицы из текста
    private func processTableImport(_ text: String) {
        // Проверяем подписку
        Task {
            await SubscriptionManager.shared.updatePurchasedStatus()
            
            let canCreate = SubscriptionManager.shared.canCreateComparison(freeComparisonsCount: self.comparisonsArray.count)
            
            await MainActor.run {
                if !canCreate {
                    let subscriptionVC = SubscriptionViewController()
                    subscriptionVC.modalPresentationStyle = .pageSheet
                    if #available(iOS 15.0, *) {
                        if let sheet = subscriptionVC.sheetPresentationController {
                            sheet.detents = [.large()]
                            sheet.prefersGrabberVisible = true
                        }
                    }
                    self.present(subscriptionVC, animated: true)
                    return
                }
                
                // Парсим таблицу
                guard let tableData = TableImportService.parseTableFromClipboard(text) else {
                    let alert = UIAlertController(
                        title: "Error",
                        message: "Could not parse the table. Please make sure the format is correct.",
                        preferredStyle: .alert
                    )
                    alert.addAction(UIAlertAction(title: "OK", style: .default))
                    self.present(alert, animated: true)
                    return
                }
                
                // Генерируем название сравнения из таблицы
                let comparisonName = generateComparisonNameFromTable(tableData)
                
                // Выбираем цвет
                var currentColor = specialColors[0]
                switch self.comparisonsArray.count {
                case 0:
                    currentColor = specialColors[0]
                case 1...:
                    let lastColor = self.comparisonsArray.first?.color ?? specialColors[0]
                    let currentColorIndex = specialColors.firstIndex(of: lastColor)
                    currentColor = specialColors[(currentColorIndex! + 1) % specialColors.count]
                default:
                    currentColor = specialColors[0]
                }
                
                // Создаем сравнение
                guard let comparisonId = self.sharedDataBase.createComparison(name: comparisonName, color: currentColor) else {
                    let alert = UIAlertController(
                        title: "Error",
                        message: "Could not create comparison. A comparison with this name may already exist.",
                        preferredStyle: .alert
                    )
                    alert.addAction(UIAlertAction(title: "OK", style: .default))
                    self.present(alert, animated: true)
                    return
                }
                
                guard let comparison = self.sharedDataBase.fetchComparisonWithID(id: comparisonId) else {
                    let alert = UIAlertController(
                        title: "Error",
                        message: "Could not find the created comparison.",
                        preferredStyle: .alert
                    )
                    alert.addAction(UIAlertAction(title: "OK", style: .default))
                    self.present(alert, animated: true)
                    return
                }
                
                // Импортируем данные таблицы
                _ = self.sharedDataBase.importTableData(to: comparison, data: tableData)
                
                // Обновляем данные и переходим к созданному сравнению
                self.getData()
                
                if let comparisonEntity = self.sharedDataBase.fetchComparisonWithID(id: comparisonId) {
                    let destination = ComparisonListViewController()
                    destination.setComparisonEntity(comparison: comparisonEntity)
                    self.navigationController?.pushViewController(destination, animation: true, completion: {
                    })
                }
            }
        }
    }
    
    /// Генерирует название сравнения из таблицы
    private func generateComparisonNameFromTable(_ tableData: ImportedTableData) -> String {
        // Если есть первый заголовок (метка категории, например "Фрукт" или "Злак (Крупа)"), используем его
        // Сохраняем название целиком, включая все символы (скобки, смайлики и т.д.)
        if let firstHeader = tableData.firstHeader, !firstHeader.isEmpty {
            return firstHeader // Возвращаем как есть, без capitalize, чтобы сохранить все символы
        }
        
        // Если нет первого заголовка, используем логику на основе items
        if tableData.items.count >= 3 {
            return getCategoryForItems(tableData.items).capitalized
        } else if tableData.items.count == 2 {
            // Для 2 элементов: "X and Y"
            return "\(tableData.items[0]) and \(tableData.items[1])"
        } else if tableData.items.count == 1 {
            // Для 1 элемента: используем его название
            return tableData.items[0]
        } else {
            // Fallback
            return "Imported Comparison"
        }
    }
    
    private func createComparisonFromAIResult(_ result: AIComparisonResult, userRequest: String) {
        // Проверяем подписку
        Task {
            await SubscriptionManager.shared.updatePurchasedStatus()
            
            let canCreate = SubscriptionManager.shared.canCreateComparison(freeComparisonsCount: self.comparisonsArray.count)
            
            await MainActor.run {
                if !canCreate {
                    let subscriptionVC = SubscriptionViewController()
                    subscriptionVC.modalPresentationStyle = .pageSheet
                    if #available(iOS 15.0, *) {
                        if let sheet = subscriptionVC.sheetPresentationController {
                            sheet.detents = [.large()]
                            sheet.prefersGrabberVisible = true
                        }
                    }
                    self.present(subscriptionVC, animated: true)
                    return
                }
                
                // Создаем название сравнения из запроса и результата AI
                let comparisonName = self.generateComparisonName(from: userRequest, result: result)
                
                // Выбираем цвет
                var currentColor = specialColors[0]
                switch self.comparisonsArray.count {
                case 0:
                    currentColor = specialColors[0]
                case 1...:
                    let lastColor = self.comparisonsArray.first?.color ?? specialColors[0]
                    let currentColorIndex = specialColors.firstIndex(of: lastColor)
                    currentColor = specialColors[(currentColorIndex! + 1) % specialColors.count]
                default:
                    currentColor = specialColors[0]
                }
                
                // Создаем сравнение
                guard let comparisonId = self.sharedDataBase.createComparison(name: comparisonName, color: currentColor) else {
                    self.showAIError(AIAssistantError.parsingFailed)
                    return
                }
                
                guard let comparison = self.sharedDataBase.fetchComparisonWithID(id: comparisonId) else {
                    self.showAIError(AIAssistantError.parsingFailed)
                    return
                }
                
                // Импортируем данные из AI результата
                // ВАЖНО: Теперь ассистент только определяет items и attributes, БЕЗ значений
                // Таблица создается пустой - пользователь заполняет значения вручную
                let importData = ImportedTableData(
                    items: result.items,
                    attributes: result.attributes,
                    values: [], // Пустая матрица значений - таблица создается без заполнения
                    firstHeader: nil // Для AI результата первый заголовок не используется
                )
                
                _ = self.sharedDataBase.importTableData(to: comparison, data: importData)
                
                // Переходим к созданному сравнению
                let destination = ComparisonListViewController()
                destination.setComparisonEntity(comparison: comparison)
                self.navigationController?.pushViewController(destination, animation: true, completion: {})
            }
        }
    }
    
    private func generateComparisonName(from request: String, result: AIComparisonResult? = nil) -> String {
        // Если AI определил категорию, используем её как название (с большой буквы)
        if let category = result?.category, !category.isEmpty {
            return category.capitalized
        }
        
        // ВАЖНО: Анализируем ТОЛЬКО items (айтомы) для генерации названия
        // Группируем items по категориям, attributes не используются
        
        // Используем данные из результата AI, если доступны
        var items = result?.items ?? []
        
        // Если данных из результата нет, пытаемся извлечь из запроса
        if items.isEmpty {
            let parsed = AIAssistantService.shared.parseUserRequest(request)
            items = parsed.items ?? []
            
            // Если items не найдены, но есть группа, используем её название
            if items.isEmpty, let groupName = parsed.groupName, !groupName.isEmpty {
                return groupName.capitalized
            }
        }
        
        // Анализируем только items и группируем их
        if items.count >= 2 {
            // Для 3+ элементов: определяем категорию и возвращаем её
            // Или если AI не вернул категорию, но мы можем определить её сами
            if items.count >= 3 {
                let category = getCategoryForItems(items)
                return category.capitalized
            } else {
                // Для 2 элементов: "X и Y" (или "X and Y" в зависимости от языка)
                let conjunction = getConjunctionForLanguage(request)
                return "\(items[0]) \(conjunction) \(items[1])"
            }
        }
        
        // Если не удалось, используем первые слова запроса
        let words = request.components(separatedBy: .whitespaces).prefix(5)
        return words.joined(separator: " ")
    }
    
    /// Нормализует названия к именительному падежу (для русского) или убирает артикли (для испанского/французского)
    /// Например: "Москву" -> "Москва", "la manzana" -> "manzana", "le chat" -> "chat"
    private func normalizeItemToNominative(_ name: String) -> String {
        var normalized = name.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Проверяем язык
        let hasRussian = normalized.range(of: "[а-яё]", options: .regularExpression) != nil
        let hasSpanish = normalized.range(of: "[áéíóúñü]", options: .regularExpression) != nil
        let hasFrench = normalized.range(of: "[àâäéèêëïîôùûüÿç]", options: .regularExpression) != nil
        
        // Русский: нормализация падежей
        if hasRussian {
            let lowercased = normalized.lowercased()
            
            // Винительный падеж женского рода: -у, -ю (Москву -> Москва)
            if normalized.hasSuffix("у") && normalized.count > 2 {
                // Исключения: слова, которые заканчиваются на "у" в именительном падеже (кофе, какао и т.д.)
                let exceptions = ["кофе", "какао", "меню", "такси", "метро", "пальто", "кино"]
                if !exceptions.contains(lowercased) {
                    // Меняем "у" на "а" (Москву -> Москва)
                    return String(normalized.dropLast(1)) + "а"
                }
            }
            
            if normalized.hasSuffix("ю") && normalized.count > 2 {
                // Исключения
                let exceptions = ["меню"]
                if !exceptions.contains(lowercased) {
                    // Меняем "ю" на "я" (землю -> земля, но это редко для названий)
                    return String(normalized.dropLast(1)) + "я"
                }
            }
            
            return normalized
        }
        
        // Испанский: убираем артикли
        if hasSpanish {
            let lowercased = normalized.lowercased()
            
            // Испанские артикли: el, la, los, las, un, una, unos, unas
            let spanishArticles = ["el ", "la ", "los ", "las ", "un ", "una ", "unos ", "unas "]
            for article in spanishArticles {
                if lowercased.hasPrefix(article) {
                    normalized = String(normalized.dropFirst(article.count))
                        .trimmingCharacters(in: .whitespacesAndNewlines)
                    break
                }
            }
            
            // Также убираем предлоги "de", "del", "de la" в начале (но не в середине, как "pomme de terre")
            if normalized.lowercased().hasPrefix("de ") && normalized.count > 3 {
                let afterDe = String(normalized.dropFirst(3)).trimmingCharacters(in: .whitespacesAndNewlines)
                // Проверяем, что после "de" не идет артикль (тогда это часть названия)
                if !afterDe.lowercased().hasPrefix("el ") && !afterDe.lowercased().hasPrefix("la ") {
                    normalized = afterDe
                }
            }
            
            if normalized.lowercased().hasPrefix("del ") {
                normalized = String(normalized.dropFirst(4))
                    .trimmingCharacters(in: .whitespacesAndNewlines)
            }
            
            if normalized.lowercased().hasPrefix("de la ") {
                normalized = String(normalized.dropFirst(6))
                    .trimmingCharacters(in: .whitespacesAndNewlines)
            }
            
            return normalized
        }
        
        // Французский: убираем артикли
        if hasFrench {
            let lowercased = normalized.lowercased()
            
            // Французские артикли: le, la, les, un, une, des, du, de la, de l'
            let frenchArticles = ["le ", "la ", "les ", "un ", "une ", "des ", "du ", "de la ", "de l'"]
            for article in frenchArticles {
                if lowercased.hasPrefix(article) {
                    normalized = String(normalized.dropFirst(article.count))
                        .trimmingCharacters(in: .whitespacesAndNewlines)
                    break
                }
            }
            
            return normalized
        }
        
        // Английский: убираем артикли (the, a, an)
        let lowercased = normalized.lowercased()
        let englishArticles = ["the ", "a ", "an "]
        for article in englishArticles {
            if lowercased.hasPrefix(article) {
                normalized = String(normalized.dropFirst(article.count))
                    .trimmingCharacters(in: .whitespacesAndNewlines)
                break
            }
        }
        
        return normalized
    }
    
    /// Определяет категорию для списка элементов (например, "vegetables", "fruits", "cities")
    private func getCategoryForItems(_ items: [String]) -> String {
        // Определяем язык по первому элементу
        let firstItem = items.first?.lowercased() ?? ""
        let hasRussianChars = firstItem.range(of: "[а-яё]", options: .regularExpression) != nil
        let hasSpanishChars = firstItem.range(of: "[áéíóúñü]", options: .regularExpression) != nil
        let hasFrenchChars = firstItem.range(of: "[àâäéèêëïîôùûüÿç]", options: .regularExpression) != nil
        
        // Простая эвристика: определяем категорию по ключевым словам
        let allItemsLower = items.map { $0.lowercased() }.joined(separator: " ")
        
        // Овощи / Vegetables / Verduras / Légumes
        let vegetableKeywords = ["carrot", "beet", "potato", "tomato", "onion", "cucumber", "pepper",
                                "морковь", "свёкла", "картофель", "помидор", "лук", "огурец", "перец",
                                "zanahoria", "remolacha", "patata", "tomate", "cebolla", "pepino",
                                "carotte", "betterave", "pomme de terre", "tomate", "oignon", "concombre"]
        if vegetableKeywords.contains(where: { allItemsLower.contains($0) }) {
            if hasRussianChars {
                return "овощей"
            } else if hasSpanishChars {
                return "verduras"
            } else if hasFrenchChars {
                return "légumes"
            } else {
                return "vegetables"
            }
        }
        
        // Фрукты / Fruits / Frutas / Fruits
        let fruitKeywords = ["apple", "banana", "orange", "grape", "strawberry", "cherry",
                            "яблоко", "банан", "апельсин", "виноград", "клубника", "вишня",
                            "manzana", "plátano", "naranja", "uva", "fresa", "cereza",
                            "pomme", "banane", "orange", "raisin", "fraise", "cerise"]
        if fruitKeywords.contains(where: { allItemsLower.contains($0) }) {
            if hasRussianChars {
                return "фруктов"
            } else if hasSpanishChars {
                return "frutas"
            } else if hasFrenchChars {
                return "fruits"
            } else {
                return "fruits"
            }
        }
        
        // Города / Cities / Ciudades / Villes
        let cityKeywords = ["moscow", "dubai", "london", "paris", "new york", "tokyo",
                           "москва", "дубай", "лондон", "париж", "нью-йорк", "токио",
                           "moscú", "dubái", "londres", "parís", "nueva york",
                           "moscou", "dubaï", "londres", "paris", "new york"]
        if cityKeywords.contains(where: { allItemsLower.contains($0) }) {
            if hasRussianChars {
                return "городов"
            } else if hasSpanishChars {
                return "ciudades"
            } else if hasFrenchChars {
                return "villes"
            } else {
                return "cities"
            }
        }
        
        // Злаки / Cereals / Cereales / Céréales
        let cerealKeywords = ["rice", "wheat", "oats", "barley", "corn", "quinoa",
                              "рис", "пшеница", "овёс", "ячмень", "кукуруза",
                              "arroz", "trigo", "avena", "cebada", "maíz",
                              "riz", "blé", "avoine", "orge", "maïs"]
        if cerealKeywords.contains(where: { allItemsLower.contains($0) }) {
            if hasRussianChars {
                return "злаков"
            } else if hasSpanishChars {
                return "cereales"
            } else if hasFrenchChars {
                return "céréales"
            } else {
                return "cereals"
            }
        }
        
        // По умолчанию: используем множественное число от первого элемента или общее слово
        if hasRussianChars {
            return "элементов"
        } else if hasSpanishChars {
            return "elementos"
        } else if hasFrenchChars {
            return "éléments"
        } else {
            return "items"
        }
    }
    
    /// Определяет союз для соединения элементов в зависимости от языка запроса
    private func getConjunctionForLanguage(_ request: String) -> String {
        let hasRussianChars = request.range(of: "[а-яё]", options: .regularExpression) != nil
        let hasSpanishChars = request.range(of: "[áéíóúñü]", options: .regularExpression) != nil
        let hasFrenchChars = request.range(of: "[àâäéèêëïîôùûüÿç]", options: .regularExpression) != nil
        
        if hasRussianChars {
            return "и"
        } else if hasSpanishChars {
            return "y"
        } else if hasFrenchChars {
            return "et"
        } else {
            return "and"
        }
    }
    
    /// Создает сравнение с базовыми значениями при ошибке парсинга
    private func createComparisonWithFallback(userRequest: String, error: Error) {
        // Пытаемся извлечь объекты и критерии из запроса
        let parsed = AIAssistantService.shared.parseUserRequest(userRequest)
        
        guard let items = parsed.items, let attributes = parsed.attributes else {
            showAIError(error)
            return
        }
        
        // Создаем сравнение с базовыми значениями (все "-")
        let comparisonName = generateComparisonName(from: userRequest)
        
        // Проверяем подписку
        Task {
            await SubscriptionManager.shared.updatePurchasedStatus()
            
            let canCreate = SubscriptionManager.shared.canCreateComparison(freeComparisonsCount: self.comparisonsArray.count)
            
            await MainActor.run {
                if !canCreate {
                    let subscriptionVC = SubscriptionViewController()
                    subscriptionVC.modalPresentationStyle = .pageSheet
                    if #available(iOS 15.0, *) {
                        if let sheet = subscriptionVC.sheetPresentationController {
                            sheet.detents = [.large()]
                            sheet.prefersGrabberVisible = true
                        }
                    }
                    self.present(subscriptionVC, animated: true)
                    return
                }
                
                // Выбираем цвет
                var currentColor = specialColors[0]
                switch self.comparisonsArray.count {
                case 0:
                    currentColor = specialColors[0]
                case 1...:
                    let lastColor = self.comparisonsArray.first?.color ?? specialColors[0]
                    let currentColorIndex = specialColors.firstIndex(of: lastColor)
                    currentColor = specialColors[(currentColorIndex! + 1) % specialColors.count]
                default:
                    currentColor = specialColors[0]
                }
                
                // Создаем сравнение
                guard let comparisonId = self.sharedDataBase.createComparison(name: comparisonName, color: currentColor) else {
                    self.showAIError(error)
                    return
                }
                
                guard let comparison = self.sharedDataBase.fetchComparisonWithID(id: comparisonId) else {
                    self.showAIError(error)
                    return
                }
                
                // Создаем базовые значения (все "-")
                let defaultValues = Array(repeating: Array(repeating: "-", count: attributes.count), count: items.count)
                let importData = ImportedTableData(
                    items: items,
                    attributes: attributes,
                    values: defaultValues,
                    firstHeader: nil // Для fallback первый заголовок не используется
                )
                
                _ = self.sharedDataBase.importTableData(to: comparison, data: importData)
                
                // Show warning and navigate to comparison
                let warningAlert = UIAlertController(
                    title: "Warning",
                    message: "Failed to get data from AI. Created comparison with default values. You can fill it manually.",
                    preferredStyle: .alert
                )
                warningAlert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
                    let destination = ComparisonListViewController()
                    destination.setComparisonEntity(comparison: comparison)
                    self.navigationController?.pushViewController(destination, animation: true, completion: {})
                })
                self.present(warningAlert, animated: true)
            }
        }
    }
    
    private func showAIError(_ error: Error) {
        var errorMessage = error.localizedDescription
        
        // More user-friendly error messages
        if let aiError = error as? AIAssistantError {
            switch aiError {
            case .parsingFailed:
                errorMessage = "Failed to recognize items and criteria in your request. Try rephrasing your request, for example: \"Compare New York and London by cost of living, technology, price\""
            case .networkError:
                errorMessage = "Network error when accessing the AI service. Check your internet connection and API settings."
            case .invalidResponse:
                errorMessage = "AI service returned an invalid response format. Try again or check your API settings."
            case .rateLimitExceeded:
                errorMessage = "Too many requests right now. The AI service has a limit on requests per minute. Please try again in a minute."
            default:
                break
            }
        } else {
            // For other errors (e.g., JSON parsing)
            if error.localizedDescription.contains("couldn't be read") || 
               error.localizedDescription.contains("correct format") {
                errorMessage = "Failed to process response from AI. Created comparison with default values. You can fill it manually."
            }
        }
        
        let errorAlert = UIAlertController(
            title: "Error",
            message: errorMessage,
            preferredStyle: .alert
        )
        errorAlert.addAction(UIAlertAction(title: "OK", style: .default))
        present(errorAlert, animated: true)
    }
    
    
}

