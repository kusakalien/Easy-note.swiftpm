import SwiftUI

/// ノート詳細画面 — ページのサムネイル一覧 + キャンバス編集
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
                    pageThumbnailStrip(note: note)
                    Divider()
                    pageEditorArea(note: note)
                }
                .navigationTitle(note.title)
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Menu {
                            Section("無地") {
                                backgroundButton(note: note, bg: .plain)
                            }
                            Section("罫線") {
                                backgroundButton(note: note, bg: .linedSmall)
                                backgroundButton(note: note, bg: .linedMedium)
                                backgroundButton(note: note, bg: .linedLarge)
                            }
                            Section("方眼") {
                                backgroundButton(note: note, bg: .gridSmall)
                                backgroundButton(note: note, bg: .gridMedium)
                                backgroundButton(note: note, bg: .gridLarge)
                            }
                        } label: {
                            Image(systemName: note.background.icon)
                        }
                    }
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            titleDraft = note.title
                            editingTitle = true
                        } label: {
                            Image(systemName: "character.cursor.ibeam")
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

    private func backgroundButton(note: Note, bg: PageBackground) -> some View {
        Button {
            var updated = note
            updated.background = bg
            store.update(updated)
        } label: {
            HStack {
                Text(bg.label)
                if note.background == bg {
                    Spacer()
                    Image(systemName: "checkmark")
                }
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
            PageEditorView(
                noteID: noteID,
                pageID: selectedPageID,
                pageNumber: pageIndex + 1,
                background: note.background,
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
