//
//  PaletteManager.swift
//  EmojiArt
//
//  Created by Elex Lee on 2/1/22.
//

import SwiftUI

struct PaletteManager: View {
    @EnvironmentObject var store: PaletteStore
    @Environment(\.presentationMode) var presentationMode
    
    @State private var editMode: EditMode = .inactive
    
    var body: some View {
        NavigationView {
            List {
                ForEach(store.palettes) { palette in
                    NavigationLink(destination: PaletteEditor(palette: $store.palettes[palette])) {
                        VStack(alignment: .leading) {
                            Text(palette.name)
                            Text(palette.emojis)
                        }
                    }
                }
                .onDelete { indexSet in
                    store.palettes.remove(atOffsets: indexSet)
                }
                .onMove { indexSet, newOffset in
                    store.palettes.move(fromOffsets: indexSet, toOffset: newOffset)
                }
            }
            .navigationTitle("Manage Palettes")
            .navigationBarTitleDisplayMode(.inline)
            .dismissable { presentationMode.wrappedValue.dismiss() }
            .toolbar {
                ToolbarItem { EditButton() }
//                ToolbarItem(placement: .navigationBarLeading) {
//                    if presentationMode.wrappedValue.isPresented,
//                       UIDevice.current.userInterfaceIdiom != .pad {
//                        Button("Close") {
//                            presentationMode.wrappedValue.dismiss()
//                        }
//                    }
//                }
            }
            .environment(\.editMode, $editMode)
        }
    }
}

struct PaletteManager_Previews: PreviewProvider {
    static var previews: some View {
        PaletteManager()
            .previewDevice("iPhone 8")
            .environmentObject(PaletteStore(named: "Preview"))
    }
}
