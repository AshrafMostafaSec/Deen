import Foundation
import AVFoundation
import MediaPlayer
import Observation

public enum PlaybackState: Sendable, Equatable {
    case idle
    case preparing
    case playing
    case paused
    case buffering
    case failed(String)
}

public enum AudioPlaybackSource: Sendable, Equatable {
    case quran(surahName: String, reciterName: String, ayahNumber: Int?)
    case radio(stationName: String, stationID: String)
}

@MainActor
@Observable
public final class AudioService: NSObject {
    public static let shared = AudioService()
    
    public private(set) var playbackState: PlaybackState = .idle
    public private(set) var currentSource: AudioPlaybackSource?
    public private(set) var currentTitle: String = ""
    public private(set) var currentSubtitle: String = ""
    public private(set) var isPlaying: Bool = false
    public private(set) var isLiveRadio: Bool = false
    
    private var player: AVPlayer?
    private var playerItem: AVPlayerItem?
    private var statusObservation: NSKeyValueObservation?
    private var timeControlObservation: NSKeyValueObservation?
    
    public override init() {
        super.init()
        setupAudioSession()
        setupRemoteCommands()
        setupNotifications()
    }
    
    deinit {
        statusObservation?.invalidate()
        timeControlObservation?.invalidate()
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Public Playback API
    
    public func playRadio(station: RadioStation) {
        guard let candidate = station.streamCandidates.first else {
            playbackState = .failed("No valid stream candidate available")
            return
        }
        
        teardownCurrentPlayback()
        
        currentSource = .radio(stationName: station.name, stationID: station.id)
        currentTitle = station.name
        currentSubtitle = station.shortName ?? "Live Broadcast"
        isLiveRadio = true
        playbackState = .preparing
        
        startPlayback(url: candidate.url, isLive: true)
    }
    
    public func playQuranAudio(surahName: String, reciterName: String, audioURL: URL, ayahNumber: Int? = nil) {
        teardownCurrentPlayback()
        
        currentSource = .quran(surahName: surahName, reciterName: reciterName, ayahNumber: ayahNumber)
        currentTitle = surahName
        currentSubtitle = reciterName
        isLiveRadio = false
        playbackState = .preparing
        
        startPlayback(url: audioURL, isLive: false)
    }
    
    public func togglePlayPause() {
        guard let player = player else { return }
        if isPlaying {
            player.pause()
            isPlaying = false
            playbackState = .paused
            updateNowPlayingPlaybackRate(0.0)
        } else {
            player.play()
            isPlaying = true
            playbackState = .playing
            updateNowPlayingPlaybackRate(1.0)
        }
    }
    
    public func stop() {
        teardownCurrentPlayback()
    }
    
    // MARK: - Private Player Mechanics
    
    private func startPlayback(url: URL, isLive: Bool) {
        activateAudioSession()
        
        let asset = AVURLAsset(url: url, options: ["AVURLAssetHTTPHeaderFieldsKey": ["User-Agent": "DeenIslamicCompanion/1.0"]])
        let item = AVPlayerItem(asset: asset)
        self.playerItem = item
        
        let player = AVPlayer(playerItem: item)
        player.automaticallyWaitsToMinimizeStalling = true
        self.player = player
        
        // Observe Player Item Status
        statusObservation = item.observe(\.status, options: [.new, .old]) { [weak self] item, _ in
            guard let self else { return }
            Task { @MainActor in
                switch item.status {
                case .readyToPlay:
                    self.player?.play()
                    self.isPlaying = true
                    self.playbackState = .playing
                    self.updateNowPlayingInfo(isLive: isLive)
                case .failed:
                    let err = item.error?.localizedDescription ?? "Playback failed"
                    self.playbackState = .failed(err)
                    self.isPlaying = false
                case .unknown:
                    self.playbackState = .preparing
                @unknown default:
                    break
                }
            }
        }
        
        // Observe Time Control Status (Buffering vs Playing)
        timeControlObservation = player.observe(\.timeControlStatus, options: [.new]) { [weak self] player, _ in
            guard let self else { return }
            Task { @MainActor in
                switch player.timeControlStatus {
                case .playing:
                    self.isPlaying = true
                    self.playbackState = .playing
                case .paused:
                    self.isPlaying = false
                    if case .failed = self.playbackState {
                        // Keep failure state
                    } else {
                        self.playbackState = .paused
                    }
                case .waitingToPlayAtSpecifiedRate:
                    self.playbackState = .buffering
                @unknown default:
                    break
                }
            }
        }
    }
    
    private func teardownCurrentPlayback() {
        statusObservation?.invalidate()
        statusObservation = nil
        timeControlObservation?.invalidate()
        timeControlObservation = nil
        
        player?.pause()
        player = nil
        playerItem = nil
        
        isPlaying = false
        playbackState = .idle
        currentSource = nil
        currentTitle = ""
        currentSubtitle = ""
        isLiveRadio = false
        
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nil
    }
    
    // MARK: - System Integrations (AudioSession, RemoteCommands, Interruptions)
    
    private func setupAudioSession() {
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playback, mode: .default, policy: .longFormAudio)
        } catch {
            // Log audio session configuration error gracefully
        }
    }
    
    private func activateAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            // Non-fatal
        }
    }
    
    private func setupRemoteCommands() {
        let commandCenter = MPRemoteCommandCenter.shared()
        
        commandCenter.playCommand.addTarget { [weak self] _ in
            Task { @MainActor in
                self?.player?.play()
                self?.isPlaying = true
                self?.playbackState = .playing
            }
            return .success
        }
        
        commandCenter.pauseCommand.addTarget { [weak self] _ in
            Task { @MainActor in
                self?.player?.pause()
                self?.isPlaying = false
                self?.playbackState = .paused
            }
            return .success
        }
        
        commandCenter.togglePlayPauseCommand.addTarget { [weak self] _ in
            Task { @MainActor in
                self?.togglePlayPause()
            }
            return .success
        }
    }
    
    private func updateNowPlayingInfo(isLive: Bool) {
        var info = [String: Any]()
        info[MPMediaItemPropertyTitle] = currentTitle
        info[MPMediaItemPropertyArtist] = currentSubtitle
        info[MPMediaItemPropertyAlbumTitle] = isLive ? "Egyptian Radio Live" : "The Holy Quran"
        info[MPNowPlayingInfoPropertyIsLiveStream] = isLive
        info[MPNowPlayingInfoPropertyPlaybackRate] = 1.0
        
        if !isLive, let duration = playerItem?.duration, duration.isNumeric {
            info[MPMediaItemPropertyPlaybackDuration] = CMTimeGetSeconds(duration)
            info[MPNowPlayingInfoPropertyElapsedPlaybackTime] = CMTimeGetSeconds(player?.currentTime() ?? .zero)
        }
        
        MPNowPlayingInfoCenter.default().nowPlayingInfo = info
    }
    
    private func updateNowPlayingPlaybackRate(_ rate: Double) {
        var info = MPNowPlayingInfoCenter.default().nowPlayingInfo ?? [:]
        info[MPNowPlayingInfoPropertyPlaybackRate] = rate
        MPNowPlayingInfoCenter.default().nowPlayingInfo = info
    }
    
    private func setupNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleInterruption),
            name: AVAudioSession.interruptionNotification,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleRouteChange),
            name: AVAudioSession.routeChangeNotification,
            object: nil
        )
    }
    
    @objc private func handleInterruption(notification: Notification) {
        guard let userInfo = notification.userInfo,
              let typeValue = userInfo[AVAudioSessionInterruptionTypeKey] as? UInt,
              let type = AVAudioSession.InterruptionType(rawValue: typeValue) else { return }
        
        switch type {
        case .began:
            player?.pause()
            isPlaying = false
            playbackState = .paused
        case .ended:
            if let optionsValue = userInfo[AVAudioSessionInterruptionOptionKey] as? UInt {
                let options = AVAudioSession.InterruptionOptions(rawValue: optionsValue)
                if options.contains(.shouldResume) {
                    player?.play()
                    isPlaying = true
                    playbackState = .playing
                }
            }
        @unknown default:
            break
        }
    }
    
    @objc private func handleRouteChange(notification: Notification) {
        guard let userInfo = notification.userInfo,
              let reasonValue = userInfo[AVAudioSessionRouteChangeReasonKey] as? UInt,
              let reason = AVAudioSession.RouteChangeReason(rawValue: reasonValue) else { return }
        
        switch reason {
        case .oldDeviceUnavailable:
            // Headphones unplugged or Bluetooth disconnected -> pause immediately!
            player?.pause()
            isPlaying = false
            playbackState = .paused
        default:
            break
        }
    }
}
