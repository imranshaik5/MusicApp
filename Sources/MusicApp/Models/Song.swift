import Foundation

struct Song: Identifiable, Hashable {
    let id: UUID
    var title: String
    var artist: String
    var album: String
    var albumID: UUID
    var duration: TimeInterval
    var trackNumber: Int
    var genre: String
    var artworkName: String
    var isFavorite: Bool
    var youtubeTrackID: String?

    var streamURL: URL? {
        guard let id = youtubeTrackID else { return nil }
        return URL(string: "https://drive.usercontent.google.com/download?id=\(id)&export=open")
    }

    init(
        id: UUID = UUID(),
        title: String,
        artist: String,
        album: String,
        albumID: UUID = UUID(),
        duration: TimeInterval,
        trackNumber: Int = 0,
        genre: String = "Pop",
        artworkName: String = "default",
        isFavorite: Bool = false,
        youtubeTrackID: String? = nil
    ) {
        self.id = id
        self.title = title
        self.artist = artist
        self.album = album
        self.albumID = albumID
        self.duration = duration
        self.trackNumber = trackNumber
        self.genre = genre
        self.artworkName = artworkName
        self.isFavorite = isFavorite
        self.youtubeTrackID = youtubeTrackID
    }
}
