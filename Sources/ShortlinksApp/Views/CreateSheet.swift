import SwiftUI
import ShortlinksCore

struct CreateSheet: View {
    @Environment(AppModel.self) private var model

    var body: some View {
        @Bindable var model = model
        VStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 3) {
                Text("Новая ссылка").font(.system(size: 16, weight: .bold))
                Text("Цель хранится локально и открывается по короткому адресу.")
                    .font(.system(size: 12.5)).foregroundStyle(Theme.secondaryText)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 22).padding(.top, 18).padding(.bottom, 6)

            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    field("Цель перехода") {
                        TextField("https://, sl-app://, file:// или путь", text: $model.form.target)
                            .textFieldStyle(.plain)
                            .font(.system(size: 13, design: .monospaced))
                            .padding(.horizontal, 12).frame(height: 34)
                            .background(boxBg)
                    }

                    field("Короткий адрес") {
                        HStack(spacing: 0) {
                            Text("sl://link/").foregroundStyle(Color.secondary)
                                .padding(.leading, 12)
                            TextField("имя", text: $model.form.slug)
                                .textFieldStyle(.plain)
                                .onChange(of: model.form.slug) { _, new in
                                    let cleaned = Slug.clean(new)
                                    if cleaned != new { model.form.slug = cleaned }
                                }
                            Button(action: { model.regenSlug() }) {
                                HStack(spacing: 4) { Image(systemName: "arrow.clockwise"); Text("Случайный") }
                                    .font(.system(size: 12, weight: .semibold))
                                    .padding(.horizontal, 10).frame(height: 26)
                                    .background(Theme.subtleFill, in: RoundedRectangle(cornerRadius: 6))
                            }
                            .buttonStyle(.plain)
                            .padding(.trailing, 5)
                        }
                        .font(.system(size: 13, design: .monospaced))
                        .frame(height: 34)
                        .background(boxBg)
                    }

                    HStack(spacing: 16) {
                        field("Тип") {
                            Picker("", selection: $model.form.kind) {
                                Text("Одноразовая").tag(LinkKind.once)
                                Text("Многоразовая").tag(LinkKind.reuse)
                            }
                            .pickerStyle(.segmented).labelsHidden()
                        }
                        field("Срок действия") {
                            Picker("", selection: $model.form.lifetime) {
                                Text("1 ч").tag(Lifetime.h1)
                                Text("24 ч").tag(Lifetime.h24)
                                Text("7 дн").tag(Lifetime.d7)
                                Text("∞").tag(Lifetime.never)
                            }
                            .pickerStyle(.segmented).labelsHidden()
                        }
                    }

                    field("Метки") {
                        VStack(alignment: .leading, spacing: 6) {
                            if !model.form.tags.isEmpty {
                                FlowLayout(spacing: 6) {
                                    ForEach(model.form.tags, id: \.self) { tag in
                                        TagChip(name: tag, onRemove: { model.removeTag(tag) })
                                    }
                                }
                            }
                            TextField("Добавить метку…", text: $model.form.tagInput)
                                .textFieldStyle(.plain)
                                .font(.system(size: 13))
                                .onSubmit { model.addTag() }
                        }
                        .padding(.horizontal, 12).padding(.vertical, 8)
                        .frame(maxWidth: .infinity, minHeight: 34, alignment: .leading)
                        .background(boxBg)
                    }

                    HStack(spacing: 14) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Защитить паролем").font(.system(size: 13, weight: .medium))
                            Text("Запросить пароль перед переходом")
                                .font(.system(size: 11.5)).foregroundStyle(Theme.secondaryText)
                        }
                        Spacer()
                        Toggle("", isOn: $model.form.passwordOn).labelsHidden().toggleStyle(.switch)
                    }

                    if model.form.passwordOn {
                        SecureField("Пароль", text: $model.form.password)
                            .textFieldStyle(.plain)
                            .padding(.horizontal, 12).frame(height: 34)
                            .background(boxBg)
                    }
                }
                .padding(.horizontal, 22).padding(.top, 14).padding(.bottom, 18)
            }

            HStack {
                Spacer()
                Button("Отмена") { model.showCreate = false }
                Button("Создать ссылку") { model.submitCreate() }
                    .keyboardShortcut(.defaultAction)
                    .disabled(model.form.target.trimmingCharacters(in: .whitespaces).isEmpty)
            }
            .padding(.horizontal, 22).padding(.vertical, 16)
            .overlay(Divider(), alignment: .top)
        }
        .frame(width: 540)
        .frame(maxHeight: 660)
    }

    private var boxBg: some View {
        RoundedRectangle(cornerRadius: 8)
            .fill(Color(nsColor: .textBackgroundColor))
            .overlay(RoundedRectangle(cornerRadius: 8).stroke(Theme.cardBorder, lineWidth: 0.5))
    }

    private func field<Content: View>(_ label: String, @ViewBuilder _ content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label).font(.system(size: 12, weight: .semibold)).foregroundStyle(Color.secondary)
            content()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
