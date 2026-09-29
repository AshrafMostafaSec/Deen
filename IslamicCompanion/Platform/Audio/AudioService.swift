import Foundation
import AVFoundation
import MediaPlayer
import Observation

public enum AudioPlaybackSource: Sendable, Equatable {
    case idle
    case quran(surahName: String, reciterName: String, ayahNumber: Int)
    case radio(station: RadioStation)
}

public enum AudioPlaybackState: Sendable, Equatable {
    case idle
    case preparing
    case playing
    case paused
    case buffering
    case failed(String)
}

@MainActor
@Observable
public final class AudioService: NSObject {
    public static let shared = AudioService()
    
    public private(set) var currentSource: AudioPlaybackSource = .idle
    public private(set) var playbackState: AudioPlaybackState = .idle
    public private(set) var currentTitle: String = ""
    public private(set) var currentSubtitle: String = ""
    public private(set) var isPlaying: Bool = false
    public private(set) var isLiveRadio: Bool = false
    
    public var onAyahPlaybackFinished: (@MainActor () -> Void)?
    
    private var player: AVPlayer?
    private var currentStation: RadioStation?
    private var currentCandidateIndex: Int = 0
    private var wasPlayingBeforeInterruption: Bool = false
    
    // KVO Observers
    private nonisolated(unsafe) var statusObservation: NSKeyValueObservation?
    private nonisolated(unsafe) var timeControlObservation: NSKeyValueObservation?
    
    private override init() {
        super.init()
        setupRemoteCommands()
        setupAudioSessionObservers()
    }
    
    deinit {
        statusObservation?.invalidate()
        timeControlObservation?.invalidate()
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Public Playback API
    
    public func playRadio(station: RadioStation) {
        self.currentStation = station
        self.currentCandidateIndex = 0
        playCurrentStationCandidate()
    }
    
    private func playCurrentStationCandidate() {
        guard let station = currentStation else { return }
        let candidates = station.streamCandidates.sorted(by: { $0.priority < $1.priority })
        guard currentCandidateIndex < candidates.count else {
            self.playbackState = .failed("All stream candidates failed")
            return
        }
        
        let candidate = candidates[currentCandidateIndex]
        teardownCurrentPlayback()
        
        self.currentSource = .radio(station: station)
        self.currentTitle = station.name
        self.currentSubtitle = station.shortName ?? "Egyptian Radio"
        self.isLiveRadio = true
        self.playbackState = .preparing
        
        startPlayback(url: candidate.url, isLive: true)
    }
    
    public func playQuranAudio(surahName: String, reciterName: String, audioURL: URL, ayahNumber: Int) {
        teardownCurrentPlayback()
        
        self.currentSource = .quran(surahName: surahName, reciterName: reciterName, ayahNumber: ayahNumber)
        self.currentTitle = surahName
        self.currentSubtitle = reciterName
        self.isLiveRadio = false
        self.playbackState = .preparing
        
        startPlayback(url: audioURL, isLive: false)
    }
    
    public func togglePlayPause() {
        guard let player else { return }
        if isPlaying {
            player.pause()
            self.isPlaying = false
            self.playbackState = .paused
            updateNowPlayingPlaybackRate(0.0)
        } else {
            activateAudioSession()
            player.play()
            self.isPlaying = true
            self.playbackState = .playing
            updateNowPlayingPlaybackRate(1.0)
        }
    }
    
    public func stop() {
        teardownCurrentPlayback()
        try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
        self.currentSource = .idle
        self.playbackState = .idle
        self.currentTitle = ""
        self.currentSubtitle = ""
        self.isPlaying = false
        self.isLiveRadio = false
        clearNowPlaying()
    }
    
    // MARK: - Core Playback Engine
    
    private func startPlayback(url: URL, isLive: Bool) {
        activateAudioSession()
        
        let asset = AVURLAsset(url: url)
        let item = AVPlayerItem(asset: asset)
        
        // Swift 6 safe: Extract values outside of @Sendable task
        statusObservation = item.observe(\.status, options: [.new, .old]) { [weak self] observedItem, _ in
            let status = observedItem.status
            let errorMsg = observedItem.error?.localizedDescription
            Task { @MainActor [weak self] in
                guard let self else { return }
                switch status {
                case .readyToPlay:
                    self.playbackState = .playing
                    self.isPlaying = true
                    self.updateNowPlayingInfo()
                case .failed:
                    if self.isLiveRadio, let station = self.currentStation {
                        let candidatesCount = station.streamCandidates.count
                        if self.currentCandidateIndex + 1 < candidatesCount {
                            self.currentCandidateIndex += 1
                            self.playCurrentStationCandidate()
                            return
                        }
                    }
                    self.playbackState = .failed(errorMsg ?? "Stream failed")
                    self.isPlaying = false
                default:
                    break
                }
            }
        }
        
        let newPlayer = AVPlayer(playerItem: item)
        timeControlObservation = newPlayer.observe(\.timeControlStatus, options: [.new]) { [weak self] observedPlayer, _ in
            let timeStatus = observedPlayer.timeControlStatus
            Task { @MainActor [weak self] in
                guard let self else { return }
                switch timeStatus {
                case .playing:
                    self.playbackState = .playing
                    self.isPlaying = true
                case .paused:
                    if self.playbackState != .idle {
                        self.playbackState = .paused
                        self.isPlaying = false
                    }
                case .waitingToPlayAtSpecifiedRate:
                    self.playbackState = .buffering
                @unknown default:
                    break
                }
            }
        }
        
        // Listen for item completion (for Quran Ayahs)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleItemDidPlayToEnd),
            name: .AVPlayerItemDidPlayToEndTime,
            object: item
        )
        
        // Listen for live radio stalls
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleItemPlaybackStalled),
            name: .AVPlayerItemPlaybackStalled,
            object: item
        )
        
        self.player = newPlayer
        newPlayer.play()
        self.isPlaying = true
        self.updateNowPlayingInfo()
    }
    
    private func teardownCurrentPlayback() {
        statusObservation?.invalidate()
        statusObservation = nil
        timeControlObservation?.invalidate()
        timeControlObservation = nil
        
        NotificationCenter.default.removeObserver(self, name: .AVPlayerItemDidPlayToEndTime, object: nil)
        NotificationCenter.default.removeObserver(self, name: .AVPlayerItemPlaybackStalled, object: nil)
        
        player?.pause()
        player = nil
    }
    
    // MARK: - AVPlayer Item Handlers
    
    @objc nonisolated private func handleItemDidPlayToEnd() {
        Task { @MainActor [weak self] in
            guard let self else { return }
            self.isPlaying = false
            self.playbackState = .paused
            self.updateNowPlayingPlaybackRate(0.0)
            self.onAyahPlaybackFinished?()
        }
    }
    
    @objc nonisolated private func handleItemPlaybackStalled() {
        Task { @MainActor [weak self] in
            guard let self else { return }
            if self.isLiveRadio {
                self.playbackState = .buffering
                // Attempt soft resume
                self.player?.play()
            }
        }
    }
    
    // MARK: - Audio Session Configuration
    
    private func activateAudioSession() {
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playback, mode: .default, policy: .longFormAudio)
            try session.setActive(true)
        } catch {
            // Non-fatal, audio engine handles error gracefully
        }
    }
    
    // MARK: - Now Playing & Remote Command Center
    
    private func setupRemoteCommands() {
        let commandCenter = MPRemoteCommandCenter.shared()
        
        commandCenter.playCommand.addTarget { [weak self] _ in
            Task { @MainActor [weak self] in
                guard let self else { return }
                if !self.isPlaying {
                    self.togglePlayPause()
                }
            }
            return .success
        }
        
        commandCenter.pauseCommand.addTarget { [weak self] _ in
            Task { @MainActor [weak self] in
                guard let self else { return }
                if self.isPlaying {
                    self.togglePlayPause()
                }
            }
            return .success
        }
        
        commandCenter.togglePlayPauseCommand.addTarget { [weak self] _ in
            Task { @MainActor [weak self] in
                self?.togglePlayPause()
            }
            return .success
        }
    }
    
    private func updateNowPlayingInfo() {
        var info = [String: Any]()
        info[MPMediaItemPropertyTitle] = currentTitle
        info[MPMediaItemPropertyArtist] = currentSubtitle
        info[MPNowPlayingInfoPropertyIsLiveStream] = isLiveRadio
        info[MPNowPlayingInfoPropertyPlaybackRate] = isPlaying ? 1.0 : 0.0
        
        if let player = player, let currentItem = player.currentItem {
            let currentTime = player.currentTime()
            if currentTime.isNumeric {
                info[MPNowPlayingInfoPropertyElapsedPlaybackTime] = CMTimeGetSeconds(currentTime)
            }
            let duration = currentItem.duration
            if duration.isNumeric && !isLiveRadio {
                info[MPMediaItemPropertyPlaybackDuration] = CMTimeGetSeconds(duration)
            }
        }
        
        MPNowPlayingInfoCenter.default().nowPlayingInfo = info
    }
    
    private func updateNowPlayingPlaybackRate(_ rate: Double) {
        guard var info = MPNowPlayingInfoCenter.default().nowPlayingInfo else { return }
        info[MPNowPlayingInfoPropertyPlaybackRate] = rate
        if let player, player.currentTime().isNumeric {
            info[MPNowPlayingInfoPropertyElapsedPlaybackTime] = CMTimeGetSeconds(player.currentTime())
        }
        MPNowPlayingInfoCenter.default().nowPlayingInfo = info
    }
    
    private func clearNowPlaying() {
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nil
    }
    
    // MARK: - System Audio Session Notification Observers
    
    private func setupAudioSessionObservers() {
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
    
    @objc nonisolated private func handleInterruption(notification: Notification) {
        guard let userInfo = notification.userInfo,
              let typeValue = userInfo[AVAudioSessionInterruptionTypeKey] as? UInt else { return }
        let optionsValue = userInfo[AVAudioSessionInterruptionOptionKey] as? UInt
        
        Task { @MainActor [weak self] in
            guard let self, let type = AVAudioSession.InterruptionType(rawValue: typeValue) else { return }
            switch type {
            case .began:
                self.wasPlayingBeforeInterruption = self.isPlaying
                self.isPlaying = false
                self.playbackState = .paused
                self.updateNowPlayingPlaybackRate(0.0)
            case .ended:
                let shouldResume = (optionsValue.flatMap { AVAudioSession.InterruptionOptions(rawValue: $0) })?.contains(.shouldResume) ?? false
                if shouldResume && self.wasPlayingBeforeInterruption {
                    if self.isLiveRadio {
                        self.playCurrentStationCandidate()
                    } else {
                        self.activateAudioSession()
                        self.player?.play()
                        self.isPlaying = true
                        self.playbackState = .playing
                        self.updateNowPlayingPlaybackRate(1.0)
                    }
                }
            @unknown default:
                break
            }
        }
    }
    
    @objc nonisolated private func handleRouteChange(notification: Notification) {
        guard let userInfo = notification.userInfo,
              let reasonValue = userInfo[AVAudioSessionRouteChangeReasonKey] as? UInt else { return }
        
        Task { @MainActor [weak self] in
            guard let self, let reason = AVAudioSession.RouteChangeReason(rawValue: reasonValue) else { return }
            if reason == .oldDeviceUnavailable {
                if self.isPlaying {
                    self.player?.pause()
                    self.isPlaying = false
                    self.playbackState = .paused
                    self.updateNowPlayingPlaybackRate(0.0)
                }
            }
        }
    }
}
