import SwiftUI
import PencilKit

/// PKCanvasView の SwiftUI ラッパー
struct CanvasView: UIViewRepresentable {
    @Binding var drawing: PKDrawing
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
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, PKCanvasViewDelegate {
        let parent: CanvasView
        var toolPicker: PKToolPicker?

        init(_ parent: CanvasView) {
            self.parent = parent
        }

        func canvasViewDrawingDidChange(_ canvasView: PKCanvasView) {
            parent.drawing = canvasView.drawing
            parent.onChanged()
        }
    }
}
