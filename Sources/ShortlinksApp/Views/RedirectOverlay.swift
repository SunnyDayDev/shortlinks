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
                Text("Открыть ссылку?").font(Typography.headline)
                Text("Этот короткий адрес перенаправит вас на:")
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
                        Image(systemName: "exclamationmark.circle.fill").foregroundStyle(Theme.onceAccent)
                        Text("Одноразовая ссылка. После перехода она станет недоступной.")
                            .font(Typography.caption).foregroundStyle(Theme.onceText)
                    }
                    .padding(Spacing.s12)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Theme.onceBg, in: RoundedRectangle(cornerRadius: Radius.lg))
                    .padding(.top, Spacing.s14)
                }

                if link.isProtected {
                    SecureField("Пароль", text: $model.redirectPasswordInput)
                        .textFieldStyle(.roundedBorder)
                        .padding(.top, Spacing.s12)
                        .onSubmit { model.confirmRedirect() }
                }

                HStack(spacing: Spacing.s10) {
                    Button("Отмена") { model.closeRedirect() }
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
            Image(systemName: "xmark.circle.fill")
                .font(Typography.glyphLarge).foregroundStyle(Theme.destructive)
            Text("Ссылка недоступна").font(Typography.title).padding(.top, Spacing.s14)
            Text(blockedReason)
                .font(Typography.body).foregroundStyle(Theme.textSecondary)
                .multilineTextAlignment(.center).frame(maxWidth: Size.dialogTextMaxWidth).padding(.top, Spacing.s8)
            Button("Закрыть") { model.closeRedirect() }.padding(.top, Spacing.s20)
        }
        .padding(.horizontal, Spacing.s22).padding(.vertical, Spacing.s26)
        .frame(maxWidth: .infinity)
    }

    private var consumed: some View {
        VStack(spacing: 0) {
            Image(systemName: "checkmark.circle.fill")
                .font(Typography.glyphLarge).foregroundStyle(Theme.activeAccent)
            Text("Открыто").font(Typography.title).padding(.top, Spacing.s14)
            Text("Переход выполнен. Эта одноразовая ссылка сгорела и больше недоступна.")
                .font(Typography.body).foregroundStyle(Theme.textSecondary)
                .multilineTextAlignment(.center).frame(maxWidth: Size.dialogTextMaxWidth).padding(.top, Spacing.s8)
            Button("Готово") { model.closeRedirect() }
                .buttonStyle(.borderedProminent).padding(.top, Spacing.s20)
        }
        .padding(.horizontal, Spacing.s22).padding(.vertical, Spacing.s26)
        .frame(maxWidth: .infinity)
    }

    private var blockedReason: String {
        if model.redirectNotFound { return "Короткая ссылка не найдена на этом Mac." }
        if let link = model.redirectLink, link.status() == .viewed {
            return "Эта ссылка уже была просмотрена. Одноразовые ссылки нельзя открыть повторно."
        }
        return "Срок действия ссылки истёк."
    }
}
