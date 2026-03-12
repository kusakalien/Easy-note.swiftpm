import SwiftUI

/// ページのサムネイル表示
struct PageThumbnailView: View {
    let page: NotePage
    let pageNumber: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(page.preview)
                .font(.caption2)
                .foregroundStyle(.primary)
                .lineLimit(4)
                .frame(maxWidth: .infinity, alignment: .topLeading)

            Spacer(minLength: 0)

            Text("ページ \(pageNumber)")
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .padding(8)
        .frame(width: 100, height: 130)
        .background(.regularMaterial, in: .rect(cornerRadius: 8))
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .strokeBorder(.quaternary, lineWidth: 1)
        )
    }
}
