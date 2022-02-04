//
//  EmojiArtApp.swift
//  Shared
//
//  Created by Elex Lee on 1/29/22.
//

import SwiftUI

@main
struct EmojiArtApp: App {
    @StateObject var paletteStore = PaletteStore(named: "Default")
    
    var body: some Scene {
        DocumentGroup(newDocument: { EmojiArtDocument() }) { config in
            EmojiArtDocumentView(document: config.document)
                .environmentObject(paletteStore)
        }
    }
}
