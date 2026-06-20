import SwiftUI

struct SearchView: View {
    @Environment(SearchViewModel.self) private var vm
    @Environment(PlayerViewModel.self) private var player
    @Environment(LibraryViewModel.self) private var library
    @State private var showClearAlert = false

    var body: some View {
        VStack(spacing: 0) {
            searchField
                .padding()

            if vm.searchQuery.isEmpty {
                recentSearches
            } else if let results = vm.searchResults {
                searchResults(results)
            } else {
                emptyState
            }
        }
    }

    private var searchField: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(.secondary)
            TextField("Search songs, albums, artists...", text: Bindable(vm).searchQuery)
                .textFieldStyle(.plain)
                .font(.title3)
                .onSubmit { vm.performSearch(in: library) }
        }
        .padding(12)
        .background(.fill.quaternary)
        .cornerRadius(12)
    }

    private var recentSearches: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Recent Searches")
                    .font(.title2)
                    .bold()
                Spacer()
                if !vm.recentSearches.isEmpty {
                    Button("Clear All") {
                        showClearAlert = true
                    }
                    .buttonStyle(.plain)
                    .foregroundStyle(Color.accentColor)
                }
            }
            .padding(.horizontal)

            if vm.recentSearches.isEmpty {
                Spacer()
                ContentUnavailableView(
                    "No Recent Searches",
                    systemImage: "magnifyingglass",
                    description: Text("Search for your favorite music")
                )
                Spacer()
            } else {
                List {
                    ForEach(vm.recentSearches, id: \.self) { search in
                        HStack {
                            Image(systemName: "clock")
                                .foregroundStyle(.secondary)
                            Text(search)
                            Spacer()
                            Button(action: { vm.removeRecentSearch(search) }) {
                                Image(systemName: "xmark")
                                    .font(.caption)
                            }
                            .buttonStyle(.plain)
                            .foregroundStyle(.secondary)
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            vm.searchQuery = search
                            vm.performSearch(in: library)
                        }
                    }
                }
                .listStyle(.plain)
            }
        }
        .alert("Clear All Recent Searches?", isPresented: $showClearAlert) {
            Button("Clear", role: .destructive) { vm.clearRecentSearches() }
            Button("Cancel", role: .cancel) {}
        }
    }

    private func searchResults(_ results: SearchViewModel.SearchResults) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                if !results.songs.isEmpty {
                    section("Songs", results.songs)
                }
                if !results.albums.isEmpty {
                    albumsSection(results.albums)
                }
                if !results.artists.isEmpty {
                    artistsSection(results.artists)
                }
            }
            .padding()
        }
    }

    private func section(_ title: String, _ songs: [Song]) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.title2)
                .bold()
            ForEach(songs.prefix(5)) { song in
                SongRow(song: song)
                    .onTapGesture(count: 2) {
                        player.play(song: song, in: songs)
                    }
                    .contextMenu {
                        Button(song.isFavorite ? "Unfavorite" : "Favorite") {
                            library.toggleFavorite(song: song)
                        }
                    }
            }
        }
    }

    private func albumsSection(_ albums: [Album]) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Albums")
                .font(.title2)
                .bold()
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(albums.prefix(6)) { album in
                        AlbumCell(album: album)
                            .frame(width: 140)
                    }
                }
            }
        }
    }

    private func artistsSection(_ artists: [Artist]) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Artists")
                .font(.title2)
                .bold()
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(artists.prefix(6)) { artist in
                        ArtistCell(artist: artist)
                            .frame(width: 120)
                    }
                }
            }
        }
    }

    private var emptyState: some View {
        Spacer()
    }
}
