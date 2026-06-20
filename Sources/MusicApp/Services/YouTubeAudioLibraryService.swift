import Foundation

// MARK: - Response Models

struct AudioLibraryResponse: Codable {
    let arr: [String]
    let map: [String: String]
    let count: Int
    let all: [YouTubeTrack]
}

struct YouTubeTrack: Codable, Identifiable {
    let kind: String
    let id: String
    let name: String
    let mimeType: String

    var title: String {
        String(name.dropLast(4)).replacingOccurrences(of: "_", with: " ")
    }

    var streamURL: URL? {
        URL(string: "https://drive.usercontent.google.com/download?id=\(id)&export=open")
    }
}

// MARK: - Service

final class YouTubeAudioLibraryService {
    static let shared = YouTubeAudioLibraryService()

    private static let apiURL = URL(
        string: "https://thibaultjanbeyer.github.io/YouTube-Free-Audio-Library-API/api.json"
    )!

    private var cachedTracks: [YouTubeTrack]?
    private var cache: [String: YouTubeTrack] = [:] // fileID -> track
    private var isLoading = false

    private init() {}

    var tracks: [YouTubeTrack] {
        cachedTracks ?? []
    }

    var songs: [Song] {
        tracks.enumerated().map { (i, yt) in
            Song(
                title: yt.title,
                artist: "YouTube Audio Library",
                album: "YouTube Free Library",
                duration: 180,
                trackNumber: i + 1,
                genre: "Various",
                youtubeTrackID: yt.id
            )
        }
    }

    func song(withID id: UUID) -> Song? {
        songs.first { $0.id == id }
    }

    func loadLibrary() async throws -> [YouTubeTrack] {
        if let tracks = cachedTracks { return tracks }
        isLoading = true
        defer { isLoading = false }

        let (data, _) = try await URLSession.shared.data(from: Self.apiURL)
        let response = try JSONDecoder().decode(AudioLibraryResponse.self, from: data)
        cachedTracks = response.all
        for track in response.all {
            cache[track.id] = track
        }
        return response.all
    }

    func search(query: String) -> [YouTubeTrack] {
        let q = query.lowercased()
        return tracks.filter { $0.title.lowercased().contains(q) }
    }

    func track(named name: String) -> YouTubeTrack? {
        let q = name.lowercased()
        return tracks.first { $0.title.lowercased() == q }
            ?? tracks.first { $0.title.lowercased().contains(q) }
    }

    func randomTracks(count: Int) -> [YouTubeTrack] {
        tracks.shuffled().prefix(count).map { $0 }
    }
}
