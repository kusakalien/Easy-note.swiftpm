import SwiftUI

/// ページのサムネイル表示（描画内容をプレビュー）
struct PageThumbnailView: View {
    let page: NotePage
    let pageNumber: Int

    var body: some View {
        VStack(spacing: 4) {
            let img = page.thumbnailImage(size: CGSize(width: 100, height: 110))
            if img.size == .zero {
                Image(systemName: "pencil.tip.crop.circle")
                    .font(.largeTitle)
                    .foregroundStyle(.quaternary)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                Image(uiImage: img)
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }

            Text("P.\(pageNumber)")
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .padding(6)
        .frame(width: 100, height: 130)
        .background(.regularMaterial, in: .rect(cornerRadius: 8))
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .strokeBorder(.quaternary, lineWidth: 1)
        )
    }
}
