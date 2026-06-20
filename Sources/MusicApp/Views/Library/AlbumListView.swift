import SwiftUI

struct AlbumListView: View {
    @Environment(LibraryViewModel.self) private var vm
    @Environment(PlayerViewModel.self) private var player
    @State private var selectedAlbum: Album?
    @State private var showAlbumDetail = false

    var body: some View {
        ScrollView {
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 180, maximum: 220), spacing: 16)], spacing: 16) {
                ForEach(vm.filteredAlbums) { album in
                    AlbumCell(album: album)
                        .onTapGesture {
                            selectedAlbum = album
                            showAlbumDetail = true
                        }
                        .contextMenu {
                            Button("Play") {
                                if let first = album.songs.first {
                                    player.play(song: first, in: album.songs)
                                }
                            }
                        }
                }
            }
            .padding()
        }
        .searchable(text: Bindable(vm).searchQuery, placement: .sidebar)
        .sheet(isPresented: $showAlbumDetail) {
            if let album = selectedAlbum {
                AlbumDetailView(album: album)
            }
        }
    }
}

struct AlbumCell: View {
    let album: Album

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            artworkPlaceholder
                .aspectRatio(1, contentMode: .fill)
                .cornerRadius(8)

            Text(album.title)
                .font(.callout)
                .lineLimit(1)

            Text(album.artist)
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity)
    }

    private var artworkPlaceholder: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8)
                .fill(.fill.tertiary)
            Image(systemName: "music.note.list")
                .font(.title)
                .foregroundStyle(.secondary)
        }
    }
}

struct AlbumDetailView: View {
    let album: Album
    @Environment(PlayerViewModel.self) private var player
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 20) {
                artworkPlaceholder
                    .frame(width: 200, height: 200)
                    .cornerRadius(12)

                VStack(alignment: .leading, spacing: 8) {
                    Text(album.title)
                        .font(.largeTitle)
                        .bold()
                    Text(album.artist)
                        .font(.title2)
                        .foregroundStyle(.secondary)
                    Text("\(album.year) · \(album.genre)")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    Text("\(album.trackCount) songs")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    HStack(spacing: 16) {
                        Button("Play") {
                            if let first = album.songs.first {
                                player.play(song: first, in: album.songs)
                                dismiss()
                            }
                        }
                        .buttonStyle(.borderedProminent)

                        Button("Shuffle") {
                            if let first = album.songs.first {
                                player.play(song: first, in: album.songs.shuffled())
                                dismiss()
                            }
                        }
                        .buttonStyle(.bordered)
                    }
                    .padding(.top, 8)
                }
            }
            .padding()

            List(album.songs) { song in
                SongRow(song: song)
                    .onTapGesture(count: 2) {
                        player.play(song: song, in: album.songs)
                        dismiss()
                    }
            }
            .listStyle(.plain)
        }
        .frame(width: 600, height: 500)
    }

    private var artworkPlaceholder: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12)
                .fill(.fill.tertiary)
            Image(systemName: "music.note.list")
                .font(.system(size: 60))
                .foregroundStyle(.secondary)
        }
    }
}
