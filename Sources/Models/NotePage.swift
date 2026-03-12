import Foundation

/// ノートの1ページを表すモデル
struct NotePage: Identifiable, Codable, Sendable {
    var id: UUID
    var body: String
    var createdAt: Date
    var updatedAt: Date

    init(id: UUID = UUID(), body: String = "", createdAt: Date = .now, updatedAt: Date = .now) {
        self.id = id
        self.body = body
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }

    /// サムネイル用のプレビューテキスト（先頭3行）
    var preview: String {
        let lines = body.components(separatedBy: .newlines).prefix(3)
        let text = lines.joined(separator: "\n")
        return text.isEmpty ? "空のページ" : text
    }
}
