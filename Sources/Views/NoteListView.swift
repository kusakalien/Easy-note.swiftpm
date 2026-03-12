import SwiftUI

/// ノート一覧画面
struct NoteListView: View {
    @Environment(NoteStore.self) private var store
    @State private var selectedNoteID: UUID?
    @State private var showDeleteConfirm = false
    @State private var noteToDelete: Note?

    var body: some View {
        NavigationSplitView {
            Group {
                if store.notes.isEmpty {
                    ContentUnavailableView {
                        Label("ノートがありません", systemImage: "note.text")
                    } description: {
                        Text("＋ボタンで新しいノートを作成しましょう")
                    }
                } else {
                    noteList
                }
            }
            .navigationTitle("Easy Note")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        let note = store.createNote()
                        selectedNoteID = note.id
                    } label: {
                        Image(systemName: "plus")
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        store.reload()
                    } label: {
                        Image(systemName: "arrow.clockwise")
                    }
                }
            }
            .confirmationDialog("このノートを削除しますか？", isPresented: $showDeleteConfirm, titleVisibility: .visible) {
                Button("削除", role: .destructive) {
                    if let noteToDelete {
                        if selectedNoteID == noteToDelete.id {
                            selectedNoteID = nil
                        }
                        store.delete(noteToDelete)
                    }
                }
                Button("キャンセル", role: .cancel) {}
            }
        } detail: {
            if let selectedNoteID {
                NoteDetailView(noteID: selectedNoteID)
            } else {
                ContentUnavailableView("ノートを選択してください", systemImage: "note.text")
            }
        }
    }

    // MARK: - ノートリスト

    private var noteList: some View {
        List(store.notes, selection: $selectedNoteID) { note in
            NavigationLink(value: note.id) {
                noteRow(note)
            }
            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                Button(role: .destructive) {
                    noteToDelete = note
                    showDeleteConfirm = true
                } label: {
                    Label("削除", systemImage: "trash")
                }
            }
        }
    }

    private func noteRow(_ note: Note) -> some View {
        HStack(spacing: 12) {
            // サムネイルプレビュー
            let img = note.pages.first?.thumbnailImage(size: CGSize(width: 44, height: 44)) ?? UIImage()
            if img.size == .zero {
                RoundedRectangle(cornerRadius: 6)
                    .fill(.quaternary)
                    .frame(width: 44, height: 44)
                    .overlay {
                        Image(systemName: "pencil.tip")
                            .foregroundStyle(.secondary)
                    }
            } else {
                Image(uiImage: img)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 44, height: 44)
                    .clipShape(.rect(cornerRadius: 6))
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(note.title)
                    .font(.headline)
                    .lineLimit(1)

                HStack {
                    Text("\(note.pages.count) ページ")
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                    Spacer()
                    Text(note.updatedAt, format: .dateTime.month().day().hour().minute())
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                }
            }
        }
        .padding(.vertical, 4)
    }
}
