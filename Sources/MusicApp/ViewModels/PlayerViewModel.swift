import Foundation
import Observation
import AVFoundation

@Observable
final class PlayerViewModel: NSObject {
    private let playerService: AudioPlayerServiceProtocol

    // MARK: - Playback State

    private(set) var currentSong: Song?
    private(set) var isPlaying = false
    var currentTime: TimeInterval = 0
    private(set) var duration: TimeInterval = 0
    var volume: Float = 0.8
    var isShuffled = false
    var repeatMode: RepeatMode = .none

    enum RepeatMode: String, Codable { case none, one, all }

    // MARK: - Queue

    private(set) var queue: [Song] = []
    private(set) var queueIndex: Int = 0
    private var queueOrderBeforeShuffle: [Song] = []
    private var forwardSkipStack: [Int] = []

    private struct QueueState {
        let trackIDs: [String] // YouTube track IDs
        let currentIndex: Int
    }

    private var undoStack: [QueueState] = []
    private var redoStack: [QueueState] = []
    private let maxUndoHistory = 10

    // MARK: - Persistence

    private struct PersistedSession: Codable {
        let queueTrackIDs: [String]
        let queueIndex: Int
        let currentTime: TimeInterval
        let isShuffled: Bool
        let repeatModeRaw: String
        let volume: Float
    }

    private static let persistenceKey = "com.musicapp.playbackSession"

    // MARK: - Skip Coalescing

    private var pendingSeek: TimeInterval?
    private var seekWorkItem: DispatchWorkItem?
    private let seekCoalescingInterval: TimeInterval = 0.15

    // MARK: - Init

    init(playerService: AudioPlayerServiceProtocol = AudioPlayerService()) {
        self.playerService = playerService
        super.init()
        setupPlayerCallbacks()
    }

    deinit {
        saveSession()
    }

    private func setupPlayerCallbacks() {
        playerService.onTimeUpdate = { [weak self] time in
            self?.currentTime = time
        }
        playerService.onDurationUpdate = { [weak self] duration in
            self?.duration = duration
        }
        playerService.onPlaybackEnd = { [weak self] in
            self?.handlePlaybackEnd()
        }
    }

    // MARK: - Playback Control

    func play(song: Song, in newQueue: [Song]) {
        pushQueueState()
        forwardSkipStack.removeAll()
        redoStack.removeAll()

        queue = deduplicated(newQueue)
        queueIndex = queue.firstIndex(of: song) ?? 0
        queueOrderBeforeShuffle = queue
        currentSong = song
        isPlaying = true
        duration = song.duration

        Task {
            let url = await resolveStreamURL(for: song)
            await playerService.play(url: url)
        }
    }

    private func resolveStreamURL(for song: Song) async -> URL {
        if let url = song.streamURL { return url }

        let service = YouTubeAudioLibraryService.shared
        if service.tracks.isEmpty {
            _ = try? await service.loadLibrary()
        }
        if let match = service.track(named: song.title),
           let url = match.streamURL {
            return url
        }

        return Bundle.main.url(forResource: song.artworkName, withExtension: "mp3")
            ?? URL(string: "https://example.com/mock.mp3")!
    }

    func playPause() {
        guard currentSong != nil else { return }
        playerService.togglePlayPause()
        isPlaying = playerService.isPlaying
    }

    func nextTrack() {
        guard !queue.isEmpty else { return }
        pushQueueState()

        let currentQueue = effectiveQueue()

        switch repeatMode {
        case .one:
            seek(to: 0, coalesce: false)
            playerService.resume()
            isPlaying = true
            return
        case .all where queueIndex >= currentQueue.count - 1:
            queueIndex = 0
        case .none where queueIndex >= currentQueue.count - 1:
            pause()
            return
        default:
            forwardSkipStack.append(queueIndex)
            queueIndex += 1
        }

        playCurrentFromQueue(currentQueue)
    }

    func previousTrack() {
        guard !queue.isEmpty else { return }

        if currentTime > 3 {
            seek(to: 0, coalesce: false)
            return
        }

        pushQueueState()

        if let prevIndex = forwardSkipStack.popLast() {
            queueIndex = prevIndex
            playCurrentFromQueue(effectiveQueue())
            return
        }

        let currentQueue = effectiveQueue()
        queueIndex = max(0, queueIndex - 1)
        playCurrentFromQueue(currentQueue)
    }

    func seek(to time: TimeInterval, coalesce: Bool = true) {
        guard coalesce else {
            playerService.seek(to: time)
            currentTime = time
            return
        }

        pendingSeek = time
        seekWorkItem?.cancel()
        let workItem = DispatchWorkItem { [weak self] in
            guard let self, let seekTime = pendingSeek else { return }
            playerService.seek(to: seekTime)
            currentTime = seekTime
            pendingSeek = nil
        }
        seekWorkItem = workItem
        DispatchQueue.main.asyncAfter(deadline: .now() + seekCoalescingInterval, execute: workItem)
    }

    func pause() {
        playerService.pause()
        isPlaying = false
    }

    func resume() {
        guard currentSong != nil else { return }
        playerService.resume()
        isPlaying = true
    }

    func setVolume(_ volume: Float) {
        self.volume = volume
        playerService.volume = volume
    }

    func toggleShuffle() {
        isShuffled.toggle()

        if isShuffled {
            guard queue.count > 1 else { return }
            queueOrderBeforeShuffle = queue
            var shuffled = queue
            let current = shuffled.remove(at: queueIndex)
            shuffled.shuffle()
            shuffled.insert(current, at: 0)
            queue = shuffled
            queueIndex = 0
        } else {
            guard !queueOrderBeforeShuffle.isEmpty else { return }
            let current = currentSong
            queue = queueOrderBeforeShuffle
            queueOrderBeforeShuffle.removeAll()
            queueIndex = queue.firstIndex(of: current ?? queue[0]) ?? 0
        }
    }

    func cycleRepeatMode() {
        switch repeatMode {
        case .none: repeatMode = .all
        case .all: repeatMode = .one
        case .one: repeatMode = .none
        }
    }

    private func effectiveQueue() -> [Song] { queue }

    private func playCurrentFromQueue(_ currentQueue: [Song]) {
        guard queue.indices.contains(queueIndex) else { return }
        let song = queue[queueIndex]

        if isShuffled {
            var shuffledQueue = queue
            if shuffledQueue[queueIndex] != song {
                shuffledQueue[queueIndex] = song
            }
            play(song: song, in: shuffledQueue)
        } else {
            play(song: song, in: queueOrderBeforeShuffle.isEmpty ? queue : queueOrderBeforeShuffle)
        }
    }

    private func handlePlaybackEnd() {
        nextTrack()
    }

    // MARK: - Queue Management

    func insertNextInQueue(_ song: Song) {
        pushQueueState()
        redoStack.removeAll()
        let insertIndex = min(queueIndex + 1, queue.count)
        queue.insert(song, at: insertIndex)
        if isShuffled {
            queueOrderBeforeShuffle.insert(song, at: insertIndex)
        }
    }

    func appendToQueue(_ song: Song) {
        pushQueueState()
        redoStack.removeAll()
        queue.append(song)
        if isShuffled {
            queueOrderBeforeShuffle.append(song)
        }
    }

    func removeFromQueue(at index: Int) {
        guard queue.indices.contains(index) else { return }
        pushQueueState()
        redoStack.removeAll()
        let removed = queue.remove(at: index)
        queueOrderBeforeShuffle.removeAll { $0.id == removed.id }
        if index < queueIndex {
            queueIndex -= 1
        } else if index == queueIndex {
            if queue.isEmpty {
                currentSong = nil
                isPlaying = false
                playerService.stop()
            } else {
                queueIndex = min(queueIndex, queue.count - 1)
                playCurrentFromQueue(effectiveQueue())
            }
        }
    }

    func reorderQueue(from: Int, to: Int) {
        guard queue.indices.contains(from), queue.indices.contains(to), from != to else { return }
        pushQueueState()
        redoStack.removeAll()
        let moved = queue.remove(at: from)
        queue.insert(moved, at: to)
        if from == queueIndex {
            queueIndex = to
        } else {
            if from < queueIndex { queueIndex -= 1 }
            if to <= queueIndex { queueIndex += 1 }
        }
    }

    func clearQueue() {
        pushQueueState()
        redoStack.removeAll()
        queue.removeAll()
        queueOrderBeforeShuffle.removeAll()
        forwardSkipStack.removeAll()
        currentSong = nil
        isPlaying = false
        queueIndex = 0
        playerService.stop()
    }

    // MARK: - Undo / Redo

    func undoQueue() {
        guard let state = undoStack.popLast() else { return }
        let currentState = captureQueueState()
        redoStack.append(currentState)
        restoreQueueState(state)
    }

    func redoQueue() {
        guard let state = redoStack.popLast() else { return }
        let currentState = captureQueueState()
        undoStack.append(currentState)
        restoreQueueState(state)
    }

    var canUndo: Bool { !undoStack.isEmpty }
    var canRedo: Bool { !redoStack.isEmpty }

    private func pushQueueState() {
        let state = captureQueueState()
        undoStack.append(state)
        if undoStack.count > maxUndoHistory {
            undoStack.removeFirst()
        }
    }

    private func captureQueueState() -> QueueState {
        QueueState(trackIDs: queue.compactMap(\.youtubeTrackID), currentIndex: queueIndex)
    }

    private func restoreQueueState(_ state: QueueState) {
        var restored: [Song] = []
        let allTracks = YouTubeAudioLibraryService.shared.tracks
        for ytID in state.trackIDs {
            guard let yt = allTracks.first(where: { $0.id == ytID }) else { continue }
            restored.append(Song(
                title: yt.title,
                artist: "YouTube Audio Library",
                album: "YouTube Free Library",
                duration: 180,
                youtubeTrackID: yt.id
            ))
        }
        if restored.isEmpty { return }
        queue = restored
        queueIndex = min(state.currentIndex, restored.count - 1)
        if queue.indices.contains(queueIndex) {
            play(song: queue[queueIndex], in: queue)
        }
    }

    // MARK: - Duplicate Removal

    private func deduplicated(_ songs: [Song]) -> [Song] {
        var seen = Set<UUID>()
        return songs.filter { seen.insert($0.id).inserted }
    }

    func removeDuplicateQueueEntries() {
        let before = queue.count
        queue = deduplicated(queue)
        if queue.count < before {
            queueIndex = min(queueIndex, queue.count - 1)
        }
    }

    // MARK: - Persistence

    private func saveSession() {
        guard currentSong != nil else { return }
        let trackIDs = queue.compactMap(\.youtubeTrackID)
        guard !trackIDs.isEmpty else { return }
        let session = PersistedSession(
            queueTrackIDs: trackIDs,
            queueIndex: queueIndex,
            currentTime: currentTime,
            isShuffled: isShuffled,
            repeatModeRaw: repeatMode.rawValue,
            volume: volume
        )
        if let data = try? JSONEncoder().encode(session) {
            UserDefaults.standard.set(data, forKey: Self.persistenceKey)
        }
    }

    private func restoreSession() {
        guard let data = UserDefaults.standard.data(forKey: Self.persistenceKey),
              let session = try? JSONDecoder().decode(PersistedSession.self, from: data) else { return }

        let allTracks = YouTubeAudioLibraryService.shared.tracks
        var restored: [Song] = []
        for ytID in session.queueTrackIDs {
            guard let yt = allTracks.first(where: { $0.id == ytID }) else { continue }
            restored.append(Song(
                title: yt.title,
                artist: "YouTube Audio Library",
                album: "YouTube Free Library",
                duration: 180,
                youtubeTrackID: yt.id
            ))
        }

        guard !restored.isEmpty else { return }

        queue = restored
        queueIndex = min(session.queueIndex, restored.count - 1)
        queueOrderBeforeShuffle = queue
        isShuffled = session.isShuffled
        repeatMode = RepeatMode(rawValue: session.repeatModeRaw) ?? .none
        volume = session.volume
        currentSong = queue.indices.contains(queueIndex) ? queue[queueIndex] : nil
        currentTime = min(session.currentTime, currentSong?.duration ?? 0)
        duration = currentSong?.duration ?? 0
    }

    // MARK: - Formatters

    var formattedCurrentTime: String { formatTime(currentTime) }
    var formattedDuration: String { formatTime(duration) }

    private func formatTime(_ time: TimeInterval) -> String {
        let m = Int(time) / 60
        let s = Int(time) % 60
        return "\(m):\(String(format: "%02d", s))"
    }
}
