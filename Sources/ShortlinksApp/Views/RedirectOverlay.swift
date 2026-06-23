import SwiftUI
import ShortlinksCore

struct RedirectOverlay: View {
    @Environment(AppModel.self) private var model

    var body: some View {
        @Bindable var model = model
        ZStack {
            Theme.scrim
                .ignoresSafeArea()
                .onTapGesture { model.closeRedirect() }

            VStack(spacing: 0) {
                HStack(spacing: Spacing.s8) {
                    RoundedRectangle(cornerRadius: Radius.sm).fill(Theme.accent)
                        .frame(width: Size.accentSquare, height: Size.accentSquare)
                    Text(Scheme.url(forSlug: model.redirectSlug ?? ""))
                        .font(Typography.mono)
                    Spacer()
                }
                .padding(.horizontal, Spacing.s22).padding(.vertical, Spacing.s16)
                .overlay(Divider(), alignment: .bottom)

                switch model.redirectPhase {
                case .ready: ready
                case .blocked: blocked
                case .consumed: consumed
                }
            }
            .frame(width: Size.overlayWidth)
            .background(Theme.overlay, in: RoundedRectangle(cornerRadius: Radius.xxl))
            .shadow(color: .black.opacity(0.4), radius: 30, y: 12)
        }
    }

    @ViewBuilder
    private var ready: some View {
        @Bindable var model = model
        if let link = model.redirectLink {
            VStack(alignment: .leading, spacing: 0) {
                Text(Strings.Redirect.confirmTitle).font(Typography.headline)
                Text(Strings.Redirect.confirmBody)
                    .font(Typography.body).foregroundStyle(Theme.textSecondary).padding(.top, Spacing.s6)
                Text(link.target)
                    .font(Typography.monoSmall)
                    .textSelection(.enabled)
                    .padding(Spacing.s12)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .codeBox(bordered: true)
                    .padding(.top, Spacing.s12)

                if link.kind == .once {
                    HStack(alignment: .top, spacing: Spacing.s8) {
                        Image(systemName: Icons.Status.warningOnce).foregroundStyle(Theme.onceAccent)
                        Text(Strings.Redirect.onceWarning)
                            .font(Typography.caption).foregroundStyle(Theme.onceText)
                    }
                    .padding(Spacing.s12)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Theme.onceBg, in: RoundedRectangle(cornerRadius: Radius.lg))
                    .padding(.top, Spacing.s14)
                }

                if link.isProtected {
                    SecureField(Strings.Common.password, text: $model.redirectPasswordInput)
                        .textFieldStyle(.roundedBorder)
                        .padding(.top, Spacing.s12)
                        .onSubmit { model.confirmRedirect() }
                }

                HStack(spacing: Spacing.s10) {
                    Button(Strings.Common.cancel) { model.closeRedirect() }
                        .frame(maxWidth: .infinity)
                    Button(action: { model.confirmRedirect() }) {
                        Text(Scheme.detect(link.target).openLabel)
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .keyboardShortcut(.defaultAction)
                }
                .padding(.top, Spacing.s20)
            }
            .padding(Spacing.s22)
        }
    }

    private var blocked: some View {
        VStack(spacing: 0) {
            Image(systemName: Icons.Status.error)
                .font(Typography.glyphLarge).foregroundStyle(Theme.destructive)
            Text(Strings.Common.linkUnavailable).font(Typography.title).padding(.top, Spacing.s14)
            Text(blockedReason)
                .font(Typography.body).foregroundStyle(Theme.textSecondary)
                .multilineTextAlignment(.center).frame(maxWidth: Size.dialogTextMaxWidth).padding(.top, Spacing.s8)
            Button(Strings.Common.close) { model.closeRedirect() }.padding(.top, Spacing.s20)
        }
        .padding(.horizontal, Spacing.s22).padding(.vertical, Spacing.s26)
        .frame(maxWidth: .infinity)
    }

    private var consumed: some View {
        VStack(spacing: 0) {
            Image(systemName: Icons.Status.success)
                .font(Typography.glyphLarge).foregroundStyle(Theme.activeAccent)
            Text(Strings.Redirect.consumedTitle).font(Typography.title).padding(.top, Spacing.s14)
            Text(Strings.Redirect.consumedBody)
                .font(Typography.body).foregroundStyle(Theme.textSecondary)
                .multilineTextAlignment(.center).frame(maxWidth: Size.dialogTextMaxWidth).padding(.top, Spacing.s8)
            Button(Strings.Common.done) { model.closeRedirect() }
                .buttonStyle(.borderedProminent).padding(.top, Spacing.s20)
        }
        .padding(.horizontal, Spacing.s22).padding(.vertical, Spacing.s26)
        .frame(maxWidth: .infinity)
    }

    private var blockedReason: String {
        if model.redirectNotFound { return Strings.Redirect.notFound }
        if let link = model.redirectLink, link.status() == .viewed {
            return Strings.Redirect.alreadyViewed
        }
        return Strings.Redirect.expired
    }
}
