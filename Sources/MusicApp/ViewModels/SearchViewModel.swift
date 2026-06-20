import Foundation
import Observation

@Observable
final class SearchViewModel {
    var searchQuery = ""
    private(set) var recentSearches: [String] = []

    struct SearchResults {
        let songs: [Song]
        let albums: [Album]
        let artists: [Artist]
    }

    private(set) var searchResults: SearchResults?

    func performSearch(in library: LibraryViewModel) {
        guard !searchQuery.isEmpty else {
            searchResults = nil
            return
        }

        let query = searchQuery.lowercased()

        let matchedSongs = library.filteredSongs.filter {
            $0.title.lowercased().contains(query)
            || $0.artist.lowercased().contains(query)
            || $0.album.lowercased().contains(query)
        }

        let matchedAlbums = library.albums.filter {
            $0.title.lowercased().contains(query)
            || $0.artist.lowercased().contains(query)
        }

        let matchedArtists = library.artists.filter {
            $0.name.lowercased().contains(query)
        }

        searchResults = SearchResults(
            songs: matchedSongs,
            albums: matchedAlbums,
            artists: matchedArtists
        )

        if !recentSearches.contains(searchQuery) {
            recentSearches.insert(searchQuery, at: 0)
            if recentSearches.count > 10 {
                recentSearches = Array(recentSearches.prefix(10))
            }
        }
    }

    func clearRecentSearches() {
        recentSearches.removeAll()
    }

    func removeRecentSearch(_ search: String) {
        recentSearches.removeAll { $0 == search }
    }
}
