import SwiftUI

struct SongListView: View {
    @Environment(LibraryViewModel.self) private var vm
    @Environment(PlayerViewModel.self) private var player

    var body: some View {
        VStack {
            HStack {
                Spacer()
                sortPicker
            }
            .padding(.horizontal)

            List {
                ForEach(vm.filteredSongs) { song in
                    SongRow(song: song)
                        .onTapGesture(count: 2) {
                            player.play(song: song, in: vm.filteredSongs)
                        }
                        .contextMenu {
                            Button(song.isFavorite ? "Unfavorite" : "Favorite") {
                                vm.toggleFavorite(song: song)
                            }
                            Button("Play Next") {
                                // queue management
                            }
                            Button("Add to Playlist") {
                                // show playlist picker
                            }
                            Divider()
                            Button("Delete", role: .destructive) {
                                if let idx = vm.songs.firstIndex(of: song) {
                                    vm.deleteSongs(at: IndexSet(integer: idx))
                                }
                            }
                        }
                }
                .onDelete { offsets in
                    let mapped = offsets.map { vm.filteredSongs[$0] }
                        .compactMap { song in vm.songs.firstIndex(of: song) }
                    vm.deleteSongs(at: IndexSet(mapped))
                }
            }
            .listStyle(.plain)
            .searchable(text: Bindable(vm).searchQuery, placement: .sidebar)
        }
    }

    private var sortPicker: some View {
        Picker("Sort", selection: Bindable(vm).sortOrder) {
            ForEach(LibraryViewModel.SortOrder.allCases, id: \.self) { order in
                Text(order.rawValue).tag(order)
            }
        }
        .pickerStyle(.menu)
        .frame(width: 150)
    }
}

struct SongRow: View {
    let song: Song

    var body: some View {
        HStack(spacing: 12) {
            artworkPlaceholder
                .frame(width: 40, height: 40)
                .cornerRadius(4)

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

            if song.isFavorite {
                Image(systemName: "heart.fill")
                    .font(.caption)
                    .foregroundStyle(.red)
            }

            Text(formattedDuration(song.duration))
                .font(.caption)
                .foregroundStyle(.secondary)
                .monospacedDigit()
        }
        .padding(.vertical, 4)
        .contentShape(Rectangle())
    }

    private func formattedDuration(_ time: TimeInterval) -> String {
        let m = Int(time) / 60
        let s = Int(time) % 60
        return "\(m):\(String(format: "%02d", s))"
    }

    private var artworkPlaceholder: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 4)
                .fill(.fill.tertiary)
            Image(systemName: "music.note")
                .foregroundStyle(.secondary)
        }
    }
}
