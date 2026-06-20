import SwiftUI

struct HomeView: View {
    @Environment(PlayerViewModel.self) private var player

    private var topPicks: [HomeTile] {
        let tracks = YouTubeAudioLibraryService.shared.randomTracks(count: 15)
        let songs = tracks.enumerated().map { (i, yt) in
            Song(title: yt.title, artist: "YouTube Audio Library", album: "YouTube Free Library",
                 duration: 180, trackNumber: i + 1, youtubeTrackID: yt.id)
        }
        return [
            HomeTile(title: "Today's Mix", subtitle: "Curated just for you", color: .red, icon: "music.note", songs: Array(songs.shuffled().prefix(5))),
            HomeTile(title: "Feel Good Hits", subtitle: "Upbeat anthems to lift your mood", color: .orange, icon: "sun.max", songs: Array(songs.shuffled().prefix(5))),
            HomeTile(title: "Late Night Vibes", subtitle: "Chill beats for the evening", color: .purple, icon: "moon.stars", songs: Array(songs.shuffled().prefix(5))),
        ]
    }

    private var recentlyPlayed: [Album] {
        let tracks = YouTubeAudioLibraryService.shared.randomTracks(count: 6)
        let songs = tracks.enumerated().map { (i, yt) in
            Song(title: yt.title, artist: "YouTube Audio Library", album: "YouTube Free Library",
                 duration: 180, trackNumber: i + 1, youtubeTrackID: yt.id)
        }
        return [Album(title: "YouTube Free Library", artist: "Various", songs: songs)]
    }

    private var curatedPlaylists: [CuratedPlaylist] {
        let allTracks = YouTubeAudioLibraryService.shared.tracks
        let songs = allTracks.isEmpty ? [] : allTracks.shuffled().prefix(30).enumerated().map { (i, yt) in
            Song(title: yt.title, artist: "YouTube Audio Library", album: "YouTube Free Library",
                 duration: 180, trackNumber: i + 1, youtubeTrackID: yt.id)
        }
        return [
            CuratedPlaylist(title: "New Music", subtitle: "Fresh releases", color: .blue, icon: "sparkles", songs: Array(songs.shuffled().prefix(5))),
            CuratedPlaylist(title: "Your Essentials", subtitle: "All-time favorites", color: .green, icon: "heart.fill", songs: Array(songs.shuffled().prefix(5))),
            CuratedPlaylist(title: "Chill", subtitle: "Relax and unwind", color: .teal, icon: "leaf", songs: Array(songs.shuffled().prefix(5))),
            CuratedPlaylist(title: "Workout", subtitle: "High energy tracks", color: .orange, icon: "figure.run", songs: Array(songs.shuffled().prefix(5))),
            CuratedPlaylist(title: "Focus", subtitle: "Music for concentration", color: .indigo, icon: "brain", songs: Array(songs.shuffled().prefix(5))),
            CuratedPlaylist(title: "Party", subtitle: "Get the party started", color: .pink, icon: "party.popper", songs: Array(songs.shuffled().prefix(5))),
        ]
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 28) {
                header

                section("Top Picks For You") {
                    topPicksSection
                }

                section("Recently Played") {
                    recentlyPlayedSection
                }

                section("Playlists Made For You") {
                    curatedSection
                }
            }
            .padding(.vertical)
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Home")
                .font(.largeTitle)
                .bold()
            Text("Welcome back")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal)
    }

    private func section<Content: View>(_ title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.title2)
                .bold()
                .padding(.horizontal)
            content()
        }
    }

    private var topPicksSection: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 16) {
                ForEach(topPicks) { pick in
                    TopPickTile(tile: pick)
                        .onTapGesture {
                            if let first = pick.songs.first {
                                player.play(song: first, in: pick.songs)
                            }
                        }
                }
            }
            .padding(.horizontal)
        }
    }

    private var recentlyPlayedSection: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 16) {
                ForEach(recentlyPlayed) { album in
                    RecentlyPlayedTile(album: album)
                        .onTapGesture {
                            if let first = album.songs.first {
                                player.play(song: first, in: album.songs)
                            }
                        }
                }
            }
            .padding(.horizontal)
        }
    }

    private var curatedSection: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 180, maximum: 220), spacing: 16)], spacing: 16) {
            ForEach(curatedPlaylists) { playlist in
                CuratedPlaylistTile(playlist: playlist)
                    .onTapGesture {
                        if let first = playlist.songs.first {
                            player.play(song: first, in: playlist.songs)
                        }
                    }
            }
        }
        .padding(.horizontal)
    }
}

// MARK: - Data Models

private struct HomeTile: Identifiable {
    let id = UUID()
    let title: String
    let subtitle: String
    let color: Color
    let icon: String
    let songs: [Song]
}

private struct CuratedPlaylist: Identifiable {
    let id = UUID()
    let title: String
    let subtitle: String
    let color: Color
    let icon: String
    let songs: [Song]
}

// MARK: - Tile Views

private struct TopPickTile: View {
    let tile: HomeTile

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            RoundedRectangle(cornerRadius: 12)
                .fill(tile.color.gradient)
                .frame(width: 260, height: 160)

            HStack {
                Image(systemName: tile.icon)
                    .font(.title2)
                VStack(alignment: .leading, spacing: 2) {
                    Text(tile.title)
                        .font(.headline)
                        .bold()
                    Text(tile.subtitle)
                        .font(.caption)
                        .lineLimit(2)
                }
            }
            .foregroundStyle(.white)
            .padding(16)
        }
    }
}

private struct RecentlyPlayedTile: View {
    let album: Album

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(.fill.tertiary)
                Image(systemName: "music.note.list")
                    .font(.title)
                    .foregroundStyle(.secondary)
            }
            .frame(width: 150, height: 150)
            .cornerRadius(8)

            Text(album.title)
                .font(.callout)
                .lineLimit(1)
            Text(album.artist)
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(1)
        }
        .frame(width: 150)
    }
}

private struct CuratedPlaylistTile: View {
    let playlist: CuratedPlaylist

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ZStack(alignment: .bottomLeading) {
                RoundedRectangle(cornerRadius: 10)
                    .fill(playlist.color.gradient)
                    .aspectRatio(1, contentMode: .fill)

                VStack(alignment: .leading, spacing: 2) {
                    Image(systemName: playlist.icon)
                        .font(.title3)
                    Text(playlist.title)
                        .font(.headline)
                        .bold()
                    Text(playlist.subtitle)
                        .font(.caption)
                }
                .foregroundStyle(.white)
                .padding(12)
            }
            .cornerRadius(10)
        }
    }
}
