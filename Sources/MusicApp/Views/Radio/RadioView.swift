import SwiftUI

struct RadioView: View {
    let stations: [RadioStation] = [
        RadioStation(name: "Pop Hits", description: "The biggest pop songs", imageName: "pop"),
        RadioStation(name: "Rock Classics", description: "Legendary rock anthems", imageName: "rock"),
        RadioStation(name: "Hip-Hop Flow", description: "Best hip-hop tracks", imageName: "hiphop"),
        RadioStation(name: "Chill Vibes", description: "Relax and unwind", imageName: "chill"),
        RadioStation(name: "Workout Energy", description: "High energy workout mix", imageName: "workout"),
        RadioStation(name: "90s Throwback", description: "Best of the 90s", imageName: "nineties"),
    ]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                Text("Radio")
                    .font(.largeTitle)
                    .bold()
                    .padding(.horizontal)

                Text("Listen to curated stations")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal)

                LazyVGrid(columns: [GridItem(.adaptive(minimum: 160, maximum: 200), spacing: 16)], spacing: 16) {
                    ForEach(stations) { station in
                        RadioStationCell(station: station)
                    }
                }
                .padding(.horizontal)
            }
            .padding(.vertical)
        }
    }
}

struct RadioStation: Identifiable {
    let id = UUID()
    let name: String
    let description: String
    let imageName: String
}

struct RadioStationCell: View {
    let station: RadioStation

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(.fill.tertiary)
                Image(systemName: "dot.radiowaves.left.and.right")
                    .font(.title)
                    .foregroundStyle(.secondary)
            }
            .aspectRatio(1, contentMode: .fill)
            .cornerRadius(8)
            .overlay(alignment: .bottomLeading) {
                Text("Radio")
                    .font(.caption2)
                    .bold()
                    .padding(4)
                    .background(.ultraThinMaterial)
                    .cornerRadius(4)
                    .padding(8)
            }

            Text(station.name)
                .font(.callout)
                .lineLimit(1)

            Text(station.description)
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity)
    }
}
