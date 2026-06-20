import Foundation
import Observation

@Observable
final class LibraryViewModel {
    private(set) var songs: [Song] = []
    private(set) var albums: [Album] = []
    private(set) var artists: [Artist] = []
    private(set) var playlists: [Playlist] = []
    private var songLibrary = SongLibrary()
    var selectedCategory: LibraryCategory = .songs
    var searchQuery = ""
    var sortOrder: SortOrder = .title
    private(set) var isLoading = true

    enum LibraryCategory: Hashable {
        case songs
        case albums
        case artists
        case playlists
        case recentlyAdded
    }

    enum SortOrder: String, CaseIterable {
        case title = "Title"
        case artist = "Artist"
        case recentlyAdded = "Recently Added"
    }

    var filteredSongs: [Song] {
        let result = searchQuery.isEmpty ? songs : songs.filter {
            $0.title.localizedCaseInsensitiveContains(searchQuery)
            || $0.artist.localizedCaseInsensitiveContains(searchQuery)
            || $0.album.localizedCaseInsensitiveContains(searchQuery)
        }
        return sort(songs: result)
    }

    var filteredAlbums: [Album] {
        let result = searchQuery.isEmpty ? albums : albums.filter {
            $0.title.localizedCaseInsensitiveContains(searchQuery)
            || $0.artist.localizedCaseInsensitiveContains(searchQuery)
        }
        return result.sorted { $0.title < $1.title }
    }

    var filteredArtists: [Artist] {
        let result = searchQuery.isEmpty ? artists : artists.filter {
            $0.name.localizedCaseInsensitiveContains(searchQuery)
        }
        return result.sorted { $0.name < $1.name }
    }

    var filteredPlaylists: [Playlist] {
        let result = searchQuery.isEmpty ? playlists : playlists.filter {
            $0.name.localizedCaseInsensitiveContains(searchQuery)
        }
        return result.sorted { $0.name < $1.name }
    }

    func loadLibrary() async {
        isLoading = true
        try? await songLibrary.loadFromYouTube()
        songs = songLibrary.songs
        albums = songLibrary.albums
        artists = songLibrary.artists
        playlists = songLibrary.playlists
        isLoading = false
    }

    func toggleFavorite(song: Song) {
        guard let index = songs.firstIndex(where: { $0.id == song.id }) else { return }
        songs[index].isFavorite.toggle()
    }

    func deleteSongs(at offsets: IndexSet) {
        songs.remove(atOffsets: offsets)
    }

    func createPlaylist(name: String, description: String = "") {
        let playlist = Playlist(name: name, description: description)
        playlists.append(playlist)
    }

    func addSongToPlaylist(song: Song, playlist: Playlist) {
        guard let index = playlists.firstIndex(where: { $0.id == playlist.id }) else { return }
        playlists[index].songs.append(song)
    }

    func removeSongFromPlaylist(song: Song, playlist: Playlist) {
        guard let index = playlists.firstIndex(where: { $0.id == playlist.id }) else { return }
        playlists[index].songs.removeAll { $0.id == song.id }
    }

    func deletePlaylist(at offsets: IndexSet) {
        playlists.remove(atOffsets: offsets)
    }

    private func sort(songs: [Song]) -> [Song] {
        switch sortOrder {
        case .title:
            return songs.sorted { $0.title < $1.title }
        case .artist:
            return songs.sorted { $0.artist < $1.artist }
        case .recentlyAdded:
            return songs
        }
    }
}
