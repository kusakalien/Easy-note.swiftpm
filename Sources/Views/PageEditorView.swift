import SwiftUI

/// 1ページ分のテキストエディタ
struct PageEditorView: View {
    @Binding var page: NotePage
    let pageNumber: Int
    let onDelete: () -> Void
    let canDelete: Bool

    @FocusState private var isFocused: Bool

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("ページ \(pageNumber)")
                    .font(.headline)
                    .foregroundStyle(.secondary)
                Spacer()
                if canDelete {
                    Button(role: .destructive) {
                        onDelete()
                    } label: {
                        Image(systemName: "trash")
                            .font(.subheadline)
                    }
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 8)

            Divider()

            TextEditor(text: $page.body)
                .focused($isFocused)
                .scrollContentBackground(.hidden)
                .padding(.horizontal, 8)
        }
    }
}
