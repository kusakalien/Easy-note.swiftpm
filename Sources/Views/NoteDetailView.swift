import SwiftUI

/// ノート詳細画面 — ページのサムネイル一覧 + ページ編集
struct NoteDetailView: View {
    let noteID: UUID
    @Environment(NoteStore.self) private var store
    @State private var selectedPageID: UUID?
    @State private var editingTitle = false
    @State private var titleDraft = ""
    @State private var showDeleteConfirm = false
    @State private var pageToDelete: UUID?

    private var note: Note? {
        store.notes.first { $0.id == noteID }
    }

    var body: some View {
        Group {
            if let note {
                VStack(spacing: 0) {
                    // サムネイル一覧
                    pageThumbnailStrip(note: note)

                    Divider()

                    // 選択されたページの編集エリア
                    pageEditorArea(note: note)
                }
                .navigationTitle(note.title)
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            titleDraft = note.title
                            editingTitle = true
                        } label: {
                            Image(systemName: "pencil")
                        }
                    }
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            store.addPage(to: noteID)
                        } label: {
                            Image(systemName: "plus")
                        }
                    }
                }
                .alert("ノート名を変更", isPresented: $editingTitle) {
                    TextField("タイトル", text: $titleDraft)
                    Button("保存") {
                        var updated = note
                        updated.title = titleDraft
                        store.update(updated)
                    }
                    Button("キャンセル", role: .cancel) {}
                }
                .confirmationDialog("このページを削除しますか？", isPresented: $showDeleteConfirm, titleVisibility: .visible) {
                    Button("削除", role: .destructive) {
                        if let pageToDelete {
                            store.deletePage(from: noteID, pageID: pageToDelete)
                            // 削除後は先頭ページを選択
                            selectedPageID = store.notes.first(where: { $0.id == noteID })?.pages.first?.id
                        }
                    }
                    Button("キャンセル", role: .cancel) {}
                }
                .onAppear {
                    if selectedPageID == nil {
                        selectedPageID = note.pages.first?.id
                    }
                }
            } else {
                ContentUnavailableView("ノートが見つかりません", systemImage: "doc.questionmark")
            }
        }
    }

    // MARK: - サムネイル一覧

    @ViewBuilder
    private func pageThumbnailStrip(note: Note) -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(Array(note.pages.enumerated()), id: \.element.id) { index, page in
                    PageThumbnailView(page: page, pageNumber: index + 1)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .strokeBorder(
                                    selectedPageID == page.id ? Color.accentColor : .clear,
                                    lineWidth: 2
                                )
                        )
                        .onTapGesture {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                selectedPageID = page.id
                            }
                        }
                        .contextMenu {
                            if note.pages.count > 1 {
                                Button("ページを削除", systemImage: "trash", role: .destructive) {
                                    pageToDelete = page.id
                                    showDeleteConfirm = true
                                }
                            }
                        }
                }
            }
            .padding()
        }
        .frame(height: 160)
        .background(.ultraThinMaterial)
    }

    // MARK: - ページエディタ

    @ViewBuilder
    private func pageEditorArea(note: Note) -> some View {
        if let selectedPageID,
           let pageIndex = note.pages.firstIndex(where: { $0.id == selectedPageID }) {
            let pageBinding = Binding<NotePage>(
                get: { note.pages[pageIndex] },
                set: { newValue in
                    store.updatePage(in: noteID, page: newValue)
                }
            )

            PageEditorView(
                page: pageBinding,
                pageNumber: pageIndex + 1,
                onDelete: {
                    pageToDelete = selectedPageID
                    showDeleteConfirm = true
                },
                canDelete: note.pages.count > 1
            )
        } else {
            ContentUnavailableView("ページを選択してください", systemImage: "doc.text")
        }
    }
}
