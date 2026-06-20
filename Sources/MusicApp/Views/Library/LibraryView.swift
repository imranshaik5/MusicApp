import SwiftUI

struct LibraryView: View {
    @Environment(LibraryViewModel.self) private var vm

    var body: some View {
        VStack(spacing: 0) {
            header
            content
        }
    }

    private var header: some View {
        HStack {
            Text(categoryTitle)
                .font(.largeTitle)
                .bold()
            Spacer()
            if vm.selectedCategory == .playlists {
                Button(action: { vm.createPlaylist(name: "New Playlist") }) {
                    Image(systemName: "plus")
                }
            }
        }
        .padding()
    }

    private var categoryTitle: String {
        switch vm.selectedCategory {
        case .songs: "Songs"
        case .albums: "Albums"
        case .artists: "Artists"
        case .playlists: "Playlists"
        case .recentlyAdded: "Recently Added"
        }
    }

    @ViewBuilder
    private var content: some View {
        switch vm.selectedCategory {
        case .songs: SongListView()
        case .albums: AlbumListView()
        case .artists: ArtistListView()
        case .playlists: PlaylistListView()
        case .recentlyAdded: SongListView()
        }
    }
}
