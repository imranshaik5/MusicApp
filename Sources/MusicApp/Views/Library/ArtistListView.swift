import SwiftUI

struct ArtistListView: View {
    @Environment(LibraryViewModel.self) private var vm
    @Environment(PlayerViewModel.self) private var player
    @State private var selectedArtist: Artist?
    @State private var showArtistDetail = false

    var body: some View {
        ScrollView {
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 160, maximum: 200), spacing: 16)], spacing: 20) {
                ForEach(vm.filteredArtists) { artist in
                    ArtistCell(artist: artist)
                        .onTapGesture {
                            selectedArtist = artist
                            showArtistDetail = true
                        }
                }
            }
            .padding()
        }
        .searchable(text: Bindable(vm).searchQuery, placement: .sidebar)
        .sheet(isPresented: $showArtistDetail) {
            if let artist = selectedArtist {
                ArtistDetailView(artist: artist)
            }
        }
    }
}

struct ArtistCell: View {
    let artist: Artist

    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(.fill.tertiary)
                Image(systemName: "person.fill")
                    .font(.title)
                    .foregroundStyle(.secondary)
            }
            .frame(width: 120, height: 120)

            Text(artist.name)
                .font(.callout)
                .lineLimit(1)
                .fontWeight(.medium)

            Text(artist.genre)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

struct ArtistDetailView: View {
    let artist: Artist
    @Environment(PlayerViewModel.self) private var player
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                HStack(spacing: 20) {
                    ZStack {
                        Circle()
                            .fill(.fill.tertiary)
                        Image(systemName: "person.fill")
                            .font(.system(size: 60))
                            .foregroundStyle(.secondary)
                    }
                    .frame(width: 150, height: 150)

                    VStack(alignment: .leading, spacing: 8) {
                        Text(artist.name)
                            .font(.largeTitle)
                            .bold()
                        Text(artist.genre)
                            .font(.title3)
                            .foregroundStyle(.secondary)
                        Text("\(artist.albums.count) albums")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding()

                VStack(alignment: .leading, spacing: 12) {
                    Text("Albums")
                        .font(.title2)
                        .bold()
                        .padding(.horizontal)

                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 160))], spacing: 16) {
                        ForEach(artist.albums) { album in
                            AlbumCell(album: album)
                                .onTapGesture {
                                    if let first = album.songs.first {
                                        player.play(song: first, in: album.songs)
                                        dismiss()
                                    }
                                }
                        }
                    }
                    .padding(.horizontal)
                }
            }
        }
        .frame(width: 700, height: 500)
    }
}
