import SwiftUI

struct EmptyStateView: View {
    let onOpenFile: () -> Void

    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "doc.richtext")
                .font(.system(size: 64))
                .foregroundColor(.secondary)

            VStack(spacing: 8) {
                Text("MDPreview")
                    .font(.title)
                    .fontWeight(.semibold)

                Text(Strings.shared.openMarkdownHint)
                    .font(.body)
                    .foregroundColor(.secondary)
            }

            Button(action: onOpenFile) {
                Label(Strings.shared.openFileButton, systemImage: "doc.text")
                    .font(.body)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
            }
            .buttonStyle(.borderedProminent)

            Text(Strings.shared.dragDropHint)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
