import SwiftUI
import ShortlinksCore

struct LinkListView: View {
    @Environment(AppModel.self) private var model

    var body: some View {
        let links = model.filteredLinks
        if links.isEmpty {
            EmptyState()
        } else {
            VStack(spacing: 8) {
                ForEach(links) { link in
                    LinkRow(link: link)
                        .contentShape(Rectangle())
                        .onTapGesture { model.openDetail(link.id) }
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 14).padding(.bottom, 24)
        }
    }
}

struct LinkRow: View {
    let link: Link

    var body: some View {
        HStack(spacing: 13) {
            TargetIcon(target: link.target)
            VStack(alignment: .leading, spacing: 3) {
                HStack(spacing: 0) {
                    Text("sl://link/").foregroundStyle(Color(hex: 0x3C3C43, alpha: 0.45))
                    Text(link.slug).foregroundStyle(.primary)
                }
                .font(.system(size: 13.5, design: .monospaced))
                .lineLimit(1)

                Text(link.target)
                    .font(.system(size: 12))
                    .foregroundStyle(Theme.secondaryText)
                    .lineLimit(1)

                Text(Format.subtitle(link))
                    .font(.system(size: 11.5))
                    .foregroundStyle(Color(hex: 0x3C3C43, alpha: 0.5))

                if !link.tags.isEmpty {
                    FlowLayout(spacing: 5) {
                        ForEach(link.tags, id: \.self) { TagChip(name: $0) }
                    }
                    .padding(.top, 3)
                }
            }
            Spacer(minLength: 6)
            StatusPill(status: link.status())
            Image(systemName: "chevron.right")
                .font(.system(size: 12))
                .foregroundStyle(Color(hex: 0x3C3C43, alpha: 0.3))
        }
        .padding(.horizontal, 14).padding(.vertical, 12)
        .background(Color(nsColor: .controlBackgroundColor), in: RoundedRectangle(cornerRadius: 10))
        .overlay(RoundedRectangle(cornerRadius: 10).stroke(Theme.cardBorder, lineWidth: 0.5))
    }
}

struct EmptyState: View {
    @Environment(AppModel.self) private var model

    var body: some View {
        VStack(spacing: 0) {
            Text("sl://")
                .font(.system(size: 15, design: .monospaced))
                .foregroundStyle(Color(hex: 0x9AA0AC))
                .frame(width: 64, height: 64)
                .background(Theme.iconBg, in: RoundedRectangle(cornerRadius: 16))
                .padding(.bottom, 16)
            Text("Здесь пока пусто").font(.system(size: 16, weight: .semibold))
            Text("Создайте короткую ссылку — она будет работать на этом Mac.")
                .font(.system(size: 13))
                .foregroundStyle(Theme.secondaryText)
                .multilineTextAlignment(.center)
                .frame(maxWidth: 280)
                .padding(.top, 6)
            Button(action: { model.openCreate() }) {
                HStack(spacing: 6) { Image(systemName: "plus"); Text("Новая ссылка") }
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 16).frame(height: 32)
                    .background(Theme.accent, in: RoundedRectangle(cornerRadius: 8))
            }
            .buttonStyle(.plain)
            .padding(.top, 18)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 90)
    }
}
