import SwiftUI
import PencilKit

/// PKCanvasView の SwiftUI ラッパー（ピンチズーム対応）
struct CanvasView: UIViewRepresentable {
    @Binding var drawing: PKDrawing
    let background: PageBackground
    let onChanged: () -> Void

    func makeUIView(context: Context) -> PKCanvasView {
        let canvas = PKCanvasView()
        canvas.drawing = drawing
        canvas.delegate = context.coordinator
        canvas.drawingPolicy = .anyInput
        canvas.backgroundColor = .clear
        canvas.isOpaque = false
        // Scribble（手書き→テキスト変換）を無効化
        canvas.isRulerActive = false
        canvas.tool = PKInkingTool(.pen, color: .label, width: 5)
        // ピンチズーム設定
        canvas.minimumZoomScale = 0.5
        canvas.maximumZoomScale = 5.0
        canvas.bouncesZoom = true
        // コンテンツサイズを大きめに設定（広いキャンバス）
        canvas.contentSize = CGSize(width: 2000, height: 3000)
        // 背景ビューを追加
        let bgView = BackgroundUIView(background: background)
        bgView.frame = CGRect(origin: .zero, size: canvas.contentSize)
        bgView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        canvas.insertSubview(bgView, at: 0)
        context.coordinator.backgroundView = bgView
        // デフォルトのツールピッカーを表示
        let toolPicker = PKToolPicker()
        toolPicker.setVisible(true, forFirstResponder: canvas)
        toolPicker.addObserver(canvas)
        toolPicker.showsDrawingPolicyControls = false
        context.coordinator.toolPicker = toolPicker
        canvas.becomeFirstResponder()
        return canvas
    }

    func updateUIView(_ uiView: PKCanvasView, context: Context) {
        if uiView.drawing.dataRepresentation() != drawing.dataRepresentation() {
            uiView.drawing = drawing
        }
        context.coordinator.backgroundView?.background = background
        context.coordinator.backgroundView?.setNeedsDisplay()
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, PKCanvasViewDelegate {
        let parent: CanvasView
        var toolPicker: PKToolPicker?
        var backgroundView: BackgroundUIView?

        init(_ parent: CanvasView) {
            self.parent = parent
        }

        func canvasViewDrawingDidChange(_ canvasView: PKCanvasView) {
            parent.drawing = canvasView.drawing
            parent.onChanged()
        }

        func scrollViewDidZoom(_ scrollView: UIScrollView) {
            guard let bgView = backgroundView else { return }
            let scale = scrollView.zoomScale
            bgView.transform = CGAffineTransform(scaleX: scale, y: scale)
        }
    }
}

// MARK: - 背景描画用 UIView（PKCanvasView 内に配置してズームに追従）

final class BackgroundUIView: UIView {
    var background: PageBackground
    private let lineSpacing: CGFloat = 32

    init(background: PageBackground) {
        self.background = background
        super.init(frame: .zero)
        self.isOpaque = false
        self.backgroundColor = .clear
        self.isUserInteractionEnabled = false
        self.layer.anchorPoint = .zero
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError()
    }

    override func draw(_ rect: CGRect) {
        guard let ctx = UIGraphicsGetCurrentContext() else { return }
        let lineColor = UIColor.label.withAlphaComponent(0.1)
        ctx.setStrokeColor(lineColor.cgColor)
        ctx.setLineWidth(0.5)

        switch background {
        case .plain:
            break
        case .lined:
            var y = lineSpacing
            while y < rect.height {
                ctx.move(to: CGPoint(x: 0, y: y))
                ctx.addLine(to: CGPoint(x: rect.width, y: y))
                y += lineSpacing
            }
            ctx.strokePath()
        case .grid:
            var y = lineSpacing
            while y < rect.height {
                ctx.move(to: CGPoint(x: 0, y: y))
                ctx.addLine(to: CGPoint(x: rect.width, y: y))
                y += lineSpacing
            }
            var x = lineSpacing
            while x < rect.width {
                ctx.move(to: CGPoint(x: x, y: 0))
                ctx.addLine(to: CGPoint(x: x, y: rect.height))
                x += lineSpacing
            }
            ctx.strokePath()
        }
    }
}
