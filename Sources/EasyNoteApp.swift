import SwiftUI

@main
struct EasyNoteApp: App {
    @State private var store = NoteStore()

    var body: some Scene {
        WindowGroup {
            NoteListView()
                .environment(store)
        }
    }
}
