import Foundation

/// Слияние конфликтных версий `links.json` по `id` ссылки.
public enum ConflictMerge {
    /// Объединяет несколько версий списка. Записи, отсутствующие в части версий,
    /// сохраняются; совпадающие по `id` разрешаются `resolve`.
    public static func merge(_ versions: [[Link]]) -> [Link] {
        var byId: [String: Link] = [:]
        for list in versions {
            for link in list {
                if let existing = byId[link.id] {
                    byId[link.id] = resolve(existing, link)
                } else {
                    byId[link.id] = link
                }
            }
        }
        // Стабильный порядок: по дате создания (новые сверху — как в UI).
        return byId.values.sorted { $0.createdAt > $1.createdAt }
    }

    /// Правило: потреблённая (`viewed`) важнее активной; при обоих потреблённых
    /// выигрывает более ранний `consumedAt`; при обеих активных — больше переходов.
    static func resolve(_ a: Link, _ b: Link) -> Link {
        switch (a.consumedAt, b.consumedAt) {
        case let (x?, y?):
            return x <= y ? a : b
        case (_?, nil):
            return a
        case (nil, _?):
            return b
        case (nil, nil):
            return a.opens >= b.opens ? a : b
        }
    }
}
