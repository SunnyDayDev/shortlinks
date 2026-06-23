import SwiftUI
import ShortlinksCore

struct LinkDetailView: View {
    @Environment(AppModel.self) private var model

    var body: some View {
        if let link = model.selectedLink {
            detail(link)
        }
    }

    private func detail(_ link: Link) -> some View {
        let status = link.status()
        return VStack(alignment: .leading, spacing: 0) {
            Button(action: { model.back() }) {
                HStack(spacing: Spacing.s6) {
                    Image(systemName: Icons.Nav.back)
                    Text(Strings.Detail.back)
                }
                .font(Typography.bodyMedium)
                .foregroundStyle(Theme.accent)
            }
            .buttonStyle(.plain)
            .padding(.bottom, Spacing.s18)

            HStack(spacing: Spacing.s14) {
                TargetIcon(target: link.target, size: Size.detailIcon)
                VStack(alignment: .leading, spacing: Spacing.s8) {
                    Text(link.fullURL)
                        .font(Typography.monoTitle)
                    StatusPill(status: status)
                }
                Spacer()
                Button(Strings.Common.copy) { model.copy(link.fullURL) }
                    .buttonStyle(.bordered)
            }
            .padding(.bottom, Spacing.s22)

            infoCard(link, status: status)

            HStack(spacing: Spacing.s10) {
                if status == .active {
                    Button(action: { model.openLink(link) }) {
                        HStack(spacing: Spacing.s6) {
                            Image(systemName: Icons.Action.redirect)
                            Text(Scheme.detect(link.target).openLabel)
                        }
                    }
                    .buttonStyle(PrimaryButtonStyle(size: .large))
                } else {
                    Text(Strings.Common.linkUnavailable)
                        .font(Typography.bodyEmphasis)
                        .foregroundStyle(Theme.textSecondary)
                        .padding(.horizontal, Spacing.s18).frame(height: Size.actionHeight)
                        .background(Theme.subtleFill, in: RoundedRectangle(cornerRadius: Radius.md))
                }
                Spacer()
                Button(role: .destructive, action: { model.delete(id: link.id) }) {
                    Text(Strings.Common.delete)
                }
                .buttonStyle(DestructiveButtonStyle(size: .large))
            }
            .padding(.top, Spacing.s20)
        }
        .screenContainer(maxWidth: Size.detailMaxWidth, bottom: Spacing.s26)
    }

    private func infoCard(_ link: Link, status: LinkStatus) -> some View {
        VStack(spacing: 0) {
            InfoRow(label: Strings.Detail.redirectsTo, value: link.target, mono: true)
            Divider()
            InfoRow(label: Strings.Detail.type, value: Format.kindLabel(link.kind))
            Divider()
            InfoRow(label: Strings.Detail.opens, value: Format.opensText(link.opens))
            Divider()
            InfoRow(label: Strings.Common.lifetimeTitle, value: expiryText(link, status: status))
            Divider()
            InfoRow(label: Strings.Detail.password, value: link.isProtected ? Strings.Detail.passwordOn : Strings.Detail.passwordOff)
            if !link.tags.isEmpty {
                Divider()
                HStack(alignment: .top) {
                    Text(Strings.Detail.tags)
                        .frame(width: Size.infoLabelWidth, alignment: .leading)
                        .foregroundStyle(Theme.textSecondary)
                    FlowLayout(spacing: Spacing.s6) {
                        ForEach(link.tags, id: \.self) { TagChip(name: $0) }
                    }
                }
                .padding(.horizontal, Spacing.s16).padding(.vertical, Spacing.s12)
            }
            Divider()
            InfoRow(label: Strings.Detail.created, value: created(link))
        }
        .font(Typography.body)
        .card()
    }

    private func expiryText(_ link: Link, status: LinkStatus) -> String {
        switch status {
        case .active, .disabled: return Format.expiresText(link)
        case .viewed: return Strings.Status.viewed
        case .expired: return Strings.Expiry.expired
        }
    }

    private func created(_ link: Link) -> String {
        Format.dateTime(link.createdAt)
    }
}
