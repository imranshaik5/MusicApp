# MusicApp

A native macOS Apple Music clone built with SwiftUI and MVVM architecture. Streams real audio from the YouTube Free Audio Library (5,000+ royalty-free tracks).

## Features

- **Library** — Browse songs, albums, artists, and playlists
- **Home** — Curated sections: Top Picks, Recently Played, Playlists Made For You
- **Browse** — Horizontally scrolling genre sections
- **Radio** — Curated station tiles
- **Search** — Full-text search across songs, albums, and artists with recent searches
- **Now Playing** — Persistent mini-player bar + full player sheet with seek, volume, shuffle, repeat
- **Queue** — Undo/redo, shuffle (preserves original order), forward skip stack, duplicate removal
- **Playback Persistence** — Saves queue, position, and settings to UserDefaults

## Architecture

```
Sources/MusicApp/
├── App/              # App entry point
├── Models/           # Song, Album, Artist, Playlist
├── Services/         # AudioPlayerService, YouTubeAudioLibraryService
├── ViewModels/       # LibraryViewModel, PlayerViewModel, SearchViewModel
└── Views/            # ContentView, HomeView, Library, Player, Browse, Radio, Search
```

- **MVVM** with `@Observable` (macOS 14+)
- **AVPlayer** for audio playback
- **YouTube Free Audio Library** as the music source (Google Drive MP3 streaming)
- **Protocol-based** audio player service for testability

## Requirements

- macOS 14+
- Xcode 15+
- Internet connection (streams audio from Google Drive)

## Build & Run

```bash
git clone https://github.com/imranshaik5/MusicApp.git
cd MusicApp
open MusicApp.xcodeproj
# Build and run from Xcode
```

Or via SwiftPM:

```bash
swift run
```

## Credits

- Audio library data from [YouTube-Free-Audio-Library-API](https://github.com/ThibaultJanBeyer/YouTube-Free-Audio-Library-API)
