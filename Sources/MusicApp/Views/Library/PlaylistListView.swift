import SwiftUI

struct PlaylistListView: View {
    @Environment(LibraryViewModel.self) private var vm
    @State private var selectedPlaylist: Playlist?
    @State private var showPlaylistDetail = false

    var body: some View {
        ScrollView {
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 180, maximum: 220), spacing: 16)], spacing: 16) {
                ForEach(vm.filteredPlaylists) { playlist in
                    PlaylistCell(playlist: playlist)
                        .onTapGesture {
                            selectedPlaylist = playlist
                            showPlaylistDetail = true
                        }
                        .contextMenu {
                            Button("Delete", role: .destructive) {
                                if let idx = vm.playlists.firstIndex(of: playlist) {
                                    vm.deletePlaylist(at: IndexSet(integer: idx))
                                }
                            }
                        }
                }
            }
            .padding()
        }
        .searchable(text: Bindable(vm).searchQuery, placement: .sidebar)
        .sheet(isPresented: $showPlaylistDetail) {
            if let playlist = selectedPlaylist {
                PlaylistDetailView(playlist: playlist)
            }
        }
    }
}

struct PlaylistCell: View {
    let playlist: Playlist

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(.fill.tertiary)
                Image(systemName: "music.note.list")
                    .font(.title)
                    .foregroundStyle(.secondary)
            }
            .aspectRatio(1, contentMode: .fill)
            .cornerRadius(8)

            Text(playlist.name)
                .font(.callout)
                .lineLimit(1)

            Text("\(playlist.songs.count) songs")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

struct PlaylistDetailView: View {
    let playlist: Playlist
    @Environment(PlayerViewModel.self) private var player
    @Environment(LibraryViewModel.self) private var library
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 20) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(.fill.tertiary)
                    Image(systemName: "music.note.list")
                        .font(.system(size: 60))
                        .foregroundStyle(.secondary)
                }
                .frame(width: 180, height: 180)
                .cornerRadius(12)

                VStack(alignment: .leading, spacing: 8) {
                    Text(playlist.name)
                        .font(.largeTitle)
                        .bold()
                    if !playlist.description.isEmpty {
                        Text(playlist.description)
                            .foregroundStyle(.secondary)
                    }
                    Text("\(playlist.songs.count) songs")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    HStack(spacing: 16) {
                        Button("Play") {
                            if let first = playlist.songs.first {
                                player.play(song: first, in: playlist.songs)
                                dismiss()
                            }
                        }
                        .buttonStyle(.borderedProminent)

                        Button("Shuffle") {
                            if let first = playlist.songs.first {
                                player.play(song: first, in: playlist.songs.shuffled())
                                dismiss()
                            }
                        }
                        .buttonStyle(.bordered)
                    }
                }
            }
            .padding()

            if playlist.songs.isEmpty {
                ContentUnavailableView(
                    "No Songs",
                    systemImage: "music.note",
                    description: Text("Add songs to this playlist")
                )
            } else {
                List(playlist.songs) { song in
                    SongRow(song: song)
                        .onTapGesture(count: 2) {
                            player.play(song: song, in: playlist.songs)
                            dismiss()
                        }
                }
                .listStyle(.plain)
            }
        }
        .frame(width: 600, height: 450)
    }
}
