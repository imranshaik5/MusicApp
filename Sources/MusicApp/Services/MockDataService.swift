import Foundation

// MARK: - Mock Data

struct MockSong {
    let title: String
    let subtitle: String
    let artworkName: String
    let genre: String
    let duration: TimeInterval
}

let mockSongs: [MockSong] = [
    MockSong(title: "After Hours", subtitle: "The Weeknd · Pop", artworkName: "afterhours", genre: "Pop", duration: 200),
    MockSong(title: "Blinding Lights", subtitle: "The Weeknd · Pop", artworkName: "afterhours", genre: "Pop", duration: 215),
    MockSong(title: "Future Nostalgia", subtitle: "Dua Lipa · Pop", artworkName: "futurenostalgia", genre: "Pop", duration: 203),
    MockSong(title: "Bohemian Rhapsody", subtitle: "Queen · Rock", artworkName: "anightattheopera", genre: "Rock", duration: 355),
    MockSong(title: "Hotel California", subtitle: "Eagles · Rock", artworkName: "hotelcalifornia", genre: "Rock", duration: 391),
    MockSong(title: "Lose Yourself", subtitle: "Eminem · Hip-Hop", artworkName: "8mile", genre: "Hip-Hop", duration: 326),
    MockSong(title: "Stairway to Heaven", subtitle: "Led Zeppelin · Rock", artworkName: "ledzeppeliniv", genre: "Rock", duration: 482),
    MockSong(title: "Shape of You", subtitle: "Ed Sheeran · Pop", artworkName: "divide", genre: "Pop", duration: 234),
    MockSong(title: "Billie Jean", subtitle: "Michael Jackson · Pop", artworkName: "thriller", genre: "Pop", duration: 294),
    MockSong(title: "Bad Guy", subtitle: "Billie Eilish · Pop", artworkName: "whenwefallasleep", genre: "Pop", duration: 194),
]

// MARK: - YouTube-Powered Library

struct SongLibrary {
    private(set) var songs: [Song] = []
    private(set) var albums: [Album] = []
    private(set) var artists: [Artist] = []
    private(set) var playlists: [Playlist] = []

    mutating func loadFromYouTube() async throws {
        let service = YouTubeAudioLibraryService.shared
        if service.tracks.isEmpty {
            try await service.loadLibrary()
        }

        let youtubeTracks = service.tracks
        guard !youtubeTracks.isEmpty else {
            songs = []
            albums = []
            artists = []
            playlists = []
            return
        }

        // Use up to 20 YouTube tracks, supplemented with mock metadata for display
        let displayCount = min(youtubeTracks.count, 20)
        let selected = Array(youtubeTracks.shuffled().prefix(displayCount))

        songs = selected.enumerated().map { (i, yt) in
            let mockIdx = i % mockSongs.count
            let mock = mockSongs[mockIdx]
            return Song(
                title: yt.title,
                artist: extractArtist(from: yt.title) ?? "YouTube Audio Library",
                album: "YouTube Free Library",
                duration: mock.duration,
                trackNumber: i + 1,
                genre: mock.genre,
                artworkName: mock.artworkName,
                youtubeTrackID: yt.id
            )
        }

        albums = [
            Album(
                title: "YouTube Free Library",
                artist: "Various Artists",
                artworkName: "youtube",
                year: Calendar.current.component(.year, from: Date()),
                genre: "Various",
                songs: songs
            )
        ]

        let artistNames = Set(songs.map(\.artist))
        artists = artistNames.map { name in
            let artistSongs = songs.filter { $0.artist == name }
            return Artist(
                name: name,
                genre: artistSongs.first?.genre ?? "Various",
                bio: "\(name) is featured in the YouTube Audio Library.",
                albums: [Album(title: "YouTube Free Library", artist: name, songs: artistSongs)]
            )
        }.sorted { $0.name < $1.name }

        playlists = [
            Playlist(name: "All Tracks", description: "All songs from YouTube Audio Library",
                     songs: Array(songs.shuffled())),
            Playlist(name: "Favorites", description: "Your favorite tracks",
                     songs: songs.filter(\.isFavorite)),
        ]
    }

    private func extractArtist(from title: String) -> String? {
        let keywords = [" by ", " - ", " – ", " ft ", " feat "]
        for kw in keywords {
            if let range = title.range(of: kw, options: .caseInsensitive) {
                return String(title[range.upperBound...]).trimmingCharacters(in: .whitespaces)
            }
        }
        return nil
    }
}

// MARK: - Legacy Static Access (kept for compilation)

enum MockDataService {
    static let shared = MockDataService.Type.self

    static var songs: [Song] { [] }
    static var albums: [Album] { [] }
    static var artists: [Artist] { [] }
    static var playlists: [Playlist] { [] }
}
