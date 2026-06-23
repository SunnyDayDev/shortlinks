import Foundation

/// Реестр имён SF Symbols — единственное место, где заданы строковые имена символов.
/// Вью обращаются к семантическим константам (`Icons.Action.add`) вместо сырых строк,
/// по аналогии с токенами `Typography`/`Spacing`/`Theme`. Смена иконки для роли —
/// правка только этого файла. См. [[ui-systematize-beyond-tokens]].
enum Icons {
    /// Навигация.
    enum Nav {
        static let back = "chevron.left"
        static let forward = "chevron.right"
    }

    /// Действия / кнопки.
    enum Action {
        static let add = "plus"
        static let search = "magnifyingglass"
        static let edit = "square.and.pencil"
        static let delete = "trash"
        static let random = "arrow.clockwise"
        static let copyPath = "doc.on.doc"
        static let redirect = "arrow.right"
        static let removeTag = "xmark"
    }

    /// Множественный выбор в списке.
    enum Select {
        static let on = "checkmark.circle.fill"
        static let off = "circle"
    }

    /// Пункты сайдбара (фильтры и навигация).
    enum Filter {
        static let all = "circle.dashed"
        static let active = "circle.fill"
        static let once = "flame.fill"
        static let expired = "clock.badge.xmark"
        static let tag = "number"
        static let settings = "gearshape.fill"
        static let help = "questionmark"
    }

    /// Статусы / обратная связь в оверлее и настройках.
    enum Status {
        static let success = "checkmark.circle.fill"
        static let warningOnce = "exclamationmark.circle.fill"
        static let error = "xmark.circle.fill"
        static let privacy = "lock.fill"
    }

    /// Иконка приложения в меню-баре.
    static let menuBar = "link"
}
