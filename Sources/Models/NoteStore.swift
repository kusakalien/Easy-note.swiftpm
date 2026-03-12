import Foundation
import Observation

/// ノートの永続化とCRUD操作を管理するストア
/// Documents ディレクトリに保存し、iCloud Files 経由で同期される
@Observable
final class NoteStore {
    private(set) var notes: [Note] = []

    private let fileManager = FileManager.default

    /// ノート保存用ディレクトリ
    private var notesDirectory: URL {
        let documents = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        let dir = documents.appendingPathComponent("EasyNotes", isDirectory: true)
        if !fileManager.fileExists(atPath: dir.path()) {
            try? fileManager.createDirectory(at: dir, withIntermediateDirectories: true)
        }
        return dir
    }

    init() {
        loadAll()
    }

    // MARK: - CRUD

    /// 新しいノートを作成
    func createNote(title: String = "新しいノート") -> Note {
        var note = Note(title: title)
        notes.insert(note, at: 0)
        save(note)
        return note
    }

    /// ノートを更新
    func update(_ note: Note) {
        var updated = note
        updated.updatedAt = .now
        if let index = notes.firstIndex(where: { $0.id == note.id }) {
            notes[index] = updated
        }
        save(updated)
    }

    /// ノートを削除
    func delete(_ note: Note) {
        notes.removeAll { $0.id == note.id }
        let fileURL = noteFileURL(for: note.id)
        try? fileManager.removeItem(at: fileURL)
    }

    /// 指定ノートにページを追加
    func addPage(to noteID: UUID) {
        guard let index = notes.firstIndex(where: { $0.id == noteID }) else { return }
        let newPage = NotePage()
        notes[index].pages.append(newPage)
        notes[index].updatedAt = .now
        save(notes[index])
    }

    /// 指定ノートからページを削除
    func deletePage(from noteID: UUID, pageID: UUID) {
        guard let index = notes.firstIndex(where: { $0.id == noteID }) else { return }
        notes[index].pages.removeAll { $0.id == pageID }
        // ページが0になったら空ページを1つ追加
        if notes[index].pages.isEmpty {
            notes[index].pages.append(NotePage())
        }
        notes[index].updatedAt = .now
        save(notes[index])
    }

    /// ページ内容を更新
    func updatePage(in noteID: UUID, page: NotePage) {
        guard let noteIndex = notes.firstIndex(where: { $0.id == noteID }) else { return }
        guard let pageIndex = notes[noteIndex].pages.firstIndex(where: { $0.id == page.id }) else { return }
        var updatedPage = page
        updatedPage.updatedAt = .now
        notes[noteIndex].pages[pageIndex] = updatedPage
        notes[noteIndex].updatedAt = .now
        save(notes[noteIndex])
    }

    // MARK: - Persistence

    private func noteFileURL(for id: UUID) -> URL {
        notesDirectory.appendingPathComponent("\(id.uuidString).json")
    }

    private func save(_ note: Note) {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = .prettyPrinted
        guard let data = try? encoder.encode(note) else { return }
        try? data.write(to: noteFileURL(for: note.id), options: .atomic)
    }

    private func loadAll() {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        guard let files = try? fileManager.contentsOfDirectory(at: notesDirectory, includingPropertiesForKeys: [.contentModificationDateKey]) else { return }

        notes = files
            .filter { $0.pathExtension == "json" }
            .compactMap { url -> Note? in
                guard let data = try? Data(contentsOf: url) else { return nil }
                return try? decoder.decode(Note.self, from: data)
            }
            .sorted { $0.updatedAt > $1.updatedAt }
    }

    /// 外部変更検知用にリロード
    func reload() {
        loadAll()
    }
}
