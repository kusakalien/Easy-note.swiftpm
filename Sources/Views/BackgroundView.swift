import SwiftUI

/// キャンバスの背景に罫線・方眼を描画するビュー
struct BackgroundView: View {
    let background: PageBackground
    let lineSpacing: CGFloat = 32

    var body: some View {
        switch background {
        case .plain:
            Color.clear
        case .lined:
            Canvas { context, size in
                let lineColor = Color.primary.opacity(0.1)
                var y = lineSpacing
                while y < size.height {
                    let path = Path { p in
                        p.move(to: CGPoint(x: 0, y: y))
                        p.addLine(to: CGPoint(x: size.width, y: y))
                    }
                    context.stroke(path, with: .color(lineColor), lineWidth: 0.5)
                    y += lineSpacing
                }
            }
        case .grid:
            Canvas { context, size in
                let lineColor = Color.primary.opacity(0.1)
                // 横線
                var y = lineSpacing
                while y < size.height {
                    let path = Path { p in
                        p.move(to: CGPoint(x: 0, y: y))
                        p.addLine(to: CGPoint(x: size.width, y: y))
                    }
                    context.stroke(path, with: .color(lineColor), lineWidth: 0.5)
                    y += lineSpacing
                }
                // 縦線
                var x = lineSpacing
                while x < size.width {
                    let path = Path { p in
                        p.move(to: CGPoint(x: x, y: 0))
                        p.addLine(to: CGPoint(x: x, y: size.height))
                    }
                    context.stroke(path, with: .color(lineColor), lineWidth: 0.5)
                    x += lineSpacing
                }
            }
        }
    }
}
