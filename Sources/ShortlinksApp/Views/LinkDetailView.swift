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
                HStack(spacing: 5) {
                    Image(systemName: "chevron.left")
                    Text("Все ссылки")
                }
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(Theme.accent)
            }
            .buttonStyle(.plain)
            .padding(.bottom, 18)

            HStack(spacing: 14) {
                TargetIcon(target: link.target, size: 52)
                VStack(alignment: .leading, spacing: 7) {
                    Text(link.fullURL)
                        .font(.system(size: 18, weight: .semibold, design: .monospaced))
                    StatusPill(status: status)
                }
                Spacer()
                Button("Копировать") { model.copy(link.fullURL) }
                    .buttonStyle(.bordered)
            }
            .padding(.bottom, 22)

            infoCard(link, status: status)

            HStack(spacing: 10) {
                if status == .active {
                    Button(action: { model.presentRedirect(for: link) }) {
                        HStack(spacing: 7) {
                            Image(systemName: "arrow.right")
                            Text(Scheme.detect(link.target).openLabel)
                        }
                        .font(.system(size: 13.5, weight: .semibold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 18).frame(height: 36)
                        .background(Theme.accent, in: RoundedRectangle(cornerRadius: 9))
                    }
                    .buttonStyle(.plain)
                } else {
                    Text("Ссылка недоступна")
                        .font(.system(size: 13.5, weight: .semibold))
                        .foregroundStyle(Theme.secondaryText)
                        .padding(.horizontal, 18).frame(height: 36)
                        .background(Color.black.opacity(0.05), in: RoundedRectangle(cornerRadius: 9))
                }
                Spacer()
                Button(role: .destructive, action: { model.delete(id: link.id) }) {
                    Text("Удалить")
                        .font(.system(size: 13.5, weight: .semibold))
                        .foregroundStyle(Color(hex: 0xC0392B))
                        .padding(.horizontal, 16).frame(height: 36)
                        .background(Color(hex: 0xD2372D, alpha: 0.08), in: RoundedRectangle(cornerRadius: 9))
                }
                .buttonStyle(.plain)
            }
            .padding(.top, 20)
        }
        .padding(.horizontal, 24).padding(.top, 18).padding(.bottom, 28)
        .frame(maxWidth: 680, alignment: .leading)
    }

    private func infoCard(_ link: Link, status: LinkStatus) -> some View {
        VStack(spacing: 0) {
            infoRow("Перенаправляет на", link.target, mono: true)
            Divider()
            infoRow("Тип", Format.kindLabel(link.kind))
            Divider()
            infoRow("Переходов", Format.opensText(link.opens))
            Divider()
            infoRow("Срок действия", status == .active ? Format.expiresText(link) : (status == .viewed ? "Просмотрена" : "Истёк"))
            Divider()
            infoRow("Пароль", link.isProtected ? "Включён" : "Нет")
            if !link.tags.isEmpty {
                Divider()
                HStack(alignment: .top) {
                    Text("Метки").frame(width: 150, alignment: .leading).foregroundStyle(Theme.secondaryText)
                    FlowLayout(spacing: 6) {
                        ForEach(link.tags, id: \.self) { TagChip(name: $0) }
                    }
                }
                .padding(.horizontal, 16).padding(.vertical, 13)
            }
            Divider()
            infoRow("Создана", created(link))
        }
        .font(.system(size: 13))
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Theme.cardBorder, lineWidth: 0.5))
        .background(Color(nsColor: .controlBackgroundColor), in: RoundedRectangle(cornerRadius: 12))
    }

    private func infoRow(_ label: String, _ value: String, mono: Bool = false) -> some View {
        HStack(alignment: .top) {
            Text(label).frame(width: 150, alignment: .leading).foregroundStyle(Theme.secondaryText)
            Text(value)
                .font(mono ? .system(size: 12.5, design: .monospaced) : .system(size: 13, weight: .medium))
                .textSelection(.enabled)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.horizontal, 16).padding(.vertical, 13)
    }

    private func created(_ link: Link) -> String {
        let fmt = DateFormatter()
        fmt.locale = Locale(identifier: "ru_RU")
        fmt.dateStyle = .medium
        fmt.timeStyle = .short
        return fmt.string(from: link.createdAt)
    }
}
