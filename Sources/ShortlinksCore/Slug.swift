import Foundation

/// Генерация и нормализация slug (перенос логики из макета).
public enum Slug {
    /// Алфавит без визуально похожих символов (нет l, o, 0, 1).
    static let alphabet = Array("abcdefghijkmnpqrstuvwxyz23456789")

    public static func generate(length: Int = 6) -> String {
        String((0..<length).map { _ in alphabet.randomElement()! })
    }

    /// Нижний регистр; недопустимые символы → `-`; схлопывание `//`; без ведущего `/`.
    public static func clean(_ value: String) -> String {
        var s = value.lowercased()
        s = s.replacingOccurrences(of: "[^a-z0-9\\-/]", with: "-", options: .regularExpression)
        s = s.replacingOccurrences(of: "/{2,}", with: "/", options: .regularExpression)
        s = s.replacingOccurrences(of: "^/+", with: "", options: .regularExpression)
        return s
    }

    /// Нормализация для сохранения: без хвостовых `/`, пустой → сгенерированный.
    public static func normalizeForSave(_ value: String) -> String {
        var s = clean(value.trimmingCharacters(in: .whitespacesAndNewlines))
        s = s.replacingOccurrences(of: "/+$", with: "", options: .regularExpression)
        return s.isEmpty ? generate() : s
    }
}
