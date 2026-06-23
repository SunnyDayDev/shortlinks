import SwiftUI
import ShortlinksCore

struct SidebarView: View {
    @Environment(AppModel.self) private var model

    private var isLib: Bool { model.screen == .library }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: Spacing.s2) {
                    sectionLabel(Strings.Sidebar.sectionLibrary)
                    item(Strings.Sidebar.all, systemImage: Icons.Filter.all, tint: Theme.accent,
                         count: model.counts.all, active: isLib && model.filter == .all) { model.setFilter(.all) }
                    item(Strings.Sidebar.active, systemImage: Icons.Filter.active, tint: Theme.activeAccent,
                         count: model.counts.active, active: isLib && model.filter == .active) { model.setFilter(.active) }
                    item(Strings.Sidebar.once, systemImage: Icons.Filter.once, tint: Theme.onceAccent,
                         count: model.counts.once, active: isLib && model.filter == .once) { model.setFilter(.once) }
                    item(Strings.Sidebar.expired, systemImage: Icons.Filter.expired, tint: Theme.neutralIcon,
                         count: model.counts.expired, active: isLib && model.filter == .expired) { model.setFilter(.expired) }

                    if !model.tagCounts.isEmpty {
                        sectionLabel(Strings.Sidebar.sectionTags).padding(.top, Spacing.s8)
                        ForEach(model.tagCounts, id: \.name) { tag in
                            item("#\(tag.name)", systemImage: Icons.Filter.tag, tint: Theme.tagIcon,
                                 count: tag.count, active: isLib && model.filter == .tag(tag.name)) {
                                model.setFilter(.tag(tag.name))
                            }
                        }
                    }

                    Divider().padding(.horizontal, Spacing.s18).padding(.vertical, Spacing.s8)

                    item(Strings.Sidebar.settings, systemImage: Icons.Filter.settings, tint: Theme.settingsIcon,
                         count: nil, active: model.screen == .settings) { model.goScreen(.settings) }
                    item(Strings.Sidebar.how, systemImage: Icons.Filter.help, tint: Theme.helpIcon,
                         count: nil, active: model.screen == .how) { model.goScreen(.how) }
                }
                .padding(.vertical, Spacing.s6)
            }

            footer
        }
        .frame(width: Size.sidebarWidth)
        .background(Theme.sidebarBg)
    }

    private func sectionLabel(_ text: String) -> some View {
        SectionLabel(text)
            .padding(.horizontal, Spacing.s20).padding(.top, Spacing.s8).padding(.bottom, Spacing.s6)
    }

    private func item(_ title: String, systemImage: String, tint: Color, count: Int?, active: Bool, action: @escaping () -> Void) -> some View {
        SidebarItem(title: title, systemImage: systemImage, tint: tint, count: count, active: active, action: action)
    }

    private var footer: some View {
        HStack(spacing: Spacing.s8) {
            Circle().fill(model.syncEnabled ? Theme.accent : Theme.activeAccent)
                .frame(width: Size.syncDot, height: Size.syncDot)
            Text(model.syncEnabled ? Strings.Sidebar.syncOn : Strings.Sidebar.syncOff)
                .font(Typography.caption2)
                .foregroundStyle(Theme.textSecondary)
                .lineLimit(2)
        }
        .padding(.horizontal, Spacing.s18).padding(.vertical, Spacing.s10)
        .frame(maxWidth: .infinity, alignment: .leading)
        .overlay(Divider(), alignment: .top)
    }
}
