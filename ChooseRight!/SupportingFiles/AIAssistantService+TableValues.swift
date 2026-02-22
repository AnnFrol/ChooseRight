//
//  AIAssistantService+TableValues.swift
//  ChooseRight!
//
//  Генерация значений (+/‑) для готовой таблицы сравнения.
//  Отдельный файл от основного AIAssistantService (создание сравнения из запроса).
//

import Foundation

extension AIAssistantService {

    /// Генерирует значения (+/‑) для готовой таблицы сравнения по объектам и атрибутам.
    /// - Parameters:
    ///   - items: Названия объектов (строками по порядку).
    ///   - attributes: Названия критериев (строками по порядку).
    /// - Returns: Матрица values[индексОбъекта][индексАтрибута] = true (+) / false (‑).
    func generateValuesForTable(items: [String], attributes: [String]) async throws -> [[Bool]] {
        guard items.count >= 2, attributes.count >= 1 else {
            throw AIAssistantError.parsingFailed
        }
        let language = detectLanguage([items, attributes].flatMap { $0 }.joined(separator: " "))
        let languageName = language == "ru" ? "RUSSIAN" : (language == "es" ? "SPANISH" : (language == "fr" ? "FRENCH" : "ENGLISH"))
        let itemsList = items.enumerated().map { "\($0.offset + 1). \($0.element)" }.joined(separator: "\n")
        let attrsList = attributes.enumerated().map { "\($0.offset + 1). \($0.element)" }.joined(separator: "\n")

        let prompt = """
        You are an analytical module for the "ChooseRight!" app. Your task is to compare objects by criteria using only "+" (true) or "-" (false).

        OBJECTS (items), in this exact order:
        \(itemsList)

        CRITERIA (attributes), in this exact order:
        \(attrsList)

        RULES:
        1. For EACH criterion, at least ONE object MUST get "+" (true).
        2. Compare objectively. Use "+" when the object clearly meets or excels on the criterion, "-" otherwise.
        3. Return ONLY valid JSON. No markdown, no explanation.
        4. All names are in \(languageName). Keep the same language in your reasoning (output is only JSON).

        OUTPUT FORMAT (strict):
        {"values": [[bool, bool, ...], [bool, bool, ...], ...]}
        - First dimension: one array per OBJECT, in the same order as the objects list above (first array = first object).
        - Second dimension: one boolean per CRITERION, in the same order as the criteria list (first bool = first criterion).
        - true = "+", false = "-".

        Example for 2 objects and 2 criteria: {"values": [[true, false], [false, true]]}
        """

        let maxTokens = 500 + (items.count * attributes.count * 2)
        let jsonResponse = try await callGroqAPI(prompt: prompt, maxTokens: max(min(maxTokens, 4096), 500))

        guard let data = jsonResponse.data(using: .utf8),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let valuesArray = json["values"] as? [[Any]] else {
            throw AIAssistantError.parsingFailed
        }

        var result: [[Bool]] = []
        for row in valuesArray {
            var rowBools: [Bool] = []
            for cell in row {
                if let b = cell as? Bool {
                    rowBools.append(b)
                } else if let n = cell as? Int {
                    rowBools.append(n != 0)
                } else {
                    rowBools.append(false)
                }
            }
            result.append(rowBools)
        }

        let expectedRows = items.count
        let expectedCols = attributes.count
        if result.count != expectedRows {
            throw AIAssistantError.parsingFailed
        }
        for (_, row) in result.enumerated() {
            if row.count != expectedCols {
                throw AIAssistantError.parsingFailed
            }
        }
        return result
    }
}
