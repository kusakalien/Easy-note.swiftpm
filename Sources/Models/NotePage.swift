import Foundation
import PencilKit

/// ノートの1ページを表すモデル（描画データを保持）
struct NotePage: Identifiable, Codable, Sendable {
    var id: UUID
    var drawingData: Data
    var createdAt: Date
    var updatedAt: Date

    init(id: UUID = UUID(), drawingData: Data = Data(), createdAt: Date = .now, updatedAt: Date = .now) {
        self.id = id
        self.drawingData = drawingData
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }

    /// PKDrawing を取得
    var drawing: PKDrawing {
        get {
            (try? PKDrawing(data: drawingData)) ?? PKDrawing()
        }
        set {
            drawingData = newValue.dataRepresentation()
        }
    }

    /// サムネイル用の UIImage を生成
    func thumbnailImage(size: CGSize) -> UIImage {
        let d = drawing
        if d.bounds.isEmpty {
            return UIImage()
        }
        return d.image(from: d.bounds.insetBy(dx: -20, dy: -20), scale: 2.0)
    }
}
