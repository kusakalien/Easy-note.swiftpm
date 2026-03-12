import Foundation

/// ノート全体を表すモデル（複数ページを含む）
struct Note: Identifiable, Codable, Sendable {
    var id: UUID
    var title: String
    var pages: [NotePage]
    var createdAt: Date
    var updatedAt: Date

    init(id: UUID = UUID(), title: String = "新しいノート", pages: [NotePage]? = nil, createdAt: Date = .now, updatedAt: Date = .now) {
        self.id = id
        self.title = title
        self.pages = pages ?? [NotePage()]
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }

    /// ノートのプレビューテキスト（最初のページの内容）
    var preview: String {
        pages.first?.preview ?? "空のノート"
    }
}
