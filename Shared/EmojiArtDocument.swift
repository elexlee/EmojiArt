//
//  EmojiArtDocument.swift
//  EmojiArt
//
//  Created by Elex Lee on 1/29/22.
//

import SwiftUI
import Combine
import UniformTypeIdentifiers

extension UTType {
    static let emojiart = UTType(exportedAs: "com.elexlee.emojiart")
}

class EmojiArtDocument: ReferenceFileDocument {
    
    static var readableContentTypes = [UTType.emojiart]
    static var writeableContentTypes = [UTType.emojiart]
    
    required init(configuration: ReadConfiguration) throws {
        if let data = configuration.file.regularFileContents {
            emojiArt = try EmojiArtModel(json: data)
            fetchBackgroundImageDataIfNecessary()
        } else {
            throw CocoaError(.fileReadCorruptFile)
        }
    }
    
    func snapshot(contentType: UTType) throws -> Data {
        try emojiArt.json()
    }
    
    func fileWrapper(snapshot: Data, configuration: WriteConfiguration) throws -> FileWrapper {
        FileWrapper(regularFileWithContents: snapshot)
    }
    
    @Published private(set) var emojiArt: EmojiArtModel {
        didSet {
//            scheduleAutosave()
            if emojiArt.background != oldValue.background {
                fetchBackgroundImageDataIfNecessary()
            }
        }
    }
    
//    private var autosaveTimer: Timer?
//
//    private func scheduleAutosave() {
//        autosaveTimer?.invalidate()
//        autosaveTimer = Timer.scheduledTimer(withTimeInterval: Autosave.coalescingInterval, repeats: false) { _ in
//            self.autosave()
//        }
//    }
//
//    private struct Autosave {
//        static let filename = "Autosaved.emojiart"
//        static var url: URL? {
//            let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
//            return documentDirectory?.appendingPathComponent(filename)
//        }
//        static let coalescingInterval = 5.0
//    }
//
//    private func autosave() {
//        if let url = Autosave.url {
//            save(to: url)
//        }
//    }
//
//    private func save(to url: URL) {
//        let thisFunction = "\(String(describing: self)).\(#function)"
//        do {
//            let data: Data = try emojiArt.json()
//            print("\(thisFunction) json = \(String(data: data, encoding: .utf8) ?? "nil")")
//            try data.write(to: url)
//            print("\(thisFunction) success!")
//        } catch let encodingError where encodingError is EncodingError {
//            print("\(thisFunction) couldn't encode EmojiArt as JSON because \(encodingError.localizedDescription)")
//        } catch {
//            print("\(thisFunction) error = \(error)")
//        }
//    }
    
    init() {
//        if let url = Autosave.url, let autosavedEmojiArt = try? EmojiArtModel(url: url) {
//            self.emojiArt = autosavedEmojiArt
//            fetchBackgroundImageDataIfNecessary()
//        } else {
//            self.emojiArt = EmojiArtModel()
//        }
        emojiArt = EmojiArtModel()
    }
    
    var emojis: [EmojiArtModel.Emoji] { return emojiArt.emojis }
    var background: EmojiArtModel.Background { return emojiArt.background }
    
    @Published var backgroundImage: UIImage?
    @Published var backgroundImageFetchStatus = BackgroundImageFetchStatus.idle
    
    enum BackgroundImageFetchStatus: Equatable {
        case idle
        case fetching
        case failed(URL)
    }
    
    private var backgroundImageFetchCancellable: AnyCancellable?
    
    private func fetchBackgroundImageDataIfNecessary() {
        backgroundImage = nil
        switch emojiArt.background {
        case .url(let url):
            backgroundImageFetchStatus = .fetching
            backgroundImageFetchCancellable?.cancel()
            let session = URLSession.shared
            let publisher = session.dataTaskPublisher(for: url)
                .map { (data, urlResponse) in UIImage(data: data) }
                .replaceError(with: nil)
                .receive(on: DispatchQueue.main)
            
            backgroundImageFetchCancellable = publisher
//                .assign(to: \EmojiArtDocument.backgroundImage, on: self)
                .sink { [weak self] image in
                    self?.backgroundImage = image
                    self?.backgroundImageFetchStatus = (image != nil) ? .idle : .failed(url)
                }
            
            // If we did not replaceError with nil up above
//            (receiveCompletion: { result in
//                    switch result {
//                    case .finished:
//                        print("Success")
//                    case .failure(let error):
//                        print("Error = \(error)")
//                    }
//                })
            
//            DispatchQueue.global(qos: .userInitiated).async {
//                let imageData = try? Data(contentsOf: url)
//                DispatchQueue.main.async { [weak self] in
//                    if self?.emojiArt.background == EmojiArtModel.Background.url(url) {
//                        self?.backgroundImageFetchStatus = .idle
//                        if imageData != nil {
//                            self?.backgroundImage = UIImage(data: imageData!)
//                        }
//                        if self?.backgroundImage == nil {
//                            self?.backgroundImageFetchStatus = .failed(url)
//                        }
//                    }
//                }
//            }
        case .imageData(let data):
            backgroundImage = UIImage(data: data)
        case .blank:
            break
        }
    }
    
    // MARK: - Intent(s)
    
    func setBackground(_ background: EmojiArtModel.Background, undoManager: UndoManager?) {
        undoablyPerform(operation: "Set Background", with: undoManager) {
            emojiArt.background = background
        }
    }
    
    func addEmoji(_ emoji: String, at location: (x: Int, y: Int), size: CGFloat, undoManager: UndoManager?) {
        undoablyPerform(operation: "Add \(emoji)", with: undoManager) {
            emojiArt.addEmoji(emoji, at: location, size: Int(size))
        }
    }
    
    func moveEmoji(_ emoji: EmojiArtModel.Emoji, by offset: CGSize, undoManager: UndoManager?) {
        undoablyPerform(operation: "Move", with: undoManager) {
            if let index = emojiArt.emojis.index(matching: emoji) {
                emojiArt.emojis[index].x += Int(offset.width)
                emojiArt.emojis[index].y += Int(offset.height)
            }
        }
    }
    
    func scaleEmoji(_ emoji: EmojiArtModel.Emoji, by scale: CGFloat, undoManager: UndoManager?) {
        undoablyPerform(operation: "Scale", with: undoManager) {
            if let index = emojiArt.emojis.index(matching: emoji) {
                emojiArt.emojis[index].size = Int((CGFloat(emojiArt.emojis[index].size) * scale).rounded(.toNearestOrAwayFromZero))
            }
        }
        
    }
    
    // MARK: - Undo
    
    private func undoablyPerform(operation: String, with undoManager: UndoManager? = nil, doit: () -> Void) {
        let oldEmojiArt = emojiArt
        doit()
        undoManager?.registerUndo(withTarget: self) { myself in
            myself.undoablyPerform(operation: operation, with: undoManager) {
                myself.emojiArt = oldEmojiArt
            }
        }
        undoManager?.setActionName(operation)
    }
}
