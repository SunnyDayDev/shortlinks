import SwiftUI
import ShortlinksCore

struct RedirectOverlay: View {
    @Environment(AppModel.self) private var model

    var body: some View {
        @Bindable var model = model
        ZStack {
            Color.black.opacity(0.45)
                .ignoresSafeArea()
                .onTapGesture { model.closeRedirect() }

            VStack(spacing: 0) {
                HStack(spacing: 9) {
                    RoundedRectangle(cornerRadius: 5).fill(Theme.accent).frame(width: 18, height: 18)
                    Text(Scheme.url(forSlug: model.redirectSlug ?? ""))
                        .font(.system(size: 13, design: .monospaced))
                    Spacer()
                }
                .padding(.horizontal, 22).padding(.vertical, 16)
                .overlay(Divider(), alignment: .bottom)

                switch model.redirectPhase {
                case .ready: ready
                case .blocked: blocked
                case .consumed: consumed
                }
            }
            .frame(width: 430)
            .background(Color(nsColor: .windowBackgroundColor), in: RoundedRectangle(cornerRadius: 16))
            .shadow(color: .black.opacity(0.4), radius: 30, y: 12)
        }
    }

    @ViewBuilder
    private var ready: some View {
        @Bindable var model = model
        if let link = model.redirectLink {
            VStack(alignment: .leading, spacing: 0) {
                Text("Открыть ссылку?").font(.system(size: 15, weight: .bold))
                Text("Этот короткий адрес перенаправит вас на:")
                    .font(.system(size: 13)).foregroundStyle(Theme.secondaryText).padding(.top, 6)
                Text(link.target)
                    .font(.system(size: 12.5, design: .monospaced))
                    .textSelection(.enabled)
                    .padding(12)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Theme.codeBg, in: RoundedRectangle(cornerRadius: 10))
                    .overlay(RoundedRectangle(cornerRadius: 10).stroke(Theme.cardBorder, lineWidth: 0.5))
                    .padding(.top, 12)

                if link.kind == .once {
                    HStack(alignment: .top, spacing: 9) {
                        Image(systemName: "exclamationmark.circle.fill").foregroundStyle(Theme.onceAccent)
                        Text("Одноразовая ссылка. После перехода она станет недоступной.")
                            .font(.system(size: 12)).foregroundStyle(Theme.onceText)
                    }
                    .padding(11)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(hex: 0xE08A2B, alpha: 0.1), in: RoundedRectangle(cornerRadius: 10))
                    .padding(.top, 14)
                }

                if link.isProtected {
                    SecureField("Пароль", text: $model.redirectPasswordInput)
                        .textFieldStyle(.roundedBorder)
                        .padding(.top, 12)
                        .onSubmit { model.confirmRedirect() }
                }

                HStack(spacing: 10) {
                    Button("Отмена") { model.closeRedirect() }
                        .frame(maxWidth: .infinity)
                    Button(action: { model.confirmRedirect() }) {
                        Text(Scheme.detect(link.target).openLabel)
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .keyboardShortcut(.defaultAction)
                }
                .padding(.top, 20)
            }
            .padding(22)
        }
    }

    private var blocked: some View {
        VStack(spacing: 0) {
            Image(systemName: "xmark.circle.fill")
                .font(.system(size: 44)).foregroundStyle(Color(hex: 0xC0392B))
            Text("Ссылка недоступна").font(.system(size: 16, weight: .bold)).padding(.top, 14)
            Text(blockedReason)
                .font(.system(size: 13)).foregroundStyle(Theme.secondaryText)
                .multilineTextAlignment(.center).frame(maxWidth: 300).padding(.top, 7)
            Button("Закрыть") { model.closeRedirect() }.padding(.top, 20)
        }
        .padding(.horizontal, 22).padding(.vertical, 26)
        .frame(maxWidth: .infinity)
    }

    private var consumed: some View {
        VStack(spacing: 0) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 44)).foregroundStyle(Theme.activeAccent)
            Text("Открыто").font(.system(size: 16, weight: .bold)).padding(.top, 14)
            Text("Переход выполнен. Эта одноразовая ссылка сгорела и больше недоступна.")
                .font(.system(size: 13)).foregroundStyle(Theme.secondaryText)
                .multilineTextAlignment(.center).frame(maxWidth: 300).padding(.top, 7)
            Button("Готово") { model.closeRedirect() }
                .buttonStyle(.borderedProminent).padding(.top, 20)
        }
        .padding(.horizontal, 22).padding(.vertical, 26)
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
