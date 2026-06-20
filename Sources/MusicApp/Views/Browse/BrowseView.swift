import SwiftUI

struct BrowseView: View {
    @Environment(PlayerViewModel.self) private var player

    private var sections: [BrowseSection] {
        let all = YouTubeAudioLibraryService.shared.tracks
        let makeSongs: ([YouTubeTrack]) -> [Song] = { tracks in
            tracks.enumerated().map { (i, yt) in
                Song(title: yt.title, artist: "YouTube Audio Library", album: "YouTube Free Library",
                     duration: 180, trackNumber: i + 1, youtubeTrackID: yt.id)
            }
        }
        return [
            BrowseSection(title: "Hot Hits", subtitle: "The biggest tracks right now",
                          songs: makeSongs(Array(all.shuffled().prefix(6)))),
            BrowseSection(title: "New Releases", subtitle: "Fresh from the library",
                          songs: makeSongs(Array(all.shuffled().prefix(6)))),
            BrowseSection(title: "Made for You", subtitle: "Personalized picks",
                          songs: makeSongs(Array(all.shuffled().prefix(6)))),
        ]
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                Text("Browse")
                    .font(.largeTitle)
                    .bold()
                    .padding(.horizontal)

                ForEach(sections) { section in
                    VStack(alignment: .leading, spacing: 8) {
                        Text(section.title)
                            .font(.title2)
                            .bold()
                            .padding(.horizontal)

                        Text(section.subtitle)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .padding(.horizontal)

                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 16) {
                                ForEach(section.songs) { song in
                                    BrowseSongCell(song: song)
                                        .onTapGesture(count: 2) {
                                            player.play(song: song, in: section.songs)
                                        }
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                }
            }
            .padding(.vertical)
        }
    }
}

struct BrowseSongCell: View {
    let song: Song

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(.fill.tertiary)
                Image(systemName: "music.note")
                    .font(.title)
                    .foregroundStyle(.secondary)
            }
            .frame(width: 140, height: 140)
            .cornerRadius(8)

            Text(song.title)
                .font(.callout)
                .lineLimit(1)

            Text(song.artist)
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(1)
        }
        .frame(width: 140)
    }
}

struct BrowseSection: Identifiable {
    let id = UUID()
    let title: String
    let subtitle: String
    let songs: [Song]
}
