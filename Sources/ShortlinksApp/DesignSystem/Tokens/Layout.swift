import CoreGraphics

/// Шкала отступов под фактический ритм макета (`_design/`). Значения именованы по
/// величине — это даёт единый, *ограниченный* набор разрешённых отступов: во вью
/// допустимы только `Spacing.sN`, а не произвольные числа. Доминирующие значения
/// (14/16/18/22/24/26) сохранены точно ради визуального паритета; мелкий хвост исходных
/// величин снапнут к ближайшему шагу (3→s4, 5→s6, 7→s8, 9→s8, 11/13→s12, 28→s26).
enum Spacing {
    static let s2: CGFloat = 2
    static let s4: CGFloat = 4
    static let s6: CGFloat = 6
    static let s8: CGFloat = 8
    static let s10: CGFloat = 10
    static let s12: CGFloat = 12
    static let s14: CGFloat = 14
    static let s16: CGFloat = 16
    static let s18: CGFloat = 18
    static let s20: CGFloat = 20
    static let s22: CGFloat = 22
    static let s24: CGFloat = 24
    static let s26: CGFloat = 26
    static let s32: CGFloat = 32
}

/// Шкала радиусов скругления. Сводит прежние 8 различных значений к единой шкале
/// (5,6→sm · 7,8,9→md · 10→lg · 12→xl · 16→xxl).
enum Radius {
    static let sm: CGFloat = 6     // чипы, мелкие иконочные плитки
    static let md: CGFloat = 8     // элементы управления, поля, кнопки
    static let lg: CGFloat = 10    // строки списка, code-боксы
    static let xl: CGFloat = 12    // карточки
    static let xxl: CGFloat = 16   // оверлеи, крупная иконка пустого состояния
}

/// Именованные фиксированные размеры — чтобы во вью не оставалось «магических» ширин и
/// высот. Размеры, привязанные к конкретному компоненту (высота поля, ширина колонки
/// меток, max-ширина экрана), впитываются в соответствующие molecules.
enum Size {
    // Главное окно
    static let windowWidth: CGFloat = 980
    static let windowHeight: CGFloat = 680
    static let windowMinWidth: CGFloat = 880
    static let windowMinHeight: CGFloat = 600

    // Окна и панели
    static let sidebarWidth: CGFloat = 240
    static let sheetWidth: CGFloat = 540
    static let sheetMaxHeight: CGFloat = 660
    static let overlayWidth: CGFloat = 430

    // Максимальные ширины контента экранов
    static let detailMaxWidth: CGFloat = 680
    static let settingsMaxWidth: CGFloat = 640
    static let howMaxWidth: CGFloat = 760
    static let proseMaxWidth: CGFloat = 560      // вводный абзац «Как это работает»
    static let toolbarTitleMaxWidth: CGFloat = 360
    static let dialogTextMaxWidth: CGFloat = 300
    static let emptyTextMaxWidth: CGFloat = 280

    // Полосы и элементы управления
    static let toolbarHeight: CGFloat = 52
    static let bulkBarHeight: CGFloat = 48
    static let searchWidth: CGFloat = 200
    static let pickerWidth: CGFloat = 220
    static let pickerWideWidth: CGFloat = 280
    static let controlHeight: CGFloat = 30       // мелкие кнопки/поля тулбара
    static let actionHeight: CGFloat = 36        // главная кнопка действия на экране
    static let fieldHeight: CGFloat = 34
    static let chipButtonHeight: CGFloat = 26

    // Колонки и метки
    static let infoLabelWidth: CGFloat = 150

    // Иконки, плитки, индикаторы
    static let emptyIcon: CGFloat = 64
    static let detailIcon: CGFloat = 52
    static let tileLg: CGFloat = 30
    static let stepBadge: CGFloat = 26
    static let tileSm: CGFloat = 20
    static let accentSquare: CGFloat = 18
    static let syncDot: CGFloat = 6

    // Прочее
    static let emptyStateVInset: CGFloat = 90
}
