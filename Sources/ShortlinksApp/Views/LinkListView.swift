import SwiftUI
import ShortlinksCore

struct LinkListView: View {
    @Environment(AppModel.self) private var model

    var body: some View {
        let links = model.filteredLinks
        if links.isEmpty {
            EmptyState()
        } else {
            VStack(spacing: Spacing.s8) {
                ForEach(links) { link in
                    row(link)
                }
            }
            .padding(.horizontal, Spacing.s16)
            .padding(.top, Spacing.s14).padding(.bottom, Spacing.s24)
        }
    }

    @ViewBuilder
    private func row(_ link: Link) -> some View {
        let editing = model.editing
        LinkRow(link: link, editing: editing, selected: model.selection.contains(link.id))
            .contentShape(Rectangle())
            .onTapGesture {
                if editing { model.toggleSelect(link.id) } else { model.openDetail(link.id) }
            }
            .contextMenu { if !editing { contextMenu(link) } }
            .transition(.move(edge: .trailing).combined(with: .opacity))
    }

    @ViewBuilder
    private func contextMenu(_ link: Link) -> some View {
        let status = link.status()
        if status == .active {
            Button(Strings.List.open) { model.openLink(link) }
        }
        Button(Strings.List.copyAddress) { model.copy(link.fullURL) }
        // Активировать сгоревшую (viewed) ссылку нечего — пункт только для остальных.
        if status != .viewed {
            if status == .disabled {
                Button(Strings.List.activate) { model.activate(id: link.id) }
            } else {
                Button(Strings.List.deactivate) { model.deactivate(id: link.id) }
            }
        }
        Divider()
        Button(Strings.Common.delete, role: .destructive) { model.delete(id: link.id) }
    }
}

struct LinkRow: View {
    let link: Link
    var editing = false
    var selected = false

    var body: some View {
        HStack(spacing: Spacing.s12) {
            if editing {
                Image(systemName: selected ? Icons.Select.on : Icons.Select.off)
                    .font(Typography.glyphMedium)
                    .foregroundStyle(selected ? Theme.accent : Theme.textSecondary)
                    .transition(.move(edge: .leading).combined(with: .opacity))
            }
            TargetIcon(target: link.target, masked: link.isProtected)
            VStack(alignment: .leading, spacing: Spacing.s4) {
                HStack(spacing: 0) {
                    Text("sl://link/").foregroundStyle(Theme.textSecondary)
                    Text(link.slug).foregroundStyle(Theme.textPrimary)
                }
                .font(Typography.mono)
                .lineLimit(1)

                if let note = link.note, !note.isEmpty {
                    Text(note)
                        .font(Typography.caption)
                        .foregroundStyle(Theme.textPrimary)
                        .lineLimit(1)
                } else {
                    Text(link.isProtected ? Strings.Common.targetMask : link.target)
                        .font(Typography.caption)
                        .foregroundStyle(Theme.textSecondary)
                        .lineLimit(1)
                }

                Text(Format.subtitle(link))
                    .font(Typography.caption2)
                    .foregroundStyle(Theme.textSecondary)

                if !link.tags.isEmpty {
                    FlowLayout(spacing: Spacing.s6) {
                        ForEach(link.tags, id: \.self) { TagChip(name: $0) }
                    }
                    .padding(.top, Spacing.s4)
                }
            }
            Spacer(minLength: Spacing.s6)
            StatusPill(status: link.status())
            if !editing {
                Image(systemName: Icons.Nav.forward)
                    .font(Typography.glyphSmall)
                    .foregroundStyle(Theme.textSecondary)
                    .transition(.move(edge: .trailing).combined(with: .opacity))
            }
        }
        .padding(.horizontal, Spacing.s14).padding(.vertical, Spacing.s12)
        .card(radius: Radius.lg)
    }
}

struct EmptyState: View {
    @Environment(AppModel.self) private var model

    var body: some View {
        VStack(spacing: 0) {
            Text("sl://")
                .font(Typography.monoHeadline)
                .foregroundStyle(Theme.placeholderGlyph)
                .frame(width: Size.emptyIcon, height: Size.emptyIcon)
                .background(Theme.iconBg, in: RoundedRectangle(cornerRadius: Radius.xxl))
                .padding(.bottom, Spacing.s16)
            Text(Strings.List.emptyTitle).font(Typography.title)
            Text(Strings.List.emptySubtitle)
                .font(Typography.body)
                .foregroundStyle(Theme.textSecondary)
                .multilineTextAlignment(.center)
                .frame(maxWidth: Size.emptyTextMaxWidth)
                .padding(.top, Spacing.s6)
            Button(action: { model.openCreate() }) {
                HStack(spacing: Spacing.s6) { Image(systemName: Icons.Action.add); Text(Strings.Common.newLink) }
            }
            .buttonStyle(PrimaryButtonStyle(size: .medium))
            .padding(.top, Spacing.s18)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, Size.emptyStateVInset)
    }
}
