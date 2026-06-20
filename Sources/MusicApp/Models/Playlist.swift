import Foundation

struct Playlist: Identifiable, Hashable {
    let id: UUID
    var name: String
    var description: String
    var artworkName: String
    var songs: [Song]
    var isSmart: Bool

    init(
        id: UUID = UUID(),
        name: String,
        description: String = "",
        artworkName: String = "playlist",
        songs: [Song] = [],
        isSmart: Bool = false
    ) {
        self.id = id
        self.name = name
        self.description = description
        self.artworkName = artworkName
        self.songs = songs
        self.isSmart = isSmart
    }
}
