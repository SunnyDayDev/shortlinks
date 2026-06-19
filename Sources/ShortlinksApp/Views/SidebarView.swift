import SwiftUI
import ShortlinksCore

struct SidebarView: View {
    @Environment(AppModel.self) private var model

    private var isLib: Bool { model.screen == .library }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: 1) {
                    sectionLabel("БИБЛИОТЕКА")
                    row("Все ссылки", systemImage: "circle.dashed", tint: Theme.accent,
                        count: model.counts.all, active: isLib && model.filter == .all) { model.setFilter(.all) }
                    row("Активные", systemImage: "circle.fill", tint: Theme.activeAccent,
                        count: model.counts.active, active: isLib && model.filter == .active) { model.setFilter(.active) }
                    row("Одноразовые", systemImage: "flame.fill", tint: Theme.onceAccent,
                        count: model.counts.once, active: isLib && model.filter == .once) { model.setFilter(.once) }
                    row("Истёкшие", systemImage: "clock.badge.xmark", tint: Color(hex: 0x9AA0AA),
                        count: model.counts.expired, active: isLib && model.filter == .expired) { model.setFilter(.expired) }

                    if !model.tagCounts.isEmpty {
                        sectionLabel("ТЕГИ").padding(.top, 8)
                        ForEach(model.tagCounts, id: \.name) { tag in
                            row("#\(tag.name)", systemImage: "number", tint: Color(hex: 0xC3C7D0),
                                count: tag.count, active: isLib && model.filter == .tag(tag.name)) {
                                model.setFilter(.tag(tag.name))
                            }
                        }
                    }

                    Divider().padding(.horizontal, 18).padding(.vertical, 8)

                    row("Настройки", systemImage: "gearshape.fill", tint: Color(hex: 0x8E8E93),
                        count: nil, active: model.screen == .settings) { model.goScreen(.settings) }
                    row("Как это работает", systemImage: "questionmark", tint: Color(hex: 0x5B6F95),
                        count: nil, active: model.screen == .how) { model.goScreen(.how) }
                }
                .padding(.vertical, 6)
            }

            footer
        }
        .frame(width: 240)
        .background(Theme.sidebarBg)
    }

    private func sectionLabel(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 11, weight: .bold))
            .foregroundStyle(Color.secondary)
            .padding(.horizontal, 20).padding(.top, 8).padding(.bottom, 6)
    }

    private func row(_ title: String, systemImage: String, tint: Color, count: Int?, active: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 9) {
                Image(systemName: systemImage)
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(.white)
                    .frame(width: 20, height: 20)
                    .background(tint, in: RoundedRectangle(cornerRadius: 5))
                Text(title)
                    .font(.system(size: 13, weight: .medium))
                    .lineLimit(1)
                Spacer(minLength: 4)
                if let count {
                    Text("\(count)")
                        .font(.system(size: 12))
                        .foregroundStyle(Theme.secondaryText)
                }
            }
            .padding(.horizontal, 10).padding(.vertical, 6)
            .background(active ? Color(hex: 0x2A6FDB, alpha: 0.14) : .clear, in: RoundedRectangle(cornerRadius: 7))
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .padding(.horizontal, 10)
    }

    private var footer: some View {
        HStack(spacing: 7) {
            Circle().fill(model.syncEnabled ? Theme.accent : Theme.activeAccent).frame(width: 6, height: 6)
            Text(model.syncEnabled ? "Синхронизируется через iCloud Drive" : "Хранится локально на этом Mac")
                .font(.system(size: 11))
                .foregroundStyle(Color.secondary)
                .lineLimit(2)
        }
        .padding(.horizontal, 18).padding(.vertical, 10)
        .frame(maxWidth: .infinity, alignment: .leading)
        .overlay(Divider(), alignment: .top)
    }
}
