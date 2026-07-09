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
                TargetIcon(target: link.target, size: Size.detailIcon, masked: link.isProtected)
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
            if let note = link.note, !note.isEmpty {
                InfoRow(label: Strings.Detail.note, value: note)
                Divider()
            }
            if link.isProtected {
                ProtectedTargetRow(label: Strings.Detail.redirectsTo,
                                   target: link.target,
                                   passwordHash: link.passwordHash ?? "")
                    .id(link.id)
            } else {
                InfoRow(label: Strings.Detail.redirectsTo, value: link.target, mono: true)
            }
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

/// Строка деталей для цели защищённой ссылки: по умолчанию маска и «Показать»,
/// раскрытие — после ввода верного пароля (`Password.verify`), с обратным «Скрыть».
/// Состояние эфемерно и сбрасывается при смене ссылки — за счёт `.id(link.id)` на
/// стороне `LinkDetailView`. Цель не выделяема и не копируется, пока скрыта.
private struct ProtectedTargetRow: View {
    let label: String
    let target: String
    let passwordHash: String

    private enum Phase { case masked, prompting, revealed }
    @State private var phase: Phase = .masked
    @State private var passwordInput = ""
    @State private var showError = false

    var body: some View {
        HStack(alignment: .top) {
            Text(label)
                .frame(width: Size.infoLabelWidth, alignment: .leading)
                .foregroundStyle(Theme.textSecondary)
            value
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.horizontal, Spacing.s16).padding(.vertical, Spacing.s12)
    }

    @ViewBuilder
    private var value: some View {
        switch phase {
        case .masked:
            HStack(spacing: Spacing.s10) {
                Text(Strings.Common.targetMask).font(Typography.monoSmall)
                Spacer(minLength: Spacing.s10)
                toggle(icon: Icons.Reveal.show, title: Strings.Detail.reveal) {
                    showError = false
                    passwordInput = ""
                    phase = .prompting
                }
            }
        case .prompting:
            VStack(alignment: .leading, spacing: Spacing.s8) {
                HStack(spacing: Spacing.s8) {
                    SecureField(Strings.Common.password, text: $passwordInput)
                        .textFieldStyle(.roundedBorder)
                        .onSubmit(attemptReveal)
                    Button(Strings.Detail.reveal, action: attemptReveal)
                        .disabled(passwordInput.isEmpty)
                    Button(Strings.Common.cancel) {
                        passwordInput = ""
                        showError = false
                        phase = .masked
                    }
                    .buttonStyle(.plain)
                    .foregroundStyle(Theme.textSecondary)
                }
                if showError {
                    Text(Strings.Toast.wrongPassword)
                        .font(Typography.caption)
                        .foregroundStyle(Theme.destructive)
                }
            }
        case .revealed:
            HStack(spacing: Spacing.s10) {
                Text(target).font(Typography.monoSmall).textSelection(.enabled)
                Spacer(minLength: Spacing.s10)
                toggle(icon: Icons.Reveal.hide, title: Strings.Detail.hide) {
                    phase = .masked
                }
            }
        }
    }

    private func toggle(icon: String, title: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: Spacing.s6) {
                Image(systemName: icon)
                Text(title)
            }
            .font(Typography.bodyMedium)
            .foregroundStyle(Theme.accent)
        }
        .buttonStyle(.plain)
    }

    private func attemptReveal() {
        guard Password.verify(passwordInput, against: passwordHash) else {
            showError = true
            return
        }
        passwordInput = ""
        showError = false
        phase = .revealed
    }
}
