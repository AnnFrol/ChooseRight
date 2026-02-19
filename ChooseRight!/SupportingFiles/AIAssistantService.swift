//
//  AIAssistantService.swift
//  ChooseRight!
//
//  AI Ассистент для создания таблиц сравнения
//
//  УПРОЩЕННАЯ ВЕРСИЯ:
//  Ассистент только определяет items (объекты) и attributes (атрибуты) из запроса пользователя.
//  Значения НЕ генерируются - таблица создается пустой, пользователь заполняет значения вручную.
//
//  Использование:
//  1. Пользователь вводит запрос типа: "Хочу сравнить Москву и Дубай по уровню жизни, технологичности, стоимости"
//  2. Сервис парсит запрос и извлекает объекты (Москва, Дубай) и критерии (уровень жизни, технологичность, стоимость)
//  3. Создает сравнение в CoreData с пустой таблицей (без значений)
//

import Foundation

// MARK: - Configuration для бесплатных LLM API
// 
// Для использования бесплатного LLM API:
// 1. Выберите один из вариантов ниже
// 2. Получите бесплатный API ключ
// 3. Раскомментируйте соответствующий метод в callLLMAPI()
// 4. Добавьте API ключ в метод вызова
//
// Рекомендации:
// - Groq: самый быстрый, хорошее качество (https://console.groq.com/)
// - Hugging Face: много моделей, бесплатный tier (https://huggingface.co/settings/tokens)
// - OpenRouter: доступ к разным моделям (https://openrouter.ai/)
//
// Все варианты поддерживают строгий JSON формат через промпт

/// Структура для хранения результата сравнения от AI
/// Теперь ассистент только определяет items и attributes, без генерации значений
struct AIComparisonResult: Codable {
    let items: [String]  // Объекты для сравнения (например, ["Москва", "Дубай"])
    let attributes: [String]  // Критерии сравнения (например, ["уровень жизни", "технологичность"])
    let category: String? // Категория сравнения (например, "Фрукты", "Города")
    // Значения больше не генерируются - таблица создается пустой, пользователь заполняет вручную
}

/// Сервис для работы с AI ассистентом
final class AIAssistantService: @unchecked Sendable {
    
    static let shared = AIAssistantService()
    
    private init() {}
    
    /// Обрабатывает запрос пользователя и возвращает структурированные данные сравнения
    /// УПРОЩЕННАЯ ВЕРСИЯ: Ассистент только определяет items и attributes, БЕЗ генерации значений
    /// - Parameter userRequest: Запрос пользователя (например, "Хочу сравнить Москву и Дубай по уровню жизни, технологичности, стоимости")
    /// - Returns: Результат сравнения с items и attributes, но БЕЗ значений (таблица создается пустой)
    func processComparisonRequest(_ userRequest: String) async throws -> AIComparisonResult {
        
        // Определяем язык запроса пользователя
        let detectedLanguage = detectLanguage(userRequest)
        
        // Массив разделителей (слов-связок) для всех языков
        let separators = [" и ", " and ", " vs ", " versus ", " против ", " y ", " et ", " con ", " avec "]
        
        // Проверяем, является ли запрос коротким (2-3 слова) и без явных разделителей
        let words = userRequest.components(separatedBy: .whitespaces).filter { !$0.isEmpty }
        let hasExplicitSeparator = separators.contains { userRequest.contains($0) }
        let hasComma = userRequest.contains(",")
        let isShortRequest = words.count <= 3 && !hasExplicitSeparator && !hasComma
        
        // Для коротких запросов без разделителей сначала спрашиваем LLM
        var parsedData: (items: [String]?, attributes: [String]?, groupName: String?, attributeGroupName: String?, inferredCategory: String?)
        
        if isShortRequest {
            // Используем LLM для парсинга коротких запросов
            do {
                parsedData = try await parseUserRequestWithLLM(userRequest, language: detectedLanguage)
            } catch {
                // Если LLM не сработал, используем обычный парсинг
                let simpleParsed = parseUserRequest(userRequest)
                parsedData = (simpleParsed.items, simpleParsed.attributes, simpleParsed.groupName, simpleParsed.attributeGroupName, nil)
            }
        } else {
            // Для длинных запросов или с разделителями используем обычный парсинг
            let simpleParsed = parseUserRequest(userRequest)
            parsedData = (simpleParsed.items, simpleParsed.attributes, simpleParsed.groupName, simpleParsed.attributeGroupName, nil)
            
            // Если обычный парсинг не дал результатов, пробуем LLM
            if parsedData.items == nil && parsedData.groupName == nil && parsedData.attributes == nil {
                do {
                    parsedData = try await parseUserRequestWithLLM(userRequest, language: detectedLanguage)
                } catch {
                    // Оставляем результат обычного парсинга
                }
            }
        }
        
        var items: [String]
        
        // Если указана группа, генерируем объекты из группы
        if let groupName = parsedData.groupName {
            // Генерируем 5 популярных объектов из группы через AI на том же языке
            items = try await generateItemsFromGroup(groupName, language: detectedLanguage)
        } else if let parsedItems = parsedData.items, parsedItems.count >= 2 {
            // Используем распарсенные объекты (они уже на правильном языке)
            items = parsedItems
        } else {
            // Не удалось распарсить ни объекты, ни группу
            throw AIAssistantError.parsingFailed
        }
        
        // Если указана группа атрибутов (например, "minerals" в скобках), генерируем атрибуты из группы
        var attributes = parsedData.attributes ?? []
        
        // CRITICAL: Если пользователь четко указал атрибут(ы) в запросе (например, "по размеру", "by size"),
        // используем ТОЛЬКО указанные атрибуты, БЕЗ генерации дополнительных
        if let attributeGroupName = parsedData.attributeGroupName {
            // Генерируем 5 популярных атрибутов из группы через AI на том же языке
            attributes = try await generateItemsFromGroup(attributeGroupName, language: detectedLanguage)
        } else if !attributes.isEmpty {
            // Пользователь четко указал атрибут(ы) - используем ТОЛЬКО их, без генерации дополнительных
            // Нормализуем указанные атрибуты
            attributes = attributes.map { normalizeAttributeName(cleanAttribute($0)) }
                .filter { !$0.isEmpty }
        } else if attributes.isEmpty {
            // Атрибуты не указаны - генерируем релевантные критерии через AI на том же языке
            // Приоритет: нечисловые атрибуты (качественные характеристики)
            let allGeneratedAttributes = try await generateAttributesForItems(items, language: detectedLanguage)
            
            // Разделяем на числовые и нечисловые атрибуты
            var numericalAttributes: [String] = []
            var nonNumericalAttributes: [String] = []
            
            for attr in allGeneratedAttributes {
                if isNumericalAttribute(attr) {
                    numericalAttributes.append(attr)
                } else {
                    nonNumericalAttributes.append(attr)
                }
            }
            
            // Используем нечисловые атрибуты как основные
            // Числовые используем только если нечисловых нет
            if !nonNumericalAttributes.isEmpty {
                attributes = nonNumericalAttributes
            } else {
                // Fallback: если сгенерировались только числовые, используем их
                attributes = numericalAttributes
            }
        }
        
        // Валидация: проверяем, что есть хотя бы 1 критерий
        guard attributes.count >= 1 else {
            throw AIAssistantError.parsingFailed
        }
        
        // ВАЖНО: Значения НЕ генерируются - таблица создается пустой
        // Пользователь заполняет значения вручную
        return AIComparisonResult(
            items: items,
            attributes: attributes,
            category: parsedData.inferredCategory
        )
    }
    
    /// Парсит запрос пользователя через LLM для сложных случаев
    /// Используется для коротких запросов без явных разделителей
    private func parseUserRequestWithLLM(_ request: String, language: String) async throws -> (items: [String]?, attributes: [String]?, groupName: String?, attributeGroupName: String?, inferredCategory: String?) {
        let languageName: String
        switch language {
        case "ru": languageName = "RUSSIAN"
        case "es": languageName = "SPANISH"
        case "fr": languageName = "FRENCH"
        default: languageName = "ENGLISH"
        }
        
        let prompt = """
        You are an analytical assistant for the Choose Right application.
        
        TASK:
        Parse the user's request and extract:
        1. Items to compare (if specific items are mentioned)
        2. Attributes/criteria for comparison (if mentioned)
        3. Group name (if user mentions a category like "домашние животные", "beautiful cities", "tropical fruits")
        4. Attribute group name (if user mentions a group of attributes like "minerals", "vitamins")
        5. Inferred category name (determine the common category for the items, e.g. "Fruits" for apple/pear, "Cities" for Moscow/Dubai)
        
        User request: "\(request)"
        
        CRITICAL RULES:
        1. Return ONLY valid JSON, without any text before or after
        2. DO NOT use markdown code blocks (```json or ```)
        3. DO NOT add explanations or comments
        4. If user mentions specific items (e.g., "Moscow and Dubai", "кошка и собака"), return them in "items" array
        5. If user mentions a category/group (e.g., "домашние животные", "beautiful cities", "тропические фрукты"), return it in "groupName"
        6. If user mentions specific attributes (e.g., "по размеру", "by size"), return them in "attributes" array
        7. If user mentions an attribute group (e.g., "minerals", "витамины"), return it in "attributeGroupName"
        8. ALWAYS determine the "inferredCategory" based on the items or groupName. It should be a short, general category name in \(languageName) (plural, capitalized, NOMINATIVE case - e.g. "Фрукты", NOT "Фруктов").
        9. Return all text in \(languageName) language (same as user request)
        10. If the request is ambiguous (e.g., "домашних животных"), determine if it's:
           - A group name (category) → return in "groupName"
           - A list of items → return in "items"
        
        IMPORTANT: For requests like "домашних животных" (domestic animals), this is a GROUP/CATEGORY, not individual items.
        Return it as "groupName": "домашних животных"
        
        REQUIRED JSON FORMAT:
        {
          "items": ["item1", "item2"] or null,
          "attributes": ["attribute1", "attribute2"] or null,
          "groupName": "category name" or null,
          "attributeGroupName": "attribute group name" or null,
          "inferredCategory": "General Category Name" (required)
        }
        
        IMPORTANT: Return ONLY the JSON object starting with { and ending with }. No other text!
        """
        
        let jsonResponse = try await callLLMAPI(prompt: prompt)
        
        // Парсим JSON ответ
        struct ParseResponse: Codable {
            let items: [String]?
            let attributes: [String]?
            let groupName: String?
            let attributeGroupName: String?
            let inferredCategory: String?
        }
        
        // Очищаем ответ от возможных markdown блоков
        var cleanedJSON = jsonResponse.trimmingCharacters(in: .whitespacesAndNewlines)
        if cleanedJSON.hasPrefix("```json") {
            cleanedJSON = String(cleanedJSON.dropFirst(7))
        } else if cleanedJSON.hasPrefix("```") {
            cleanedJSON = String(cleanedJSON.dropFirst(3))
        }
        if cleanedJSON.hasSuffix("```") {
            cleanedJSON = String(cleanedJSON.dropLast(3))
        }
        cleanedJSON = cleanedJSON.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Ищем начало JSON объекта
        if let startIndex = cleanedJSON.firstIndex(of: "{"),
           let endIndex = cleanedJSON.lastIndex(of: "}"),
           startIndex <= endIndex {
            cleanedJSON = String(cleanedJSON[startIndex...endIndex])
        }
        
        guard let data = cleanedJSON.data(using: .utf8) else {
            return (items: nil, attributes: nil, groupName: nil, attributeGroupName: nil, inferredCategory: nil)
        }
        
        let decoder = JSONDecoder()
        do {
            let response = try decoder.decode(ParseResponse.self, from: data)
            
            // Нормализуем items
            let normalizedItems = response.items?.map { normalizeItemToNominative($0) }.filter { !$0.isEmpty }
            let normalizedAttributes = response.attributes?.map { normalizeAttributeName($0) }.filter { !$0.isEmpty }
            
            // Нормализуем категорию к именительному падежу (для русского языка)
            let normalizedCategory = response.inferredCategory.map { normalizeCategoryToNominative($0) }
            
            return (
                items: normalizedItems?.isEmpty == false ? normalizedItems : nil,
                attributes: normalizedAttributes?.isEmpty == false ? normalizedAttributes : nil,
                groupName: response.groupName?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false ? response.groupName?.trimmingCharacters(in: .whitespacesAndNewlines) : nil,
                attributeGroupName: response.attributeGroupName?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false ? response.attributeGroupName?.trimmingCharacters(in: .whitespacesAndNewlines) : nil,
                inferredCategory: normalizedCategory?.isEmpty == false ? normalizedCategory : nil
            )
        } catch {
            return (items: nil, attributes: nil, groupName: nil, attributeGroupName: nil, inferredCategory: nil)
        }
    }
    
    /// Парсит запрос пользователя и извлекает объекты, критерии или группу
    /// Возвращает: items, attributes, groupName (для объектов), attributeGroupName (для атрибутов в скобках)
    func parseUserRequest(_ request: String) -> (items: [String]?, attributes: [String]?, groupName: String?, attributeGroupName: String?) {
        
        let lowercased = request.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        var items: [String] = []
        var attributes: [String] = []
        var groupName: String? = nil
        var attributeGroupName: String? = nil
        
        // PRIORITY CHECK: Check for "Compare [criterion] of [items]" pattern - e.g., "Compare the calorie content of carrots, beets, and potatoes"
        // This must be checked BEFORE generic list parsing to avoid incorrect parsing where criterion becomes part of the first item
        if lowercased.hasPrefix("compare") || lowercased.hasPrefix("comparar") || lowercased.hasPrefix("comparer") {
            let compareOfPattern = #"(?:compare|comparar|comparer)\s+(?:the\s+)?(.+?)\s+(?:of|de)\s+(.+?)$"#
            if let regex = try? NSRegularExpression(pattern: compareOfPattern, options: .caseInsensitive) {
                let nsString = request as NSString
                let results = regex.matches(in: request, options: [], range: NSRange(location: 0, length: nsString.length))
                
                if let match = results.first, match.numberOfRanges >= 3 {
                    let potentialCriterion = nsString.substring(with: match.range(at: 1))
                        .trimmingCharacters(in: .whitespacesAndNewlines)
                    let potentialItems = nsString.substring(with: match.range(at: 2))
                        .trimmingCharacters(in: .whitespacesAndNewlines)
                    
                    // Parse items from comma-separated list (e.g., "carrots, beets, and potatoes")
                    let itemsList = parseItemsList(potentialItems)
                    
                    // CRITICAL: Validation to ensure potentialCriterion is truly a criterion and not "Items by Criterion"
                    // Example failure: "Compare New York and London by cost of living"
                    // potentialCriterion matches "New York and London by cost" -> WRONG
                    let lowerCriterion = potentialCriterion.lowercased()
                    let invalidIndicators = [" by ", " in terms of ", " with ", " vs ", " versus ", " против ", " по ", " par ", " selon "]
                    let hasInvalidIndicator = invalidIndicators.contains { lowerCriterion.contains($0) }
                    
                    // Also check for "and" in potentialCriterion - if it contains "and", it's likely a list of items, not a single criterion
                    // Exception: complex criterion like "advantages and disadvantages" - but usually "Compare X and Y" comes first
                    let hasAnd = lowerCriterion.contains(" and ") || lowerCriterion.contains(" и ") || lowerCriterion.contains(" y ") || lowerCriterion.contains(" et ")
                    
                    if itemsList.count >= 2 && !hasInvalidIndicator && !hasAnd {
                        // This is "Compare [criterion] of [items]" format
                        items = itemsList
                        let cleanedCriterion = cleanAttribute(potentialCriterion)
                        attributes = [normalizeAttributeName(cleanedCriterion)]
                        // Return early to skip other pattern matching
                        return (items: items, attributes: attributes, groupName: nil, attributeGroupName: nil)
                    }
                }
            }
        }
        
        // FIRST: Check for lists with commas (works for all languages)
        // This must be checked BEFORE all other patterns to avoid incorrect parsing
        // CRITICAL: If commas are found, parse as list and return immediately - never group items
        let allCompareKeywords = ["compare", "сравнить", "сравни", "хочу сравнить", "i want to compare", 
                                  "comparar", "quiero comparar", "comparer", "je veux comparer"]
        for keyword in allCompareKeywords {
            if let compareIndex = lowercased.range(of: keyword), compareIndex.upperBound < request.endIndex {
                let afterCompare = String(request[compareIndex.upperBound...])
                    .trimmingCharacters(in: .whitespacesAndNewlines)
                
                // Remove criteria keywords and everything after them (all languages)
                // This helps us identify where the items list ends
                let criteriaStartWords = ["по", "in terms of", "by", "criteria", "критери", "parameters",
                                          "por", "en términos de", "según", "par", "en termes de", "selon"]
                var itemsString = afterCompare
                for criteriaWord in criteriaStartWords {
                    if let criteriaIndex = itemsString.lowercased().range(of: criteriaWord) {
                        itemsString = String(itemsString[..<criteriaIndex.lowerBound])
                            .trimmingCharacters(in: .whitespacesAndNewlines)
                        break
                    }
                }
                
                // Check if there are commas in the string (indicates a list) - works for all languages
                if afterCompare.contains(",") {
                    // Parse comma-separated list (works for all languages)
                    let itemsList = parseItemsList(itemsString)
                    // CRITICAL: If we found items via comma-separated list, use them and STOP
                    // Never group items together - each comma-separated item is separate
                    if itemsList.count >= 2 {
                        items = itemsList
                        // Explicitly prevent grouping - items are already separate
                        groupName = nil
                        // Mark that we found items via comma list - don't continue with other patterns
                        // We'll continue to parse attributes, but items are final
                    } else if itemsList.count == 1 && itemsString.contains(",") {
                        // Edge case: parseItemsList might have failed, try manual split
                        let manualParts = itemsString.components(separatedBy: ",")
                            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                            .filter { !$0.isEmpty }
                        if manualParts.count >= 2 {
                            items = manualParts.map { cleanItemName($0) }.filter { !$0.isEmpty }
                            if items.count < manualParts.count {
                                // If cleaning removed items, use original parts
                                items = manualParts
                            }
                            groupName = nil
                        }
                    }
                    // If items were found, break immediately to prevent other patterns from overwriting
                    if !items.isEmpty {
                        break
                    }
                } else {
                    // No commas found - try to parse as space-separated list
                    // This handles cases like "compare London Dubai Moscow Tokyo" (without commas)
                    if !itemsString.isEmpty {
                        let itemsList = parseItemsList(itemsString)
                        // CRITICAL: If we found multiple items via space-separated list, use them
                        // Never group items together - each item is separate
                        if itemsList.count >= 2 {
                            items = itemsList
                            // Explicitly prevent grouping - items are already separate
                            groupName = nil
                            // Break immediately to prevent other patterns from overwriting
                            break
                        }
                    }
                }
            }
        }
        
        // Patterns for finding items (supports English, Russian, Spanish, and French)
        // CRITICAL: These patterns should NOT match if there are commas in the request
        // (commas indicate a list, which should be handled by parseItemsList above)
        let itemPatterns = [
            // English patterns
            "compare\\s+(.+?)\\s+and\\s+(.+?)(?:\\s+(?:in\\s+terms\\s+of|by|with)|$)",  // "compare X and Y in terms of/by..."
            "compare\\s+(.+?)\\s+with\\s+(.+?)(?:\\s+(?:in\\s+terms\\s+of|by)|$)",  // "compare X with Y..."
            "(.+?)\\s+vs\\s+(.+?)(?:\\s+(?:in\\s+terms\\s+of|by)|$)",  // "X vs Y in terms of/by..."
            "(.+?)\\s+versus\\s+(.+?)(?:\\s+(?:in\\s+terms\\s+of|by)|$)",  // "X versus Y..."
            "i\\s+want\\s+to\\s+compare\\s+(.+?)\\s+and\\s+(.+?)(?:\\s+(?:in\\s+terms\\s+of|by)|$)",  // "I want to compare X and Y..."
            // Russian patterns
            "сравни\\s+(.+?)\\s+и\\s+(.+?)(?:\\s+по|$)",  // "сравни X и Y" или "сравни X и Y по..."
            "сравнить\\s+(.+?)\\s+и\\s+(.+?)(?:\\s+по|$)",  // "сравнить X и Y по..."
            "сравнить\\s+(.+?)\\s+и\\s+(.+?)(?:\\s+критериям|$)",  // "сравнить X и Y критериям..."
            "(.+?)\\s+против\\s+(.+?)(?:\\s+по|$)",  // "X против Y по..."
            "(.+?)\\s+или\\s+(.+?)(?:\\s+по|$)",  // "X или Y по..."
            "хочу\\s+сравнить\\s+(.+?)\\s+и\\s+(.+?)(?:\\s+по|$)",  // "хочу сравнить X и Y по..."
            // Spanish patterns
            "comparar\\s+(.+?)\\s+y\\s+(.+?)(?:\\s+(?:por|en\\s+términos\\s+de|según)|$)",  // "comparar X y Y por/en términos de..."
            "comparar\\s+(.+?)\\s+con\\s+(.+?)(?:\\s+(?:por|en\\s+términos\\s+de)|$)",  // "comparar X con Y por..."
            "(.+?)\\s+vs\\s+(.+?)(?:\\s+(?:por|en\\s+términos\\s+de)|$)",  // "X vs Y por..."
            "quiero\\s+comparar\\s+(.+?)\\s+y\\s+(.+?)(?:\\s+(?:por|en\\s+términos\\s+de)|$)",  // "quiero comparar X y Y por..."
            // French patterns
            "comparer\\s+(.+?)\\s+et\\s+(.+?)(?:\\s+(?:par|en\\s+termes\\s+de|selon)|$)",  // "comparer X et Y par/en termes de..."
            "comparer\\s+(.+?)\\s+avec\\s+(.+?)(?:\\s+(?:par|en\\s+termes\\s+de)|$)",  // "comparer X avec Y par..."
            "(.+?)\\s+vs\\s+(.+?)(?:\\s+(?:par|en\\s+termes\\s+de)|$)",  // "X vs Y par..."
            "je\\s+veux\\s+comparer\\s+(.+?)\\s+et\\s+(.+?)(?:\\s+(?:par|en\\s+termes\\s+de)|$)",  // "je veux comparer X et Y par..."
        ]
        
        // Ищем объекты через регулярные выражения
        // CRITICAL: Skip these patterns if:
        // 1. Request contains commas (indicates a list already parsed above)
        // 2. Items are already found (should not be overwritten)
        if items.isEmpty && !request.contains(",") {
            for pattern in itemPatterns {
                if let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive) {
                    let nsString = request as NSString
                    let results = regex.matches(in: request, options: [], range: NSRange(location: 0, length: nsString.length))
                    
                    if let match = results.first, match.numberOfRanges >= 3 {
                        let firstItem = nsString.substring(with: match.range(at: 1)).trimmingCharacters(in: .whitespacesAndNewlines)
                        let secondItem = nsString.substring(with: match.range(at: 2)).trimmingCharacters(in: .whitespacesAndNewlines)
                        
                        // CRITICAL: Check that neither item contains commas (would indicate a list)
                        if firstItem.contains(",") || secondItem.contains(",") {
                            continue // Skip this pattern, it's likely a list
                        }
                        
                        // Убираем лишние слова из начала/конца
                        let cleanFirst = cleanItemName(firstItem)
                        let cleanSecond = cleanItemName(secondItem)
                        
                        if !cleanFirst.isEmpty && !cleanSecond.isEmpty {
                            items = [cleanFirst, cleanSecond]
                            break
                        }
                    }
                }
            }
        }
        
        // If not found through patterns or comma-separated lists, try to find through keywords
        // CRITICAL: Skip this if:
        // 1. Items are already found (should not be overwritten)
        // 2. Request contains commas (already handled above)
        if items.isEmpty && !request.contains(",") {
            // Look after words "compare", "сравнить", "хочу сравнить", "comparar", "comparer"
            let compareKeywords = ["compare", "сравнить", "хочу сравнить", "i want to compare", 
                                   "comparar", "quiero comparar", "comparer", "je veux comparer"]
            for keyword in compareKeywords {
                if let compareIndex = lowercased.range(of: keyword), compareIndex.upperBound < request.endIndex {
                    let afterCompare = String(request[compareIndex.upperBound...])
                    
                    // CRITICAL: If afterCompare contains commas, it's a list - skip this method
                    if afterCompare.contains(",") {
                        continue
                    }
                    
                    // Split by various separators (English, Russian, Spanish, French)
                    let separators = CharacterSet(charactersIn: "и,and,with,vs,versus,против,или,or,y,et,con,avec,")
                    var parts = afterCompare.components(separatedBy: separators)
                        .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                        .filter { !$0.isEmpty }
                    
                    // Remove parts that contain criteria keywords (this is the start of criteria)
                    let criteriaStartWords = ["по", "in terms of", "by", "criteria", "критери", "parameters",
                                              "por", "en términos de", "según", "par", "en termes de", "selon"]
                    parts = parts.filter { part in
                        let lowerPart = part.lowercased()
                        return !criteriaStartWords.contains { lowerPart.contains($0) }
                    }
                    
                    // CRITICAL: Only take items if there are exactly 2 (not more, to avoid grouping)
                    if parts.count == 2 {
                        // Take both as separate items
                        items = [cleanItemName(parts[0]), cleanItemName(parts[1])]
                        break
                    } else if parts.count > 2 {
                        // If more than 2, it might be a list - try to parse it properly
                        let itemsString = parts.joined(separator: ", ")
                        let itemsList = parseItemsList(itemsString)
                        if itemsList.count >= 2 {
                            items = itemsList
                            break
                        }
                    }
                }
            }
        }
        
        // First, check for "Compare [group]: [question about attributes]" pattern - e.g., "Compare cereals: what minerals do they have and what don't?"
        // This must be checked BEFORE other patterns to avoid conflicts
        // CRITICAL: Only check for groups if NO specific items were found (items.isEmpty)
        if items.isEmpty && attributes.isEmpty && groupName == nil {
            let compareGroupQuestionPattern = #"(?:compare|сравни|comparar|comparer)\s+(.+?):\s+(.+?)$"#
            if let regex = try? NSRegularExpression(pattern: compareGroupQuestionPattern, options: .caseInsensitive) {
                let nsString = request as NSString
                let results = regex.matches(in: request, options: [], range: NSRange(location: 0, length: nsString.length))
                
                if let match = results.first, match.numberOfRanges >= 3 {
                    let potentialGroup = nsString.substring(with: match.range(at: 1))
                        .trimmingCharacters(in: .whitespacesAndNewlines)
                    let questionPart = nsString.substring(with: match.range(at: 2))
                        .trimmingCharacters(in: .whitespacesAndNewlines)
                    
                    // Check that it's not two items separated by "and", "и", "vs", etc.
                    if !potentialGroup.lowercased().contains(" и ") && 
                       !potentialGroup.lowercased().contains(" and ") &&
                       !potentialGroup.lowercased().contains(" vs ") &&
                       !potentialGroup.lowercased().contains(" versus ") &&
                       !potentialGroup.lowercased().contains(" против ") &&
                       !potentialGroup.lowercased().contains(" y ") &&
                       !potentialGroup.lowercased().contains(" et ") &&
                       !potentialGroup.lowercased().contains(" con ") &&
                       !potentialGroup.lowercased().contains(" avec ") {
                        // This looks like "Compare [group]: [question]" format
                        // НЕ используем cleanItemName, чтобы сохранить прилагательные (например, "красивые города")
                        groupName = potentialGroup.trimmingCharacters(in: .whitespacesAndNewlines)
                        
                        // Try to extract attribute group from question (e.g., "minerals" from "what minerals do they have")
                        let questionLowercased = questionPart.lowercased()
                        
                        // Pattern 1: "what [group] do they have" or "what [group] do they have and what don't"
                        let whatPattern = #"what\s+([a-z]+(?:\s+[a-z]+)?)\s+(?:do\s+they\s+have|are|contain)"#
                        if let whatRegex = try? NSRegularExpression(pattern: whatPattern, options: .caseInsensitive) {
                            let nsQuestion = questionPart as NSString
                            let whatResults = whatRegex.matches(in: questionPart, options: [], range: NSRange(location: 0, length: nsQuestion.length))
                            
                            if let whatMatch = whatResults.first, whatMatch.numberOfRanges >= 2 {
                                let potentialAttributeGroup = nsQuestion.substring(with: whatMatch.range(at: 1))
                                    .trimmingCharacters(in: .whitespacesAndNewlines)
                                
                                // Check if it's a plural noun (likely a group)
                                if potentialAttributeGroup.hasSuffix("s") || 
                                   potentialAttributeGroup.lowercased() == "minerals" ||
                                   potentialAttributeGroup.lowercased() == "vitamins" ||
                                   potentialAttributeGroup.lowercased() == "nutrients" {
                                    attributeGroupName = cleanItemName(potentialAttributeGroup)
                                }
                            }
                        }
                        
                        // Pattern 2: Look for common attribute groups in the question
                        if attributeGroupName == nil {
                            let commonGroups = ["minerals", "vitamins", "nutrients", "proteins", "fats", "carbohydrates", "fibers", "antioxidants"]
                            for group in commonGroups {
                                if questionLowercased.contains(group) {
                                    attributeGroupName = group
                                    break
                                }
                            }
                        }
                    }
                }
            }
        }
        
        // Second, check for "Compare [group] by [criterion]" pattern - e.g., "Compare cereals by composition (minerals)"
        // Also handles "сравни фрукты по размеру" (Russian "по" = "by")
        // This must be checked BEFORE other patterns to avoid conflicts
        // CRITICAL: Only check for groups if NO specific items were found (items.isEmpty)
        if items.isEmpty && attributes.isEmpty && groupName == nil {
            // Pattern supports: "compare X by Y", "сравни X по Y", "comparar X por Y", "comparer X par Y"
            let compareGroupByPattern = #"(?:compare|сравни|comparar|comparer)\s+(.+?)\s+(?:by|por|par|по)\s+(.+?)$"#
            if let regex = try? NSRegularExpression(pattern: compareGroupByPattern, options: .caseInsensitive) {
                let nsString = request as NSString
                let results = regex.matches(in: request, options: [], range: NSRange(location: 0, length: nsString.length))
                
                if let match = results.first, match.numberOfRanges >= 3 {
                    let potentialGroup = nsString.substring(with: match.range(at: 1))
                        .trimmingCharacters(in: .whitespacesAndNewlines)
                    let potentialCriterion = nsString.substring(with: match.range(at: 2))
                        .trimmingCharacters(in: .whitespacesAndNewlines)
                    
                    // Check that it's not two items separated by "and", "и", "vs", etc.
                    if !potentialGroup.lowercased().contains(" и ") && 
                       !potentialGroup.lowercased().contains(" and ") &&
                       !potentialGroup.lowercased().contains(" vs ") &&
                       !potentialGroup.lowercased().contains(" versus ") &&
                       !potentialGroup.lowercased().contains(" против ") &&
                       !potentialGroup.lowercased().contains(" y ") &&
                       !potentialGroup.lowercased().contains(" et ") &&
                       !potentialGroup.lowercased().contains(" con ") &&
                       !potentialGroup.lowercased().contains(" avec ") {
                        // This looks like "Compare [group] by [criterion]" format
                        groupName = cleanItemName(potentialGroup)
                        let cleanedCriterion = cleanAttribute(potentialCriterion)
                        
                        // Check if criterion contains parentheses with a group name (e.g., "composition (minerals)")
                        let parenthesesPattern = #"\(([^)]+)\)"#
                        if let regex = try? NSRegularExpression(pattern: parenthesesPattern, options: .caseInsensitive) {
                            let nsString = cleanedCriterion as NSString
                            let results = regex.matches(in: cleanedCriterion, options: [], range: NSRange(location: 0, length: nsString.length))
                            
                            if let match = results.first, match.numberOfRanges >= 2 {
                                let groupInParentheses = nsString.substring(with: match.range(at: 1))
                                    .trimmingCharacters(in: .whitespacesAndNewlines)
                                
                                // This is a group of attributes (e.g., "minerals")
                                attributeGroupName = cleanItemName(groupInParentheses)
                                
                                // Remove parentheses and use the main criterion name (e.g., "composition")
                                let normalizedCriterion = cleanedCriterion
                                    .replacingOccurrences(of: #"\([^)]*\)"#, with: "", options: .regularExpression)
                                    .trimmingCharacters(in: .whitespacesAndNewlines)
                                
                                // If criterion is empty after removing parentheses, don't set attributes
                                // They will be generated from the attributeGroupName
                                if !normalizedCriterion.isEmpty {
                                    attributes = [normalizeAttributeName(normalizedCriterion)]
                                }
                            } else {
                                // No parentheses, treat as regular criterion
                                var normalizedCriterion = cleanedCriterion
                                    .replacingOccurrences(of: #"\([^)]*\)"#, with: "", options: .regularExpression)
                                    .trimmingCharacters(in: .whitespacesAndNewlines)
                                if normalizedCriterion.isEmpty {
                                    normalizedCriterion = cleanedCriterion
                                }
                                attributes = [normalizeAttributeName(normalizedCriterion)]
                            }
                        } else {
                            // No parentheses pattern found, treat as regular criterion
                            var normalizedCriterion = cleanedCriterion
                                .replacingOccurrences(of: #"\([^)]*\)"#, with: "", options: .regularExpression)
                                .trimmingCharacters(in: .whitespacesAndNewlines)
                            if normalizedCriterion.isEmpty {
                                normalizedCriterion = cleanedCriterion
                            }
                            attributes = [normalizeAttributeName(normalizedCriterion)]
                        }
                        // Skip normal criteria parsing
                    }
                }
            }
        }
        
        // Second, check for "X of Y" pattern (criterion of group) - e.g., "Caloric content of cereals"
        // Supports English "of", Spanish "de", French "de"
        let ofPattern = #"(.+?)\s+(?:of|de)\s+(.+?)$"#
        if items.isEmpty && attributes.isEmpty && groupName == nil {
            if let regex = try? NSRegularExpression(pattern: ofPattern, options: .caseInsensitive) {
                let nsString = request as NSString
                let results = regex.matches(in: request, options: [], range: NSRange(location: 0, length: nsString.length))
                
                if let match = results.first, match.numberOfRanges >= 3 {
                    let potentialCriterion = nsString.substring(with: match.range(at: 1))
                        .trimmingCharacters(in: .whitespacesAndNewlines)
                    let potentialGroup = nsString.substring(with: match.range(at: 2))
                        .trimmingCharacters(in: .whitespacesAndNewlines)
                    
                    // Check that it's not "compare X of Y"
                    if !lowercased.hasPrefix("compare") && !lowercased.hasPrefix("сравни") {
                        // This looks like "criterion of group" format
                        // НЕ используем cleanItemName, чтобы сохранить прилагательные (например, "beautiful cities")
                        groupName = potentialGroup.trimmingCharacters(in: .whitespacesAndNewlines)
                        let cleanedCriterion = cleanAttribute(potentialCriterion)
                        attributes = [normalizeAttributeName(cleanedCriterion)]
                        // Skip normal criteria parsing
                    }
                }
            }
        }
        
        // Third, check for "Y by X" pattern (group by criterion) - but NOT if it starts with "compare"
        if items.isEmpty && attributes.isEmpty && groupName == nil {
            let byPattern = #"(.+?)\s+by\s+(.+?)$"#
            if let regex = try? NSRegularExpression(pattern: byPattern, options: .caseInsensitive) {
                let nsString = request as NSString
                let results = regex.matches(in: request, options: [], range: NSRange(location: 0, length: nsString.length))
                
                if let match = results.first, match.numberOfRanges >= 3 {
                    let potentialGroup = nsString.substring(with: match.range(at: 1))
                        .trimmingCharacters(in: .whitespacesAndNewlines)
                    let potentialCriterion = nsString.substring(with: match.range(at: 2))
                        .trimmingCharacters(in: .whitespacesAndNewlines)
                    
                    // Check that it's not "compare X by Y" (this should have been caught above)
                    if !lowercased.hasPrefix("compare") && !lowercased.hasPrefix("сравни") {
                        // This looks like "group by criterion" format
                        // НЕ используем cleanItemName, чтобы сохранить прилагательные (например, "tropical fruits")
                        groupName = potentialGroup.trimmingCharacters(in: .whitespacesAndNewlines)
                        let cleanedCriterion = cleanAttribute(potentialCriterion)
                        // Remove parentheses and extra spaces from criterion
                        var normalizedCriterion = cleanedCriterion
                            .replacingOccurrences(of: #"\([^)]*\)"#, with: "", options: .regularExpression)
                            .trimmingCharacters(in: .whitespacesAndNewlines)
                        // If criterion is empty after removing parentheses, use the original
                        if normalizedCriterion.isEmpty {
                            normalizedCriterion = cleanedCriterion
                        }
                        attributes = [normalizeAttributeName(normalizedCriterion)]
                        // Skip normal criteria parsing
                    }
                }
            }
        }
        
        // Look for criteria after keywords (English and Russian) - only if not already found
        if attributes.isEmpty {
            let criteriaKeywords = [
                // English
                "in terms of", "by", "criteria", "parameters", "based on",
                // Russian
                "по", "критерии", "критериям", "по параметрам", "параметры", "по критериям"
            ]
            var criteriaStartIndex: String.Index?
            var criteriaKeyword: String?
            
            // Используем NSString для безопасного поиска с учетом регистра
            let nsRequest = request as NSString
            let lowercasedNS = lowercased as NSString
            
            for keyword in criteriaKeywords {
                let range = lowercasedNS.range(of: keyword, options: .caseInsensitive)
                if range.location != NSNotFound {
                    // Преобразуем NSRange в String.Index
                    let keywordEndLocation = range.location + range.length
                    if keywordEndLocation <= nsRequest.length {
                        criteriaStartIndex = request.index(request.startIndex, offsetBy: keywordEndLocation)
                        criteriaKeyword = keyword
                        break
                    }
                }
            }
            
            if let startIndex = criteriaStartIndex, startIndex < request.endIndex {
                var criteriaString = String(request[startIndex...]).trimmingCharacters(in: .whitespacesAndNewlines)
                
                // Убираем лишние слова в начале
                if let keyword = criteriaKeyword, criteriaString.lowercased().hasPrefix(keyword) {
                    let keywordIndex = criteriaString.index(criteriaString.startIndex, offsetBy: keyword.count, limitedBy: criteriaString.endIndex) ?? criteriaString.endIndex
                    if keywordIndex <= criteriaString.endIndex {
                        criteriaString = String(criteriaString[keywordIndex...])
                            .trimmingCharacters(in: .whitespacesAndNewlines)
                    }
                }
                
                // Улучшенное разделение критериев
                // Сначала разделяем по запятым (основной разделитель)
                let rawAttributes = criteriaString.components(separatedBy: ",")
                
                // Обрабатываем каждый атрибут
                attributes = []
                for rawAttr in rawAttributes {
                    let trimmed = rawAttr.trimmingCharacters(in: .whitespacesAndNewlines)
                    
                    // If attribute contains "and" or "и" (as separate word), split by it
                    // Use regex to find "and" or "и" as separate words
                    let andPattern = #"\s+(?:and|и)\s+"#
                    if let regex = try? NSRegularExpression(pattern: andPattern, options: .caseInsensitive) {
                        let nsString = trimmed as NSString
                        let matches = regex.matches(in: trimmed, options: [], range: NSRange(location: 0, length: nsString.length))
                        
                        if !matches.isEmpty {
                            // Разделяем по "и" - находим все позиции и разбиваем строку
                            var parts: [String] = []
                            var lastIndex = 0
                            
                            for match in matches {
                                if match.range.location > lastIndex {
                                    let part = nsString.substring(with: NSRange(location: lastIndex, length: match.range.location - lastIndex))
                                    let trimmedPart = part.trimmingCharacters(in: .whitespacesAndNewlines)
                                    if !trimmedPart.isEmpty {
                                        parts.append(trimmedPart)
                                    }
                                }
                                lastIndex = match.range.location + match.range.length
                            }
                            
                            // Добавляем остаток после последнего "и"
                            if lastIndex < nsString.length {
                                let part = nsString.substring(from: lastIndex)
                                let trimmedPart = part.trimmingCharacters(in: .whitespacesAndNewlines)
                                if !trimmedPart.isEmpty {
                                    parts.append(trimmedPart)
                                }
                            }
                            
                            if !parts.isEmpty {
                                attributes.append(contentsOf: parts)
                            } else {
                                // Если не удалось разделить, добавляем как есть
                                if !trimmed.isEmpty {
                                    attributes.append(trimmed)
                                }
                            }
                        } else {
                            // Нет "и" внутри, добавляем как есть
                            if !trimmed.isEmpty {
                                attributes.append(trimmed)
                            }
                        }
                    } else {
                        // Если regex не работает, просто добавляем
                        if !trimmed.isEmpty {
                            attributes.append(trimmed)
                        }
                    }
                }
                
                // Clean and filter attributes
                attributes = attributes
                    .map { cleanAttribute($0) } // Clean attribute: remove "and" at start, punctuation at end
                    .filter { !$0.isEmpty && $0.count > 1 }
                    .map { normalizeAttributeName($0) } // Normalize names (калориям -> калорийность)
                
                // Удаляем дубликаты, сохраняя порядок
                var uniqueAttributes: [String] = []
                var seen = Set<String>()
                for attr in attributes {
                    let lowercased = attr.lowercased()
                    if !seen.contains(lowercased) {
                        seen.insert(lowercased)
                        uniqueAttributes.append(attr)
                    }
                }
                attributes = uniqueAttributes
            }
        }
        
        // Если не нашли критерии, но нашли объекты, пытаемся найти их после объектов
        if attributes.isEmpty && !items.isEmpty {
            // Ищем текст после второго объекта
            let secondItem = items[1]
            
            // Ищем позицию второго объекта
            if let secondItemRange = request.range(of: secondItem, options: .caseInsensitive),
               secondItemRange.upperBound < request.endIndex {
                let afterSecondItem = String(request[secondItemRange.upperBound...])
                    .trimmingCharacters(in: .whitespacesAndNewlines)
                
                // If there's "in terms of", "by", or "по" after the second item
                let criteriaStartKeywords = ["in terms of", "by", "по"]
                var foundKeyword: String?
                var keywordIndex: String.Index?
                
                for keyword in criteriaStartKeywords {
                    if let index = afterSecondItem.lowercased().range(of: keyword),
                       index.upperBound < afterSecondItem.endIndex {
                        foundKeyword = keyword
                        keywordIndex = index.upperBound
                        break
                    }
                }
                
                if let _ = foundKeyword, let startIndex = keywordIndex {
                    let afterPo = String(afterSecondItem[startIndex...])
                        .trimmingCharacters(in: .whitespacesAndNewlines)
                    
                    // Улучшенное разделение критериев
                    // Сначала разделяем по запятым
                    let rawAttributes = afterPo.components(separatedBy: ",")
                    
                    // Обрабатываем каждый атрибут
                    var extractedAttributes: [String] = []
                    for rawAttr in rawAttributes {
                        let trimmed = rawAttr.trimmingCharacters(in: .whitespacesAndNewlines)
                        
                        // Split by "and" or "и" only if it's a separate word
                        let andPattern = #"\s+(?:and|и)\s+"#
                        if let regex = try? NSRegularExpression(pattern: andPattern, options: .caseInsensitive) {
                            let nsString = trimmed as NSString
                            let matches = regex.matches(in: trimmed, options: [], range: NSRange(location: 0, length: nsString.length))
                            
                            if !matches.isEmpty {
                                // Разделяем по "и"
                                var parts: [String] = []
                                var lastIndex = 0
                                
                                for match in matches {
                                    if match.range.location > lastIndex {
                                        let part = nsString.substring(with: NSRange(location: lastIndex, length: match.range.location - lastIndex))
                                        let trimmedPart = part.trimmingCharacters(in: .whitespacesAndNewlines)
                                        if !trimmedPart.isEmpty {
                                            parts.append(trimmedPart)
                                        }
                                    }
                                    lastIndex = match.range.location + match.range.length
                                }
                                
                                // Добавляем остаток
                                if lastIndex < nsString.length {
                                    let part = nsString.substring(from: lastIndex)
                                    let trimmedPart = part.trimmingCharacters(in: .whitespacesAndNewlines)
                                    if !trimmedPart.isEmpty {
                                        parts.append(trimmedPart)
                                    }
                                }
                                
                                if !parts.isEmpty {
                                    extractedAttributes.append(contentsOf: parts)
                                } else {
                                    if !trimmed.isEmpty {
                                        extractedAttributes.append(trimmed)
                                    }
                                }
                            } else {
                                if !trimmed.isEmpty {
                                    extractedAttributes.append(trimmed)
                                }
                            }
                        } else {
                            if !trimmed.isEmpty {
                                extractedAttributes.append(trimmed)
                            }
                        }
                    }
                    
                    attributes = extractedAttributes
                        .map { cleanAttribute($0) } // Clean attributes
                        .filter { !$0.isEmpty && $0.count > 1 }
                        .map { normalizeAttributeName($0) } // Normalize names
                }
            }
        }
        
        // If items not found and group not found yet, check if request is for comparing a group
        // CRITICAL: Only check for groups if NO specific items were found (items.isEmpty)
        // Objects should NEVER be grouped - if specific items are listed, they must remain separate
        // Supports groups with descriptive adjectives: "красивые города", "beautiful cities", "ciudades hermosas", "belles villes"
        if items.isEmpty && groupName == nil {
            // Patterns for recognizing groups: "compare fruits", "сравни фрукты", "compare beautiful cities", "сравни красивые города", etc.
            let groupPatterns = [
                // English patterns
                "compare\\s+(.+?)(?:\\s+(?:in\\s+terms\\s+of|by)|$)",  // "compare fruits" or "compare fruits by..." or "compare beautiful cities"
                "i\\s+want\\s+to\\s+compare\\s+(.+?)(?:\\s+(?:in\\s+terms\\s+of|by)|$)",  // "I want to compare fruits..." or "I want to compare beautiful cities..."
                // Russian patterns
                "сравни\\s+(.+?)(?:\\s+по|$)",  // "сравни фрукты" или "сравни фрукты по..." или "сравни красивые города"
                "сравнить\\s+(.+?)(?:\\s+по|$)",  // "сравнить фрукты" или "сравнить фрукты по..." или "сравнить домашних животных"
                "хочу\\s+сравнить\\s+(.+?)(?:\\s+по|$)",  // "хочу сравнить фрукты" или "хочу сравнить фрукты по..." или "хочу сравнить тропические фрукты"
                // Spanish patterns
                "comparar\\s+(.+?)(?:\\s+(?:por|en\\s+términos\\s+de|según)|$)",  // "comparar frutas" or "comparar ciudades hermosas"
                "quiero\\s+comparar\\s+(.+?)(?:\\s+(?:por|en\\s+términos\\s+de)|$)",  // "quiero comparar frutas" or "quiero comparar ciudades hermosas"
                // French patterns
                "comparer\\s+(.+?)(?:\\s+(?:par|en\\s+termes\\s+de|selon)|$)",  // "comparer fruits" or "comparer belles villes"
                "je\\s+veux\\s+comparer\\s+(.+?)(?:\\s+(?:par|en\\s+termes\\s+de)|$)",  // "je veux comparer fruits" or "je veux comparer belles villes"
            ]
            
            for pattern in groupPatterns {
                if let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive) {
                    let nsString = request as NSString
                    let results = regex.matches(in: request, options: [], range: NSRange(location: 0, length: nsString.length))
                    
                    if let match = results.first, match.numberOfRanges >= 2 {
                        let potentialGroup = nsString.substring(with: match.range(at: 1))
                            .trimmingCharacters(in: .whitespacesAndNewlines)
                        
                        // Check that it's not two items separated by "and", "и", "vs", etc.
                        if !potentialGroup.lowercased().contains(" и ") && 
                           !potentialGroup.lowercased().contains(" and ") &&
                           !potentialGroup.lowercased().contains(" vs ") &&
                           !potentialGroup.lowercased().contains(" versus ") &&
                           !potentialGroup.lowercased().contains(" против ") &&
                           !potentialGroup.lowercased().contains(" y ") &&
                           !potentialGroup.lowercased().contains(" et ") &&
                           !potentialGroup.lowercased().contains(" con ") &&
                           !potentialGroup.lowercased().contains(" avec ") {
                            // Это похоже на группу (может быть с прилагательным: "красивые города", "beautiful cities")
                            // НЕ используем cleanItemName здесь, чтобы сохранить прилагательные
                            groupName = potentialGroup.trimmingCharacters(in: .whitespacesAndNewlines)
                            if !groupName!.isEmpty {
                                break
                            }
                        }
                    }
                }
            }
        }
        
        // Если критерии не найдены, возвращаем nil - они будут сгенерированы через AI
        return (items: items.isEmpty ? nil : items, attributes: attributes.isEmpty ? nil : attributes, groupName: groupName, attributeGroupName: attributeGroupName)
    }
    
    /// Очищает название атрибута от лишних слов и знаков препинания
    /// Убирает "and" в начале, точки в конце и т.д.
    private func cleanAttribute(_ name: String) -> String {
        var cleaned = name.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Remove "and" or "и" at the beginning
        let prefixesToRemove = ["and ", "и ", "AND ", "И "]
        for prefix in prefixesToRemove {
            if cleaned.lowercased().hasPrefix(prefix.lowercased()) {
                cleaned = String(cleaned.dropFirst(prefix.count))
                cleaned = cleaned.trimmingCharacters(in: .whitespacesAndNewlines)
            }
        }
        
        // Remove punctuation at the end (.,;:!?)
        let punctuation = CharacterSet(charactersIn: ".,;:!?")
        cleaned = cleaned.trimmingCharacters(in: punctuation)
        cleaned = cleaned.trimmingCharacters(in: .whitespacesAndNewlines)
        
        return cleaned
    }
    
    /// Нормализует название критерия, преобразуя падежные формы в нормальную форму
    /// Например: "калориям" -> "калорийность", "стоимости" -> "стоимость"
    private func normalizeAttributeName(_ name: String) -> String {
        let lowercased = name.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Специальные правила для сложных атрибутов (убираем лишние слова)
        // "сложность ухода" -> "уход", "сложности ухода" -> "уход"
        if lowercased.contains("сложность") && lowercased.contains("уход") {
            return "уход"
        }
        if lowercased.contains("difficulty") && lowercased.contains("care") {
            return "care"
        }
        if lowercased.contains("difficulty") && lowercased.contains("maintenance") {
            return "maintenance"
        }
        
        // Словарь для прямых замен распространенных падежных форм
        let normalizationMap: [String: String] = [
            // Дательный падеж множественного числа -> нормальная форма
            "калориям": "калорийность",
            "возможностям": "возможности",
            "технологиям": "технологичность",
            "стоимостям": "стоимость",
            "ценам": "цена",
            "параметрам": "параметры",
            "критериям": "критерии",
            "сложности ухода": "уход",
            "сложность ухода": "уход",
            
            // Родительный/дательный падеж единственного числа -> нормальная форма
            "калории": "калорийность",
            "стоимости": "стоимость",
            "технологичности": "технологичность",
            "возможности": "возможности",
            "цены": "цена",
            "параметра": "параметр",
            "критерия": "критерий",
            "ухода": "уход",
            
            // Творительный падеж
            "калориями": "калорийность",
            "стоимостями": "стоимость",
            "технологиями": "технологичность",
        ]
        
        // Проверяем прямые совпадения
        if let normalized = normalizationMap[lowercased] {
            return normalized
        }
        
        // Правила для распространенных окончаний
        var normalized = lowercased
        
        // Дательный падеж множественного числа: -ам, -ям -> убираем окончание и добавляем суффикс
        if normalized.hasSuffix("ам") && normalized.count > 3 {
            let stem = String(normalized.dropLast(2))
            // Попытка преобразовать в нормальную форму
            if stem.hasSuffix("калори") {
                normalized = "калорийность"
            } else if stem.hasSuffix("возможност") {
                normalized = "возможности"
            } else if stem.hasSuffix("технолог") {
                normalized = "технологичность"
            } else if stem.hasSuffix("стоимост") {
                normalized = "стоимость"
            } else if stem.hasSuffix("цен") {
                normalized = "цена"
            } else {
                // Общее правило: убираем окончание
                normalized = stem
            }
        } else if normalized.hasSuffix("ям") && normalized.count > 3 {
            let stem = String(normalized.dropLast(2))
            if stem.hasSuffix("возможност") {
                normalized = "возможности"
            } else if stem.hasSuffix("технолог") {
                normalized = "технологичность"
            } else {
                normalized = stem
            }
        }
        // Родительный/дательный падеж единственного числа: -и, -ы -> убираем окончание
        else if normalized.hasSuffix("и") && normalized.count > 2 && !normalized.hasSuffix("сти") {
            let stem = String(normalized.dropLast(1))
            if stem.hasSuffix("калори") {
                normalized = "калорийность"
            } else if stem.hasSuffix("стоимост") {
                normalized = "стоимость"
            } else if stem.hasSuffix("технологичност") {
                normalized = "технологичность"
            } else {
                normalized = stem
            }
        }
        // Творительный падеж: -ами, -ями -> убираем окончание
        else if normalized.hasSuffix("ами") && normalized.count > 4 {
            let stem = String(normalized.dropLast(3))
            normalized = stem
        } else if normalized.hasSuffix("ями") && normalized.count > 4 {
            let stem = String(normalized.dropLast(3))
            normalized = stem
        }
        
        // Сохраняем регистр первой буквы оригинала
        if name.first?.isUppercase == true {
            return normalized.capitalized
        }
        
        return normalized
    }
    
    /// Парсит список элементов, используя массив разделителей (слов-связок)
    /// CRITICAL: Always returns separate items, never groups them together
    private func parseItemsList(_ itemsString: String) -> [String] {
        var items: [String] = []
        
        let cleaned = itemsString.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Массив разделителей (слов-связок) для всех языков
        let separators = [" и ", " and ", " vs ", " versus ", " против ", " y ", " et ", " con ", " avec "]
        
        // Сначала проверяем наличие запятых
        if cleaned.contains(",") {
            // Заменяем все разделители на запятые для единообразной обработки
            var normalized = cleaned
            for separator in separators {
                normalized = normalized.replacingOccurrences(of: separator, with: ", ", options: .caseInsensitive)
            }
            
            // Разделяем по запятым - каждый элемент становится отдельным
            let parts = normalized.components(separatedBy: ",")
                .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                .filter { !$0.isEmpty }
            
            // CRITICAL: Each part is a separate item - never combine them
            items = parts.map { cleanItemName($0) }
            
            // Убеждаемся, что мы не потеряли элементы
            if items.count < parts.count {
                items = parts.map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                    .filter { !$0.isEmpty }
            }
        } else {
            // Нет запятых - разделяем по разделителям (словам-связкам)
            var parts: [String] = []
            let currentString = cleaned
            
            // Ищем все вхождения разделителей
            var foundSeparator: String? = nil
            for separator in separators {
                if currentString.contains(separator) {
                    foundSeparator = separator
                    break
                }
            }
            
            if let separator = foundSeparator {
                // Разделяем по найденному разделителю
                let components = currentString.components(separatedBy: separator)
                parts = components.map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                    .filter { !$0.isEmpty }
            }
            
            // Если не удалось разделить по разделителям, пробуем разделить по пробелам
            // Это для случаев типа "сравни Лондон Дубай Москва Токио" (без запятых и разделителей)
            if parts.isEmpty {
                let words = cleaned.components(separatedBy: .whitespaces)
                    .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                    .filter { !$0.isEmpty }
                
                // CRITICAL: If we have multiple words and no separators were found,
                // treat each word as a separate item
                if words.count >= 2 {
                    parts = words
                } else if words.count == 1 {
                    parts = words
                } else {
                    parts = [cleaned]
                }
            }
            
            // Очищаем каждый элемент
            items = parts.map { cleanItemName($0) }
        }
        
        return items
    }
    
    /// Очищает название объекта от лишних слов
    private func cleanItemName(_ name: String) -> String {
        var cleaned = name.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Remove words at the beginning that might be part of the pattern
        let prefixesToRemove = ["хочу", "нужно", "надо", "сравнить", "compare", "i want to", "want to"]
        for prefix in prefixesToRemove {
            if cleaned.lowercased().hasPrefix(prefix) {
                let prefixIndex = cleaned.index(cleaned.startIndex, offsetBy: prefix.count, limitedBy: cleaned.endIndex) ?? cleaned.endIndex
                if prefixIndex <= cleaned.endIndex {
                    cleaned = String(cleaned[prefixIndex...])
                        .trimmingCharacters(in: .whitespacesAndNewlines)
                }
            }
        }
        
        // Remove words at the end that might be the start of criteria
        let suffixesToRemove = ["по", "критериям", "критерии", "параметрам", "in terms of", "by", "criteria", "parameters"]
        for suffix in suffixesToRemove {
            if cleaned.lowercased().hasSuffix(suffix) && cleaned.count >= suffix.count {
                let suffixIndex = cleaned.index(cleaned.endIndex, offsetBy: -suffix.count, limitedBy: cleaned.startIndex) ?? cleaned.startIndex
                if suffixIndex >= cleaned.startIndex {
                    cleaned = String(cleaned[..<suffixIndex])
                        .trimmingCharacters(in: .whitespacesAndNewlines)
                }
            }
        }
        
        // Нормализуем русские названия к именительному падежу
        cleaned = normalizeItemToNominative(cleaned)
        
        return cleaned
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
                    return String(normalized.dropLast(1)) + "а"
                }
            }
            
            if normalized.hasSuffix("ю") && normalized.count > 2 {
                // Исключения
                let exceptions = ["меню"]
                if !exceptions.contains(lowercased) {
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
            // Это делаем только если они стоят отдельно в начале
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
    
    /// Нормализует категорию к именительному падежу (для русского языка)
    /// Например: "Фруктов" -> "Фрукты", "Городов" -> "Города"
    private func normalizeCategoryToNominative(_ category: String) -> String {
        let normalized = category.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Проверяем, является ли это русским текстом
        let hasRussian = normalized.range(of: "[а-яё]", options: .regularExpression) != nil
        
        if hasRussian {
            let lowercased = normalized.lowercased()
            
            // Родительный падеж множественного числа: -ов, -ев, -ей
            // Фруктов -> Фрукты
            if normalized.hasSuffix("ов") && normalized.count > 2 {
                return String(normalized.dropLast(2)) + "ы"
            }
            
            // -ев -> -и (например, для некоторых слов)
            if normalized.hasSuffix("ев") && normalized.count > 2 {
                // Проверяем, не является ли это словом, которое заканчивается на "ев" в именительном падеже
                let exceptions = ["лев", "медведь"]
                if !exceptions.contains(lowercased) {
                    return String(normalized.dropLast(2)) + "и"
                }
            }
            
            // Если уже в именительном падеже (заканчивается на -ы, -и, -а, -я), возвращаем как есть
            if normalized.hasSuffix("ы") || normalized.hasSuffix("и") || 
               normalized.hasSuffix("а") || normalized.hasSuffix("я") {
                return normalized
            }
        }
        
        return normalized
    }
    
    /// Определяет, содержит ли название группы описательное прилагательное
    /// - Parameter groupName: Название группы (например, "красивые города", "beautiful cities")
    /// - Parameter language: Язык группы
    /// - Returns: true, если название содержит прилагательное
    private func detectAdjectiveInGroupName(_ groupName: String, language: String) -> Bool {
        let lowercased = groupName.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        let words = lowercased.components(separatedBy: .whitespaces).filter { !$0.isEmpty }
        
        // Если меньше 2 слов, это не группа с прилагательным
        guard words.count >= 2 else {
            return false
        }
        
        // Русский: прилагательные обычно стоят перед существительным
        // Примеры: "красивые города", "домашних животных", "тропические фрукты"
        if language == "ru" {
            let firstWord = words[0]
            
            // Расширенный список окончаний прилагательных в русском языке
            let adjectiveEndings = [
                // Множественное число
                "ые", "ие", "ые", "их", "ых", "им", "ым", "ыми", "ыми",
                // Единственное число женский род
                "ая", "яя", "ую", "юю", "ой", "ей", "ую", "юю",
                // Единственное число средний род
                "ое", "ее", "ое", "ее",
                // Единственное число мужской род (винительный падеж)
                "ого", "его", "ому", "ему", "ым", "им"
            ]
            
            // Проверяем окончания
            for ending in adjectiveEndings {
                if firstWord.hasSuffix(ending) && firstWord.count > ending.count {
                    return true
                }
            }
            
            // Также проверяем распространенные прилагательные
            let commonAdjectives = ["красивые", "красивый", "красивая", "красивое",
                                   "домашних", "домашние", "домашний", "домашняя", "домашнее",
                                   "тропические", "тропический", "тропическая", "тропическое",
                                   "дикие", "дикий", "дикая", "дикое",
                                   "экзотические", "экзотический", "экзотическая", "экзотическое",
                                   "популярные", "популярный", "популярная", "популярное",
                                   "известные", "известный", "известная", "известное",
                                   "лучшие", "лучший", "лучшая", "лучшее",
                                   "большие", "большой", "большая", "большое",
                                   "маленькие", "маленький", "маленькая", "маленькое",
                                   "новые", "новый", "новая", "новое",
                                   "старые", "старый", "старая", "старое",
                                   "современные", "современный", "современная", "современное",
                                   "древние", "древний", "древняя", "древнее"]
            
            if commonAdjectives.contains(firstWord) {
                return true
            }
        }
        
        // Английский: прилагательные обычно стоят перед существительным
        // Примеры: "beautiful cities", "tropical fruits", "domestic animals"
        if language == "en" {
            // Расширенный список распространенных прилагательных
            let commonAdjectives = [
                "beautiful", "tropical", "domestic", "wild", "exotic", "popular", "famous", "best", "top",
                "large", "small", "big", "tiny", "old", "new", "modern", "ancient", "expensive", "cheap",
                "affordable", "luxury", "premium", "common", "rare", "famous", "well-known", "prestigious",
                "affordable", "budget", "high-end", "premium", "exotic", "native", "foreign", "local",
                "international", "global", "regional", "urban", "rural", "coastal", "mountain", "desert",
                "tropical", "temperate", "arctic", "mediterranean", "continental", "island", "mainland"
            ]
            
            if commonAdjectives.contains(words[0]) {
                return true
            }
        }
        
        // Испанский: прилагательные могут стоять после существительного
        // Примеры: "ciudades hermosas", "frutas tropicales", "animales domésticos"
        if language == "es" {
            let commonAdjectives = [
                "hermosas", "hermosos", "hermosa", "hermoso",
                "tropicales", "tropical", "tropicales",
                "domésticos", "domésticas", "doméstico", "doméstica",
                "populares", "popular",
                "famosos", "famosas", "famoso", "famosa",
                "mejores", "mejor",
                "grandes", "grande",
                "pequeños", "pequeñas", "pequeño", "pequeña",
                "nuevos", "nuevas", "nuevo", "nueva",
                "antiguos", "antiguas", "antiguo", "antigua",
                "modernos", "modernas", "moderno", "moderna",
                "exóticos", "exóticas", "exótico", "exótica",
                "populares", "popular"
            ]
            
            // Проверяем первое и последнее слово
            if commonAdjectives.contains(words[0]) || commonAdjectives.contains(words.last ?? "") {
                return true
            }
        }
        
        // Французский: прилагательные могут стоять до или после существительного
        // Примеры: "belles villes", "villes belles", "fruits tropicaux", "animaux domestiques"
        if language == "fr" {
            let commonAdjectives = [
                "belles", "beaux", "belle", "beau",
                "tropicaux", "tropicales", "tropical", "tropicale",
                "domestiques", "domestique",
                "populaires", "populaire",
                "célèbres", "célèbre",
                "meilleurs", "meilleures", "meilleur", "meilleure",
                "grandes", "grands", "grande", "grand",
                "petits", "petites", "petit", "petite",
                "nouveaux", "nouvelles", "nouveau", "nouvelle",
                "anciens", "anciennes", "ancien", "ancienne",
                "modernes", "moderne",
                "exotiques", "exotique"
            ]
            
            // Проверяем первое и последнее слово
            if commonAdjectives.contains(words[0]) || commonAdjectives.contains(words.last ?? "") {
                return true
            }
        }
        
        // Общий подход: если первое слово не является известным существительным (для всех языков),
        // и группа состоит из 2+ слов, то вероятно это прилагательное
        // Известные существительные (города, фрукты, животные и т.д.)
        let commonNouns = [
            // Русский
            "города", "город", "фрукты", "фрукт", "животные", "животное", "животных",
            "овощи", "овощ", "машины", "машина", "телефоны", "телефон", "страны", "страна",
            "столицы", "столица", "реки", "река", "горы", "гора", "острова", "остров",
            // Английский
            "cities", "city", "fruits", "fruit", "animals", "animal", "vegetables", "vegetable",
            "cars", "car", "phones", "phone", "countries", "country", "capitals", "capital",
            "rivers", "river", "mountains", "mountain", "islands", "island",
            // Испанский
            "ciudades", "ciudad", "frutas", "fruta", "animales", "animal", "verduras", "verdura",
            "coches", "coche", "teléfonos", "teléfono", "países", "país", "capitales", "capital",
            "ríos", "río", "montañas", "montaña", "islas", "isla",
            // Французский
            "villes", "ville", "fruits", "fruit", "animaux", "animal", "légumes", "légume",
            "voitures", "voiture", "téléphones", "téléphone", "pays", "capitales", "capitale",
            "rivières", "rivière", "montagnes", "montagne", "îles", "île"
        ]
        
        // Если первое слово не является известным существительным, и группа состоит из 2+ слов,
        // то вероятно это прилагательное
        if !commonNouns.contains(words[0]) && words.count >= 2 {
            return true
        }
        
        // Дополнительная проверка: если группа состоит из 2+ слов и последнее слово - известное существительное,
        // а первое слово не является существительным, то первое слово - прилагательное
        if words.count >= 2 {
            let lastWord = words.last ?? ""
            let firstWord = words[0]
            
            // Если последнее слово - известное существительное, а первое - нет, то первое - прилагательное
            if commonNouns.contains(lastWord) && !commonNouns.contains(firstWord) {
                return true
            }
        }
        
        return false
    }
    
    /// Определяет язык запроса пользователя
    /// - Parameter text: Текст запроса
    /// - Returns: Код языка ("en", "ru", "es", "fr")
    private func detectLanguage(_ text: String) -> String {
        // Проверяем наличие кириллицы (русский)
        if text.range(of: "[а-яё]", options: .regularExpression) != nil {
            return "ru"
        }
        
        // Проверяем испанские символы
        if text.range(of: "[áéíóúñü]", options: .regularExpression) != nil {
            return "es"
        }
        
        // Проверяем французские символы
        if text.range(of: "[àâäéèêëïîôùûüÿç]", options: .regularExpression) != nil {
            return "fr"
        }
        
        // По умолчанию английский
        return "en"
    }
    
    /// Генерирует популярные объекты из группы через AI
    /// - Parameter groupName: Название группы (например, "фрукты", "города", "телефоны")
    /// - Parameter language: Язык для генерации ("en", "ru", "es", "fr")
    /// - Returns: Массив из 5 популярных объектов из группы
    private func generateItemsFromGroup(_ groupName: String, language: String = "en") async throws -> [String] {
        // Определяем, содержит ли название группы описательное прилагательное
        let hasAdjective = detectAdjectiveInGroupName(groupName, language: language)
        
        // Проверяем, состоит ли группа из 2+ слов (вероятно содержит прилагательное)
        let words = groupName.components(separatedBy: .whitespaces).filter { !$0.isEmpty }
        let hasMultipleWords = words.count >= 2
        
        let languageInstruction: String
        switch language {
        case "ru":
            languageInstruction = "CRITICAL: Return all item names in RUSSIAN language."
        case "es":
            languageInstruction = "CRITICAL: Return all item names in SPANISH language."
        case "fr":
            languageInstruction = "CRITICAL: Return all item names in FRENCH language."
        default:
            languageInstruction = "CRITICAL: Return all item names in ENGLISH language."
        }
        
        // ВСЕГДА учитываем полное название группы, особенно если оно состоит из нескольких слов
        // Это критически важно для групп с прилагательными
        let categoryInstruction = (hasAdjective || hasMultipleWords) ? """
        
        CRITICAL: The category name is "\(groupName)". 
        
        IMPORTANT: This category name contains MULTIPLE WORDS. You MUST consider ALL words in the name, not just the last word.
        
        If the name contains a descriptive adjective (like "красивые", "beautiful", "tropical", "тропические", "hermosas", "belles"), 
        you MUST select items that match BOTH the adjective AND the noun.
        
        Examples of correct interpretation:
        - Category "красивые города" (beautiful cities) → select BEAUTIFUL cities like Paris, Venice, Prague, NOT just any cities
        - Category "домашних животных" (domestic animals) → select DOMESTIC/PET animals like dog, cat, rabbit, NOT wild animals
        - Category "тропические фрукты" (tropical fruits) → select TROPICAL fruits like mango, pineapple, papaya, NOT temperate fruits
        - Category "beautiful cities" → select BEAUTIFUL cities, NOT just any cities
        - Category "tropical fruits" → select TROPICAL fruits, NOT just any fruits
        - Category "ciudades hermosas" → select BEAUTIFUL cities (hermosas = beautiful)
        - Category "belles villes" → select BEAUTIFUL cities (belles = beautiful)
        
        DO NOT ignore any words in the category name! Every word is important for defining the category.
        If the first word is an adjective, it describes what kind of items you should select.
        """ : """
        
        IMPORTANT: The category name is "\(groupName)". 
        Select items that belong to this specific category.
        """
        
        let prompt = """
        You are an analytical assistant for the Choose Right application.

        TASK:
        Create a list of 5 most popular and well-known items from the category "\(groupName)".
        Return the result STRICTLY in JSON format.
        \(languageInstruction)\(categoryInstruction)

        CRITICAL RULES:
        1. Return ONLY valid JSON, without any text before or after
        2. DO NOT use markdown code blocks (```json or ```)
        3. DO NOT add explanations or comments
        4. Select exactly 5 most popular and well-known items from this category
        5. Use short item names (1-3 words)
        6. Names must be clear and specific
        7. Items MUST match the FULL category name "\(groupName)" - consider ALL words in the name, especially if it contains descriptive adjectives

        REQUIRED JSON FORMAT:
        {
          "items": ["item 1", "item 2", "item 3", "item 4", "item 5"]
        }

        IMPORTANT: Return ONLY the JSON object starting with { and ending with }. No other text!
        """
        
        let jsonResponse = try await callLLMAPI(prompt: prompt)
        
        // Парсим JSON ответ
        struct ItemsResponse: Codable {
            let items: [String]
        }
        
        // Очищаем ответ от возможных markdown блоков
        var cleanedJSON = jsonResponse.trimmingCharacters(in: .whitespacesAndNewlines)
        if cleanedJSON.hasPrefix("```json") {
            cleanedJSON = String(cleanedJSON.dropFirst(7))
        } else if cleanedJSON.hasPrefix("```") {
            cleanedJSON = String(cleanedJSON.dropFirst(3))
        }
        if cleanedJSON.hasSuffix("```") {
            cleanedJSON = String(cleanedJSON.dropLast(3))
        }
        cleanedJSON = cleanedJSON.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Ищем начало JSON объекта
        if let startIndex = cleanedJSON.firstIndex(of: "{"),
           let endIndex = cleanedJSON.lastIndex(of: "}"),
           startIndex <= endIndex {
            cleanedJSON = String(cleanedJSON[startIndex...endIndex])
        }
        
        guard let data = cleanedJSON.data(using: .utf8) else {
            // Fallback: возвращаем дефолтные объекты в зависимости от группы и языка
            return getFallbackItemsForGroup(groupName, language: language)
        }
        
        let decoder = JSONDecoder()
        do {
            let response = try decoder.decode(ItemsResponse.self, from: data)
            // Фильтруем и валидируем объекты
            let validItems = response.items
                .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                .filter { !$0.isEmpty && $0.count > 1 }
            
            // Если получили валидные объекты, возвращаем их (ровно 5)
            if !validItems.isEmpty {
                return Array(validItems.prefix(5))
            }
        } catch _ {
            // Если парсинг не удался, пытаемся извлечь вручную
            if let items = extractItemsManually(from: cleanedJSON) {
                return items
            }
        }
        
        // Fallback: возвращаем дефолтные объекты на правильном языке
        return getFallbackItemsForGroup(groupName, language: language)
    }
    
    /// Извлекает объекты вручную из текста, если JSON парсинг не удался
    private func extractItemsManually(from text: String) -> [String]? {
        // Ищем паттерн "items": ["объект 1", "объект 2", ...]
        let pattern = #""items"\s*:\s*\[(.*?)\]"#
        
        guard let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive) else {
            return nil
        }
        
        let nsString = text as NSString
        let matches = regex.matches(in: text, options: [], range: NSRange(location: 0, length: nsString.length))
        
        guard let match = matches.first, match.numberOfRanges > 1 else {
            return nil
        }
        
        let itemsRange = match.range(at: 1)
        let itemsString = nsString.substring(with: itemsRange)
        
        // Парсим значения из строки
        let items = itemsString
            .components(separatedBy: ",")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines)
                .replacingOccurrences(of: "\"", with: "")
                .replacingOccurrences(of: "'", with: "") }
            .filter { !$0.isEmpty && $0.count > 1 }
        
        return items.isEmpty ? nil : Array(items.prefix(5))
    }
    
    /// Возвращает дефолтные объекты для группы, если AI не смог сгенерировать
    /// - Parameter groupName: Название группы
    /// - Parameter language: Язык для возврата значений ("en", "ru", "es", "fr")
    private func getFallbackItemsForGroup(_ groupName: String, language: String = "en") -> [String] {
        let lowercased = groupName.lowercased()
        
        // Определяем значения в зависимости от языка
        switch language {
        case "ru":
            if lowercased.contains("fruit") || lowercased.contains("фрукт") {
                return ["Яблоко", "Банан", "Апельсин", "Клубника", "Виноград"]
            } else if lowercased.contains("vegetable") || lowercased.contains("овощ") {
                return ["Помидор", "Огурец", "Морковь", "Картофель", "Лук"]
            } else if lowercased.contains("city") || lowercased.contains("cities") || lowercased.contains("город") {
                return ["Нью-Йорк", "Лондон", "Токио", "Париж", "Сидней"]
            } else if lowercased.contains("phone") || lowercased.contains("smartphone") || lowercased.contains("телефон") {
                return ["iPhone", "Samsung Galaxy", "Xiaomi", "Huawei", "OnePlus"]
            } else if lowercased.contains("car") || lowercased.contains("автомобиль") || lowercased.contains("машина") {
                return ["Toyota", "BMW", "Mercedes-Benz", "Audi", "Volkswagen"]
            } else if lowercased.contains("laptop") || lowercased.contains("computer") || lowercased.contains("ноутбук") {
                return ["MacBook", "ThinkPad", "Dell XPS", "HP", "ASUS"]
            }
            return ["Элемент 1", "Элемент 2", "Элемент 3", "Элемент 4", "Элемент 5"]
            
        case "es":
            if lowercased.contains("fruit") || lowercased.contains("fruta") {
                return ["Manzana", "Plátano", "Naranja", "Fresa", "Uva"]
            } else if lowercased.contains("vegetable") || lowercased.contains("verdura") {
                return ["Tomate", "Pepino", "Zanahoria", "Patata", "Cebolla"]
            } else if lowercased.contains("city") || lowercased.contains("cities") || lowercased.contains("ciudad") {
                return ["Nueva York", "Londres", "Tokio", "París", "Sídney"]
            } else if lowercased.contains("phone") || lowercased.contains("smartphone") || lowercased.contains("teléfono") {
                return ["iPhone", "Samsung Galaxy", "Xiaomi", "Huawei", "OnePlus"]
            } else if lowercased.contains("car") || lowercased.contains("coche") || lowercased.contains("automóvil") {
                return ["Toyota", "BMW", "Mercedes-Benz", "Audi", "Volkswagen"]
            } else if lowercased.contains("laptop") || lowercased.contains("computer") || lowercased.contains("portátil") {
                return ["MacBook", "ThinkPad", "Dell XPS", "HP", "ASUS"]
            }
            return ["Elemento 1", "Elemento 2", "Elemento 3", "Elemento 4", "Elemento 5"]
            
        case "fr":
            if lowercased.contains("fruit") {
                return ["Pomme", "Banane", "Orange", "Fraise", "Raisin"]
            } else if lowercased.contains("vegetable") || lowercased.contains("légume") {
                return ["Tomate", "Concombre", "Carotte", "Pomme de terre", "Oignon"]
            } else if lowercased.contains("city") || lowercased.contains("cities") || lowercased.contains("ville") {
                return ["New York", "Londres", "Tokyo", "Paris", "Sydney"]
            } else if lowercased.contains("phone") || lowercased.contains("smartphone") || lowercased.contains("téléphone") {
                return ["iPhone", "Samsung Galaxy", "Xiaomi", "Huawei", "OnePlus"]
            } else if lowercased.contains("car") || lowercased.contains("voiture") || lowercased.contains("automobile") {
                return ["Toyota", "BMW", "Mercedes-Benz", "Audi", "Volkswagen"]
            } else if lowercased.contains("laptop") || lowercased.contains("computer") || lowercased.contains("ordinateur") {
                return ["MacBook", "ThinkPad", "Dell XPS", "HP", "ASUS"]
            }
            return ["Élément 1", "Élément 2", "Élément 3", "Élément 4", "Élément 5"]
            
        default: // English
            if lowercased.contains("fruit") {
                return ["Apple", "Banana", "Orange", "Strawberry", "Grape"]
            } else if lowercased.contains("vegetable") {
                return ["Tomato", "Cucumber", "Carrot", "Potato", "Onion"]
            } else if lowercased.contains("city") || lowercased.contains("cities") {
                return ["New York", "London", "Tokyo", "Paris", "Sydney"]
            } else if lowercased.contains("phone") || lowercased.contains("smartphone") {
                return ["iPhone", "Samsung Galaxy", "Xiaomi", "Huawei", "OnePlus"]
            } else if lowercased.contains("car") || lowercased.contains("automobile") {
                return ["Toyota", "BMW", "Mercedes-Benz", "Audi", "Volkswagen"]
            } else if lowercased.contains("laptop") || lowercased.contains("computer") {
                return ["MacBook", "ThinkPad", "Dell XPS", "HP", "ASUS"]
            }
            return ["Item 1", "Item 2", "Item 3", "Item 4", "Item 5"]
        }
    }
    
    /// Генерирует релевантные критерии для сравнения объектов через AI
    /// - Parameter items: Объекты для сравнения
    /// - Parameter language: Язык для генерации ("en", "ru", "es", "fr")
    /// - Returns: Массив критериев (3-5 штук)
    private func generateAttributesForItems(_ items: [String], language: String = "en") async throws -> [String] {
        let itemsList = items.enumerated().map { "\($0.offset + 1). \($0.element)" }.joined(separator: "\n")
        
        // Определяем язык для промпта
        let languageInstruction: String
        switch language {
        case "ru":
            languageInstruction = "CRITICAL: Return all attribute names in RUSSIAN language. Use Russian names for all criteria."
        case "es":
            languageInstruction = "CRITICAL: Return all attribute names in SPANISH language. Use Spanish names for all criteria."
        case "fr":
            languageInstruction = "CRITICAL: Return all attribute names in FRENCH language. Use French names for all criteria."
        default:
            languageInstruction = "CRITICAL: Return all attribute names in ENGLISH language. Use English names for all criteria."
        }
        
        let prompt = """
        You are an analytical assistant for the Choose Right application.

        TASK:
        Create a list of 3-5 relevant criteria for comparing the following items.
        Return the result STRICTLY in JSON format.

        ITEMS TO COMPARE:
        \(itemsList)

        \(languageInstruction)

        CRITICAL RULES:
        1. Return ONLY valid JSON, without any text before or after
        2. DO NOT use markdown code blocks (```json or ```)
        3. DO NOT add explanations or comments
        4. PRIORITY: Generate NON-NUMERICAL criteria (qualitative attributes like "culture", "climate", "transportation", "safety", "entertainment", etc.)
        5. AVOID numerical criteria (price, cost, calories, weight, etc.) unless they are essential for the comparison
        6. Focus on meaningful qualitative comparisons that help users make decisions
        7. Create 3 to 5 criteria that are truly important for comparing these items
        8. Criteria must be specific and clear
        9. Use short criterion names (1-3 words)

        REQUIRED JSON FORMAT:
        {
          "attributes": ["criterion 1", "criterion 2", "criterion 3", "criterion 4"]
        }

        IMPORTANT: Return ONLY the JSON object starting with { and ending with }. No other text!
        """
        
        let jsonResponse = try await callLLMAPI(prompt: prompt)
        
        // Парсим JSON ответ
        struct AttributesResponse: Codable {
            let attributes: [String]
        }
        
        // Очищаем ответ от возможных markdown блоков
        var cleanedJSON = jsonResponse.trimmingCharacters(in: .whitespacesAndNewlines)
        if cleanedJSON.hasPrefix("```json") {
            cleanedJSON = String(cleanedJSON.dropFirst(7))
        } else if cleanedJSON.hasPrefix("```") {
            cleanedJSON = String(cleanedJSON.dropFirst(3))
        }
        if cleanedJSON.hasSuffix("```") {
            cleanedJSON = String(cleanedJSON.dropLast(3))
        }
        cleanedJSON = cleanedJSON.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Ищем начало JSON объекта
        if let startIndex = cleanedJSON.firstIndex(of: "{"),
           let endIndex = cleanedJSON.lastIndex(of: "}"),
           startIndex <= endIndex {
            cleanedJSON = String(cleanedJSON[startIndex...endIndex])
        }
        
        guard let data = cleanedJSON.data(using: .utf8) else {
            // Fallback: возвращаем дефолтные критерии на правильном языке
            return getFallbackAttributes(language: language)
        }
        
        let decoder = JSONDecoder()
        do {
            let response = try decoder.decode(AttributesResponse.self, from: data)
            // Фильтруем и валидируем критерии
            let validAttributes = response.attributes
                .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                .filter { !$0.isEmpty && $0.count > 1 }
            
            // Если получили валидные критерии, возвращаем их
            if !validAttributes.isEmpty {
                return Array(validAttributes.prefix(5)) // Максимум 5 критериев
            }
        } catch _ {
            // Если парсинг не удался, пытаемся извлечь вручную
            if let attributes = extractAttributesManually(from: cleanedJSON) {
                return attributes
            }
        }
        
        // Fallback: return default criteria on correct language
        return getFallbackAttributes(language: language)
    }
    
    /// Возвращает дефолтные критерии на указанном языке
    private func getFallbackAttributes(language: String) -> [String] {
        switch language {
        case "ru":
            return ["Критерий 1", "Критерий 2", "Критерий 3"]
        case "es":
            return ["Criterio 1", "Criterio 2", "Criterio 3"]
        case "fr":
            return ["Critère 1", "Critère 2", "Critère 3"]
        default:
            return ["Criterion 1", "Criterion 2", "Criterion 3"]
        }
    }
    
    /// Извлекает критерии вручную из текста, если JSON парсинг не удался
    private func extractAttributesManually(from text: String) -> [String]? {
        // Ищем паттерн "attributes": ["критерий 1", "критерий 2", ...]
        let pattern = #""attributes"\s*:\s*\[(.*?)\]"#
        
        guard let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive) else {
            return nil
        }
        
        let nsString = text as NSString
        let matches = regex.matches(in: text, options: [], range: NSRange(location: 0, length: nsString.length))
        
        guard let match = matches.first, match.numberOfRanges > 1 else {
            return nil
        }
        
        let attributesRange = match.range(at: 1)
        let attributesString = nsString.substring(with: attributesRange)
        
        // Парсим значения из строки
        let attributes = attributesString
            .components(separatedBy: ",")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines)
                .replacingOccurrences(of: "\"", with: "")
                .replacingOccurrences(of: "'", with: "") }
            .filter { !$0.isEmpty && $0.count > 1 }
        
        return attributes.isEmpty ? nil : Array(attributes.prefix(5))
    }
    
    /// Проверяет, является ли атрибут числовым (калории, цена, вес и т.д.)
    private func isNumericalAttribute(_ attribute: String) -> Bool {
        let lowerAttr = attribute.lowercased()
        let numericalKeywords = [
            "calor", "калори", "price", "cost", "цена", "стоимость", 
            "weight", "вес", "mass", "масса", "amount", "количество",
            "quantity", "volume", "объем", "size", "размер",
            "percentage", "процент", "index", "индекс", "score", "балл",
            "rate", "ставка", "speed", "скорость", "distance", "расстояние"
        ]
        return numericalKeywords.contains { lowerAttr.contains($0) }
    }
    
    // MARK: - LLM API вызовы
    
    /// Вызывает LLM API (настроен Groq по умолчанию)
    private func callLLMAPI(prompt: String) async throws -> String {
        // Groq API настроен по умолчанию (быстрый и бесплатный)
        // Получите API ключ на https://console.groq.com/ и добавьте его в Info.plist как "GroqAPIKey"
        // или замените "YOUR_GROQ_API_KEY" в методе callGroqAPI() на ваш реальный ключ
        
        return try await callGroqAPI(prompt: prompt)
    }
    
    /// Вызов Groq API (бесплатный tier, очень быстрый)
    /// Получите API ключ на https://console.groq.com/
    private func callGroqAPI(prompt: String) async throws -> String {
        // Получаем API ключ из Info.plist или используем значение по умолчанию
        // Для настройки: добавьте ключ в Info.plist как "GroqAPIKey" или замените значение ниже
        let apiKey = Bundle.main.object(forInfoDictionaryKey: "GroqAPIKey") as? String ?? "YOUR_GROQ_API_KEY"
        
        // Проверяем, что ключ настроен
        guard apiKey != "YOUR_GROQ_API_KEY", !apiKey.isEmpty else {
            throw AIAssistantError.networkError
        }
        
        guard let url = URL(string: "https://api.groq.com/openai/v1/chat/completions") else {
            throw AIAssistantError.networkError
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Системные правила для модели
        let systemRules = """
        Ты — аналитический модуль приложения "ChooseRight!". 
        Твоя задача: сравнивать объекты по критериям, используя только "+" и "-".

        КРИТИЧЕСКИ ВАЖНО:
        - Ты ОБЯЗАН сравнивать объекты относительно друг друга
        - Для КАЖДОГО критерия хотя бы ОДИН объект ДОЛЖЕН получить "+"
        - НЕДОПУСТИМО ставить "-" для всех объектов по какому-либо критерию
        - Если объекты кажутся равными, выбери лучший и поставь ему "+"
        - ИСПОЛЬЗУЙ КОНКРЕТНЫЕ ЧИСЛОВЫЕ ДАННЫЕ из твоих знаний, а не общие впечатления

        ПРАВИЛА ОЦЕНКИ (ИСПОЛЬЗУЙ РЕАЛЬНЫЕ ДАННЫЕ):
        1. "+" — это преимущество, наличие полезного свойства или высокий показатель (для позитивных качеств).
        2. "-" — это недостаток, отсутствие или низкий показатель.
        3. Если критерий "Цена/Стоимость/Cost/Price": Используй РЕАЛЬНЫЕ ЦЕНЫ. "+" — это доступная цена (дешево), "-" — это дорого.
        4. Если критерий "Калории/Calories": Используй РЕАЛЬНОЕ СОДЕРЖАНИЕ КАЛОРИЙ. Сравни конкретные числа (ккал на 100г). "+" — это высокое содержание, "-" — низкое.
        5. Если критерий "Technology/Технологии": Используй РЕАЛЬНЫЕ ФАКТЫ о технологическом развитии. "+" — лучшие технологии, "-" — хуже.
        6. Если критерий "Education/Образование": Используй РЕАЛЬНЫЕ ДАННЫЕ об образовании (университеты, рейтинги). "+" — лучшие возможности, "-" — хуже.
        7. Для ВСЕХ критериев: Используй КОНКРЕТНЫЕ ЧИСЛА и ФАКТЫ из твоих знаний, сравнивай РЕАЛЬНЫЕ ЗНАЧЕНИЯ.
        8. Отвечай СТРОГО в формате JSON без вводных слов.
        """
        
        let body: [String: Any] = [
            "model": "llama-3.1-8b-instant", // Быстрая модель, можно заменить на "mixtral-8x7b-32768" для лучшего качества
            "messages": [
                ["role": "system", "content": systemRules], // Ключевой апгрейд здесь
                ["role": "user", "content": prompt]
            ],
            "temperature": 0.0, // Установлено в 0 для максимальной детерминированности
            "top_p": 1.0, // Используем все токены для максимальной детерминированности
            "max_tokens": 500,
            "response_format": ["type": "json_object"] // Обязательно для стабильного парсинга
        ]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        // Проверяем статус ответа
        if let httpResponse = response as? HTTPURLResponse {
            if httpResponse.statusCode == 401 {
                throw AIAssistantError.networkError // Неверный API ключ
            }
            if httpResponse.statusCode != 200 {
                throw AIAssistantError.networkError
            }
        }
        
        // Парсим ответ Groq (OpenAI-совместимый формат)
        if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
            // Проверяем наличие ошибки
            if json["error"] is [String: Any] {
                throw AIAssistantError.networkError
            }
            
            if let choices = json["choices"] as? [[String: Any]],
               let firstChoice = choices.first,
               let message = firstChoice["message"] as? [String: Any],
               let content = message["content"] as? String {
                return content
            }
        }
        
        throw AIAssistantError.invalidResponse
    }
    
}

enum AIAssistantError: LocalizedError {
    case parsingFailed
    case networkError
    case invalidResponse
    
    var errorDescription: String? {
        switch self {
        case .parsingFailed:
            return "Failed to recognize items and criteria in your request"
        case .networkError:
            return "Network error when accessing the AI service"
        case .invalidResponse:
            return "Invalid response format from the AI service"
        }
    }
}
