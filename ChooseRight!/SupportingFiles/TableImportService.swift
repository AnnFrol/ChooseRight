import UIKit

class TableImportService {
    
    static func parseTableFromClipboard(_ text: String? = nil) -> ImportedTableData? {
        let inputText = text ?? UIPasteboard.general.string ?? ""
        guard !inputText.isEmpty else { return nil }
        
        // 1. Попытка распарсить переданный текст
        if let data = parseTableFromText(inputText) {
            return data
        }
        
        // 2. Fallback: Если текст пришел из TextField (где нет переносов строк),
        // проверяем буфер обмена на наличие оригинальной форматированной таблицы
        if let providedText = text, let clipboardText = UIPasteboard.general.string {
            // Нормализуем обе строки для сравнения (убираем пробелы и переносы)
            let normalizedInput = providedText.components(separatedBy: .whitespacesAndNewlines).joined()
            let normalizedClipboard = clipboardText.components(separatedBy: .whitespacesAndNewlines).joined()
            
            // Если содержимое совпадает (но в буфере есть переносы, а в input нет), пробуем парсить буфер
            if normalizedInput == normalizedClipboard || normalizedClipboard.contains(normalizedInput) {
                if let dataFromClipboard = parseTableFromText(clipboardText) {
                    return dataFromClipboard
                }
            }
        }
        
        return nil
    }
    
    private static func capitalizeFirstLetter(_ string: String) -> String {
        guard let first = string.first else { return string }
        return String(first).uppercased() + string.dropFirst()
    }

    private static func parseTableFromText(_ text: String) -> ImportedTableData? {
        // 1. Очистка и нормализация
        // Используем .newlines для разбиения, чтобы поддерживать все виды переносов строк (\n, \r, \r\n, u2028 и т.д.)
        let lines = text.components(separatedBy: .newlines)
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }
        
        guard lines.count >= 2 else { return nil }
        
        // 2. Детекция формата
        // Если строка состоит ТОЛЬКО из символа значения — это вертикальный формат
        if isVerticalFormat(lines) {
            return parseVerticalTableFormat(lines)
        }
        
        // 3. Табличный формат (CSV/TSV)
        let delimiter = detectDelimiter(in: lines[0])
        let headerColumns = parseLine(lines[0], delimiter: delimiter)
        
        // "City" или "Фрукты" — это заголовок категории
        let categoryLabel = headerColumns.first.map { capitalizeFirstLetter($0) }
        // Все остальное в первой строке — атрибуты
        let attributes = headerColumns.count > 1 ? Array(headerColumns[1...]).map { capitalizeFirstLetter($0) } : []
        
        var items: [String] = []
        var values: [[String]] = []
        
        for i in 1..<lines.count {
            let columns = parseLine(lines[i], delimiter: delimiter)
            guard !columns.isEmpty else { continue }
            
            // Первая колонка — название (New York, London, 🍎 Яблоки)
            items.append(capitalizeFirstLetter(columns[0]))
            
            // Остальные — значения
            let rowValues = columns.count > 1 ? Array(columns[1...]) : []
            
            // Жесткая синхронизация количества значений с количеством атрибутов
            var alignedValues = Array(repeating: "", count: attributes.count)
            for (idx, val) in rowValues.enumerated() where idx < attributes.count {
                alignedValues[idx] = val
            }
            values.append(alignedValues)
        }
        
        return ImportedTableData(items: items, attributes: attributes, values: values, firstHeader: categoryLabel)
    }

    private static func isVerticalFormat(_ lines: [String]) -> Bool {
        // Проверяем, есть ли среди первых 10 строк одиночные символы значений
        for i in 0..<min(lines.count, 10) {
            let t = lines[i].trimmingCharacters(in: .whitespaces)
            if t == "+" || t == "-" || t == "−" || t == "—" || t == "–" || t == "○" || t == "◯" || t.lowercased() == "o" {
                return true
            }
        }
        return false
    }

    private static func parseVerticalTableFormat(_ lines: [String]) -> ImportedTableData? {
        // Ищем первое появление значения (+/-/neutral)
        guard let firstValIdx = lines.firstIndex(where: { 
            let t = $0.trimmingCharacters(in: .whitespaces)
            return t == "+" || t == "-" || t == "−" || t == "—" || t == "–" || t == "○" || t == "◯" || t.lowercased() == "o"
        }) else { return nil }
        
        // Элемент (напр. Яблоки) — это строка ПЕРЕД первым значением
        let firstItemIdx = firstValIdx - 1
        guard firstItemIdx >= 1 else { return nil }
        
        let categoryLabel = capitalizeFirstLetter(lines[0])
        let attributes = Array(lines[1..<firstItemIdx]).map { capitalizeFirstLetter($0) }
        let attrCount = attributes.count
        
        var items: [String] = []
        var values: [[String]] = []
        
        var current = firstItemIdx
        while current < lines.count {
            items.append(capitalizeFirstLetter(lines[current]))
            var itemValues: [String] = []
            for i in 1...attrCount {
                let v = (current + i < lines.count) ? lines[current + i] : ""
                itemValues.append(v)
            }
            values.append(itemValues)
            current += (attrCount + 1)
        }
        
        return ImportedTableData(items: items, attributes: attributes, values: values, firstHeader: categoryLabel)
    }

    private static func detectDelimiter(in line: String) -> String {
        let delimiters = ["\t", ";", ",", "|"]
        var maxCount = 0
        var bestDelimiter = "\t" // Default
        
        for delimiter in delimiters {
            let count = line.components(separatedBy: delimiter).count - 1
            if count > maxCount {
                maxCount = count
                bestDelimiter = delimiter
            }
        }
        
        // If no delimiters found by count, but commas are present, assume comma as default for CSV
        if maxCount == 0 && line.contains(",") {
            return ","
        }
        
        return bestDelimiter
    }

    private static func parseLine(_ line: String, delimiter: String) -> [String] {
        var result: [String] = []
        var current = ""
        var inParentheses = 0
        
        // Посимвольный разбор, чтобы не разбивать текст внутри скобок (на всякий случай)
        for char in line {
            if char == "(" { inParentheses += 1 }
            else if char == ")" { inParentheses -= 1 }
            
            if String(char) == delimiter && inParentheses == 0 {
                result.append(current.trimmingCharacters(in: .whitespaces))
                current = ""
            } else {
                current.append(char)
            }
        }
        result.append(current.trimmingCharacters(in: .whitespaces))
        return result
    }

    static func parseComparisonValueState(_ value: String) -> ComparisonValueState {
        let normalized = value.trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: "\u{200B}", with: "") // Zero-width space
            .replacingOccurrences(of: "\u{FEFF}", with: "") // Zero-width no-break space
            .replacingOccurrences(of: "\u{00A0}", with: "") // Non-breaking space
            .trimmingCharacters(in: .whitespacesAndNewlines)
        
        if normalized.isEmpty { return .minus }

        let neutralValues = ["○", "◯", "◌", "o", "circle"]
        if neutralValues.contains(normalized.lowercased()) {
            return .neutral
        }

        // Check for plus first
        if normalized == "+" || normalized.hasPrefix("+") || normalized.lowercased() == "да" {
            return .plus
        }
        
        // List of all possible "minus" and negation variants
        let negativeValues = ["-", "−", "—", "–", "нет", "no", "0", "false", "✗"]
        
        // If it's any of the minuses - it's false
        if negativeValues.contains(normalized) || negativeValues.contains(where: { normalized.hasPrefix($0) }) {
            return .minus
        }
        
        let positive = ["+", "да", "yes", "true", "1", "✓", "✔"]
        if positive.contains(where: { normalized.lowercased().contains($0) }) { return .plus }
        
        return .minus
    }
    
    static func parseBooleanValue(_ value: String) -> Bool {
        parseComparisonValueState(value) == .plus
    }
}
