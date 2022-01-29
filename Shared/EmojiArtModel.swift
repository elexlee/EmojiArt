//
//  EmojiArtModel.swift
//  EmojiArt
//
//  Created by Elex Lee on 1/29/22.
//

import Foundation

struct EmojiArtModel {
    var background = Background.blank
    var emojis = [Emoji]()
    
    struct Emoji: Identifiable, Hashable {
        let text: String
        var x: Int // offset from the center
        var y: Int // offset from the center
        var size: Int
        var id: Int
        
        fileprivate init(text: String, at location: (x: Int, y: Int), size: Int, id: Int) {
            self.text = text
            self.x = location.x
            self.y = location.y
            self.size = size
            self.id = id
        }
    }
    
    init() { }
    
    private var uniqueEmojiId = 0
    
    mutating func addEmoji(_ text: String, at location: (x: Int, y: Int), size: Int) {
        uniqueEmojiId += 1
        emojis.append(Emoji(text: text, at: location, size: size, id: uniqueEmojiId))
    }
}
