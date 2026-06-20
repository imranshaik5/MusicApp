import Foundation
import AVKit
import Combine

protocol AudioPlayerServiceProtocol: AnyObject {
    var currentTime: TimeInterval { get }
    var duration: TimeInterval { get }
    var isPlaying: Bool { get }
    var volume: Float { get set }

    func play(url: URL) async
    func resume()
    func pause()
    func stop()
    func seek(to time: TimeInterval)
    func togglePlayPause()

    var onTimeUpdate: ((TimeInterval) -> Void)? { get set }
    var onPlaybackEnd: (() -> Void)? { get set }
    var onDurationUpdate: ((TimeInterval) -> Void)? { get set }
}

final class AudioPlayerService: NSObject, AudioPlayerServiceProtocol {
    private var player: AVPlayer?
    private var timeObserver: Any?

    var onTimeUpdate: ((TimeInterval) -> Void)?
    var onPlaybackEnd: (() -> Void)?
    var onDurationUpdate: ((TimeInterval) -> Void)?

    private(set) var currentTime: TimeInterval = 0
    private(set) var duration: TimeInterval = 0
    private(set) var isPlaying = false

    var volume: Float {
        get { player?.volume ?? 0.5 }
        set { player?.volume = newValue }
    }

    deinit {
        removeTimeObserver()
    }

    func play(url: URL) async {
        removeTimeObserver()
        player?.pause()

        let asset = AVAsset(url: url)
        let playerItem = await AVPlayerItem(asset: asset)

        do {
            let loaded = try await asset.load(.duration)
            duration = CMTimeGetSeconds(loaded)
            onDurationUpdate?(duration)
        } catch {
            duration = 0
        }

        player = AVPlayer(playerItem: playerItem)
        player?.volume = volume

        addTimeObserver()
        player?.play()
        isPlaying = true
    }

    func resume() {
        player?.play()
        isPlaying = true
    }

    func pause() {
        player?.pause()
        isPlaying = false
    }

    func stop() {
        player?.pause()
        player = nil
        isPlaying = false
        currentTime = 0
        removeTimeObserver()
    }

    func seek(to time: TimeInterval) {
        let cmTime = CMTime(seconds: time, preferredTimescale: 1000)
        player?.seek(to: cmTime, toleranceBefore: .zero, toleranceAfter: .zero) { [weak self] finished in
            if finished {
                self?.currentTime = time
            }
        }
    }

    func togglePlayPause() {
        if isPlaying {
            pause()
        } else {
            resume()
        }
    }

    private func addTimeObserver() {
        let interval = CMTime(seconds: 0.25, preferredTimescale: 1000)
        timeObserver = player?.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] time in
            let seconds = CMTimeGetSeconds(time)
            self?.currentTime = seconds
            self?.onTimeUpdate?(seconds)
        }
    }

    private func removeTimeObserver() {
        guard let observer = timeObserver else { return }
        player?.removeTimeObserver(observer)
        timeObserver = nil
    }
}

extension AudioPlayerService {
    // Generate a silent audio file for mock playback
    static func generateSilentAudioURL(duration: TimeInterval) -> URL {
        let tempDir = FileManager.default.temporaryDirectory
        let url = tempDir.appendingPathComponent("mock_\(Int(duration)).m4a")
        return url
    }
}
