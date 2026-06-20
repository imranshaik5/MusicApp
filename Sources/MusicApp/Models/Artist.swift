import Foundation

struct Artist: Identifiable, Hashable {
    let id: UUID
    var name: String
    var genre: String
    var bio: String
    var artworkName: String
    var albums: [Album]

    init(
        id: UUID = UUID(),
        name: String,
        genre: String = "Pop",
        bio: String = "",
        artworkName: String = "default",
        albums: [Album] = []
    ) {
        self.id = id
        self.name = name
        self.genre = genre
        self.bio = bio
        self.artworkName = artworkName
        self.albums = albums
    }
}
