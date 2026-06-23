import SwiftUI
import ShortlinksCore

struct HowItWorksView: View {
    private let steps = [
        ("1", Strings.HowItWorks.step1Title, Strings.HowItWorks.step1Body, Theme.accent),
        ("2", Strings.HowItWorks.step2Title, Strings.HowItWorks.step2Body, Theme.accent),
        ("3", Strings.HowItWorks.step3Title, Strings.HowItWorks.step3Body, Theme.accent),
        ("4", Strings.HowItWorks.step4Title, Strings.HowItWorks.step4Body, Theme.onceAccent),
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(Strings.HowItWorks.title)
                .font(Typography.display)
            Text(Strings.HowItWorks.intro)
                .font(Typography.bodyLarge)
                .foregroundStyle(Theme.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: Size.proseMaxWidth, alignment: .leading)
                .padding(.top, Spacing.s8)

            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: Spacing.s12), count: 2), spacing: Spacing.s12) {
                ForEach(steps, id: \.0) { step in
                    VStack(alignment: .leading, spacing: 0) {
                        Text(step.0)
                            .font(Typography.bodyEmphasis)
                            .foregroundStyle(Theme.onAccent)
                            .frame(width: Size.stepBadge, height: Size.stepBadge)
                            .background(step.3, in: RoundedRectangle(cornerRadius: Radius.md))
                        Text(step.1).font(Typography.sectionTitle).padding(.top, Spacing.s12)
                        Text(step.2)
                            .font(Typography.caption)
                            .foregroundStyle(Theme.textSecondary)
                            .fixedSize(horizontal: false, vertical: true)
                            .padding(.top, Spacing.s6)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(Spacing.s16)
                    .card()
                }
            }
            .padding(.top, Spacing.s26)

            HStack(spacing: Spacing.s14) {
                Text("sl://link/demo")
                    .font(Typography.mono).foregroundStyle(Theme.accent)
                Image(systemName: Icons.Action.redirect).foregroundStyle(Theme.textSecondary)
                Text("https://example.com/very/long/target?token=…")
                    .font(Typography.mono)
                    .foregroundStyle(Theme.textSecondary)
                    .lineLimit(1)
            }
            .padding(Spacing.s16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .card(fill: Theme.infoBg, stroke: Theme.infoBorder)
            .padding(.top, Spacing.s24)
        }
        .screenContainer(maxWidth: Size.howMaxWidth, top: Spacing.s22)
    }
}
