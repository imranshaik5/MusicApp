import Foundation

struct Album: Identifiable, Hashable {
    let id: UUID
    var title: String
    var artist: String
    var artistID: UUID
    var artworkName: String
    var year: Int
    var genre: String
    var trackCount: Int {
        songs.count
    }
    var songs: [Song]

    init(
        id: UUID = UUID(),
        title: String,
        artist: String,
        artistID: UUID = UUID(),
        artworkName: String = "default",
        year: Int = Calendar.current.component(.year, from: Date()),
        genre: String = "Pop",
        songs: [Song] = []
    ) {
        self.id = id
        self.title = title
        self.artist = artist
        self.artistID = artistID
        self.artworkName = artworkName
        self.year = year
        self.genre = genre
        self.songs = songs
    }
}
