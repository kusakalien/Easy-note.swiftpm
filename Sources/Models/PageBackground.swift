import Foundation

/// ページの背景スタイル
enum PageBackground: String, Codable, CaseIterable, Sendable {
    case plain       = "plain"
    case linedSmall  = "lined_s"
    case linedMedium = "lined_m"
    case linedLarge  = "lined_l"
    case gridSmall   = "grid_s"
    case gridMedium  = "grid_m"
    case gridLarge   = "grid_l"

    var label: String {
        switch self {
        case .plain:       "無地"
        case .linedSmall:  "罫線（小）"
        case .linedMedium: "罫線（中）"
        case .linedLarge:  "罫線（大）"
        case .gridSmall:   "方眼（小）"
        case .gridMedium:  "方眼（中）"
        case .gridLarge:   "方眼（大）"
        }
    }

    var icon: String {
        switch self {
        case .plain:                              "doc"
        case .linedSmall, .linedMedium, .linedLarge: "line.3.horizontal"
        case .gridSmall, .gridMedium, .gridLarge:    "grid"
        }
    }

    /// 線の間隔（pt）
    var lineSpacing: CGFloat {
        switch self {
        case .plain:       0
        case .linedSmall:  20
        case .linedMedium: 32
        case .linedLarge:  48
        case .gridSmall:   16
        case .gridMedium:  32
        case .gridLarge:   48
        }
    }

    /// 描画スタイル
    var style: BackgroundStyle {
        switch self {
        case .plain:                                 .plain
        case .linedSmall, .linedMedium, .linedLarge: .lined
        case .gridSmall, .gridMedium, .gridLarge:    .grid
        }
    }

    enum BackgroundStyle {
        case plain, lined, grid
    }
}
