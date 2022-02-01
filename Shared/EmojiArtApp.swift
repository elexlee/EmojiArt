//
//  EmojiArtApp.swift
//  Shared
//
//  Created by Elex Lee on 1/29/22.
//

import SwiftUI

@main
struct EmojiArtApp: App {
    var body: some Scene {
        let document = EmojiArtDocument()
        let paletteStore = PaletteStore(named: "Default")
        
        WindowGroup {
            EmojiArtDocumentView(document: document, paletteStore: paletteStore)
        }
    }
}
