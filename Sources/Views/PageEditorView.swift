import SwiftUI
import PencilKit

/// 1ページ分のキャンバスエディタ
struct PageEditorView: View {
    let noteID: UUID
    let pageID: UUID
    let pageNumber: Int
    let background: PageBackground
    let onDelete: () -> Void
    let canDelete: Bool
    @Environment(NoteStore.self) private var store

    @State private var drawing = PKDrawing()
    @State private var needsSave = false

    private var page: NotePage? {
        store.notes.first(where: { $0.id == noteID })?
            .pages.first(where: { $0.id == pageID })
    }

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

            CanvasView(drawing: $drawing, background: background) {
                needsSave = true
            }
        }
        .onAppear {
            if let page {
                drawing = page.drawing
            }
        }
        .onChange(of: pageID) {
            // ページ切り替え時に保存してからロード
            saveIfNeeded()
            if let page {
                drawing = page.drawing
            }
        }
        .onDisappear {
            saveIfNeeded()
        }
        .onChange(of: needsSave) {
            if needsSave {
                // 描画変更後に少し遅延して保存（連続描画中の負荷軽減）
                Task {
                    try? await Task.sleep(for: .seconds(1))
                    saveIfNeeded()
                }
            }
        }
    }

    private func saveIfNeeded() {
        guard needsSave, var page else { return }
        page.drawing = drawing
        store.updatePage(in: noteID, page: page)
        needsSave = false
    }
}
