import SwiftUI
import ShortlinksCore

struct CreateSheet: View {
    @Environment(AppModel.self) private var model

    var body: some View {
        @Bindable var model = model
        VStack(spacing: 0) {
            VStack(alignment: .leading, spacing: Spacing.s4) {
                Text(Strings.Common.newLink).font(Typography.title)
                Text(Strings.Create.subtitle)
                    .font(Typography.caption).foregroundStyle(Theme.textSecondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, Spacing.s22).padding(.top, Spacing.s18).padding(.bottom, Spacing.s6)

            ScrollView {
                VStack(alignment: .leading, spacing: Spacing.s16) {
                    LabeledField(Strings.Create.targetLabel) {
                        TextField(Strings.Create.targetPlaceholder, text: $model.form.target)
                            .textFieldStyle(.plain)
                            .font(Typography.mono)
                            .padding(.horizontal, Spacing.s12).frame(height: Size.fieldHeight)
                            .fieldBox()
                    }

                    LabeledField(Strings.Create.shortLabel) {
                        HStack(spacing: 0) {
                            Text("sl://link/").foregroundStyle(Theme.textSecondary)
                                .padding(.leading, Spacing.s12)
                            TextField(Strings.Create.namePlaceholder, text: $model.form.slug)
                                .textFieldStyle(.plain)
                                .onChange(of: model.form.slug) { _, new in
                                    let cleaned = Slug.clean(new)
                                    if cleaned != new { model.form.slug = cleaned }
                                }
                            Button(action: { model.regenSlug() }) {
                                HStack(spacing: Spacing.s4) { Image(systemName: Icons.Action.random); Text(Strings.Create.random) }
                                    .font(Typography.captionEmphasis)
                                    .padding(.horizontal, Spacing.s8).frame(height: Size.chipButtonHeight)
                                    .background(Theme.subtleFill, in: RoundedRectangle(cornerRadius: Radius.sm))
                            }
                            .buttonStyle(.plain)
                            .padding(.trailing, Spacing.s6)
                        }
                        .font(Typography.mono)
                        .frame(height: Size.fieldHeight)
                        .fieldBox()
                    }

                    HStack(spacing: Spacing.s16) {
                        LabeledField(Strings.Create.typeLabel) {
                            Picker("", selection: $model.form.kind) {
                                Text(Strings.Kind.once).tag(LinkKind.once)
                                Text(Strings.Kind.reuse).tag(LinkKind.reuse)
                            }
                            .pickerStyle(.segmented).labelsHidden()
                        }
                        LabeledField(Strings.Common.lifetimeTitle) {
                            Picker("", selection: $model.form.lifetime) {
                                Text(Strings.LifetimeLabel.h1).tag(Lifetime.h1)
                                Text(Strings.LifetimeLabel.h24).tag(Lifetime.h24)
                                Text(Strings.LifetimeLabel.d7).tag(Lifetime.d7)
                                Text(Strings.LifetimeLabel.neverShort).tag(Lifetime.never)
                            }
                            .pickerStyle(.segmented).labelsHidden()
                        }
                    }

                    LabeledField(Strings.Create.tagsLabel) {
                        VStack(alignment: .leading, spacing: Spacing.s6) {
                            if !model.form.tags.isEmpty {
                                FlowLayout(spacing: Spacing.s6) {
                                    ForEach(model.form.tags, id: \.self) { tag in
                                        TagChip(name: tag, onRemove: { model.removeTag(tag) })
                                    }
                                }
                            }
                            TextField(Strings.Create.addTag, text: $model.form.tagInput)
                                .textFieldStyle(.plain)
                                .font(Typography.body)
                                .onSubmit { model.addTag() }
                        }
                        .padding(.horizontal, Spacing.s12).padding(.vertical, Spacing.s8)
                        .frame(maxWidth: .infinity, minHeight: Size.fieldHeight, alignment: .leading)
                        .fieldBox()
                    }

                    HStack(spacing: Spacing.s14) {
                        VStack(alignment: .leading, spacing: Spacing.s2) {
                            Text(Strings.Create.passwordProtect).font(Typography.bodyMedium)
                            Text(Strings.Create.passwordHint)
                                .font(Typography.caption2).foregroundStyle(Theme.textSecondary)
                        }
                        Spacer()
                        Toggle("", isOn: $model.form.passwordOn).labelsHidden().toggleStyle(.switch)
                    }

                    if model.form.passwordOn {
                        SecureField(Strings.Common.password, text: $model.form.password)
                            .textFieldStyle(.plain)
                            .padding(.horizontal, Spacing.s12).frame(height: Size.fieldHeight)
                            .fieldBox()
                    }
                }
                .padding(.horizontal, Spacing.s22).padding(.top, Spacing.s14).padding(.bottom, Spacing.s18)
            }

            HStack {
                Spacer()
                Button(Strings.Common.cancel) { model.showCreate = false }
                Button(Strings.Create.submit) { model.submitCreate() }
                    .keyboardShortcut(.defaultAction)
                    .disabled(model.form.target.trimmingCharacters(in: .whitespaces).isEmpty)
            }
            .padding(.horizontal, Spacing.s22).padding(.vertical, Spacing.s16)
            .overlay(Divider(), alignment: .top)
        }
        .frame(width: Size.sheetWidth)
        .frame(maxHeight: Size.sheetMaxHeight)
    }
}
