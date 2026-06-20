import SwiftUI

struct NowPlayingBar: View {
    @Environment(PlayerViewModel.self) private var player
    @Binding var showNowPlaying: Bool

    var body: some View {
        VStack(spacing: 0) {
            Divider()
            HStack(spacing: 12) {
                if let song = player.currentSong {
                    artworkPlaceholder
                        .frame(width: 48, height: 48)
                        .cornerRadius(6)

                    VStack(alignment: .leading, spacing: 2) {
                        Text(song.title)
                            .font(.body)
                            .lineLimit(1)
                        Text(song.artist)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                    }

                    Spacer()

                    HStack(spacing: 20) {
                        Button(action: { player.previousTrack() }) {
                            Image(systemName: "backward.fill")
                                .font(.title3)
                        }
                        .buttonStyle(.plain)

                        Button(action: { player.playPause() }) {
                            Image(systemName: player.isPlaying ? "pause.fill" : "play.fill")
                                .font(.title2)
                        }
                        .buttonStyle(.plain)

                        Button(action: { player.nextTrack() }) {
                            Image(systemName: "forward.fill")
                                .font(.title3)
                        }
                        .buttonStyle(.plain)
                    }

                    Spacer()

                    Text(player.formattedCurrentTime)
                        .font(.caption)
                        .monospacedDigit()
                        .foregroundStyle(.secondary)

                    Slider(value: Bindable(player).currentTime, in: 0...max(player.duration, 1)) {
                    } onEditingChanged: { editing in
                        if !editing {
                            player.seek(to: player.currentTime)
                        }
                    }
                    .frame(width: 120)
                    .controlSize(.small)

                    Text(player.formattedDuration)
                        .font(.caption)
                        .monospacedDigit()
                        .foregroundStyle(.secondary)

                    HStack(spacing: 12) {
                        Button(action: { player.toggleShuffle() }) {
                            Image(systemName: "shuffle")
                                    .foregroundStyle(player.isShuffled ? Color.accentColor : Color.secondary)
                        }
                        .buttonStyle(.plain)

                        Button(action: { player.cycleRepeatMode() }) {
                            Image(systemName: repeatIcon)
                                    .foregroundStyle(player.repeatMode != .none ? Color.accentColor : Color.secondary)
                        }
                        .buttonStyle(.plain)

                        Button(action: { showNowPlaying = true }) {
                            Image(systemName: "music.note")
                                .font(.title3)
                        }
                        .buttonStyle(.plain)
                    }
                } else {
                    Text("No music playing")
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .frame(height: 64)
            .background(.bar)
        }
    }

    private var repeatIcon: String {
        switch player.repeatMode {
        case .none: "repeat"
        case .all: "repeat"
        case .one: "repeat.1"
        }
    }

    private var artworkPlaceholder: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 6)
                .fill(.fill.tertiary)
            Image(systemName: "music.note")
                .foregroundStyle(.secondary)
        }
    }
}
