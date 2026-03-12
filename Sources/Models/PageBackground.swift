import Foundation

/// ページの背景スタイル
enum PageBackground: String, Codable, CaseIterable, Sendable {
    case plain    = "plain"
    case lined    = "lined"
    case grid     = "grid"

    var label: String {
        switch self {
        case .plain: "無地"
        case .lined: "罫線"
        case .grid:  "方眼"
        }
    }

    var icon: String {
        switch self {
        case .plain: "doc"
        case .lined: "line.3.horizontal"
        case .grid:  "grid"
        }
    }
}
