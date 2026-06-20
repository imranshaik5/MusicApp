import SwiftUI

struct NowPlayingView: View {
    @Environment(PlayerViewModel.self) private var player
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 24) {
            HStack {
                Button("Close") {
                    dismiss()
                }
                .buttonStyle(.plain)
                Spacer()
            }
            .padding(.horizontal)

            Spacer()

            artworkPlaceholder
                .frame(width: 300, height: 300)
                .cornerRadius(16)
                .shadow(radius: 8)

            if let song = player.currentSong {
                VStack(spacing: 4) {
                    Text(song.title)
                        .font(.title)
                        .bold()
                    Text(song.artist)
                        .font(.title3)
                        .foregroundStyle(.secondary)
                    Text(song.album)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }

            VStack(spacing: 8) {
                Slider(value: Bindable(player).currentTime, in: 0...max(player.duration, 1)) {
                } onEditingChanged: { editing in
                    if !editing {
                        player.seek(to: player.currentTime)
                    }
                }
                .controlSize(.large)

                HStack {
                    Text(player.formattedCurrentTime)
                        .font(.caption)
                        .monospacedDigit()
                    Spacer()
                    Text(player.formattedDuration)
                        .font(.caption)
                        .monospacedDigit()
                }
            }
            .padding(.horizontal, 60)

            HStack(spacing: 40) {
                Button(action: { player.toggleShuffle() }) {
                    VStack(spacing: 4) {
                        Image(systemName: "shuffle")
                            .font(.title2)
                        Text("Shuffle")
                            .font(.caption2)
                    }
                }
                .foregroundStyle(player.isShuffled ? Color.accentColor : Color.secondary)
                .buttonStyle(.plain)

                Button(action: { player.previousTrack() }) {
                    Image(systemName: "backward.fill")
                        .font(.system(size: 32))
                }
                .buttonStyle(.plain)

                Button(action: { player.playPause() }) {
                    Image(systemName: player.isPlaying ? "pause.circle.fill" : "play.circle.fill")
                        .font(.system(size: 56))
                }
                .buttonStyle(.plain)

                Button(action: { player.nextTrack() }) {
                    Image(systemName: "forward.fill")
                        .font(.system(size: 32))
                }
                .buttonStyle(.plain)

                Button(action: { player.cycleRepeatMode() }) {
                    VStack(spacing: 4) {
                        Image(systemName: "repeat")
                            .font(.title2)
                            .overlay(alignment: .topTrailing) {
                                if player.repeatMode == .one {
                                    Text("1")
                                        .font(.caption2)
                                        .bold()
                                }
                            }
                        Text("Repeat")
                            .font(.caption2)
                    }
                }
                .foregroundStyle(player.repeatMode != .none ? Color.accentColor : Color.secondary)
                .buttonStyle(.plain)
            }

            HStack {
                Image(systemName: "speaker.fill")
                    .font(.caption)
                Slider(value: Bindable(player).volume, in: 0...1) {
                } onEditingChanged: { _ in
                    player.setVolume(player.volume)
                }
                .frame(width: 120)
                Image(systemName: "speaker.wave.3.fill")
                    .font(.caption)
            }
            .foregroundStyle(.secondary)

            Spacer()
        }
        .frame(width: 500, height: 650)
        .background(.regularMaterial)
    }

    private var artworkPlaceholder: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16)
                .fill(.fill.tertiary)
            Image(systemName: "music.note")
                .font(.system(size: 80))
                .foregroundStyle(.secondary)
        }
    }
}
