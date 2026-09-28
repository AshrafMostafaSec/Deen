# AGENTS.md — iOS Islamic Daily Companion

> Repository operating rules for AI coding agents and human contributors.
> Last architecture review: 2026-09-29.

## 0. Mission

Build a production-quality, iPhone-first Islamic daily companion focused on the smallest set of high-value daily experiences:

- Quran reading
- Quran audio
- Prayer times
- Prayer tracking
- Qibla
- Adhkar
- Qiyam Al-Layl
- iOS widgets
- Live Egyptian radio / Quran radio

The app must be fast, stable, private, accessible, offline-friendly where practical, and native to Apple platforms.

Do not expand into hadith libraries, fatwa generation, social/community features, news, ads, marketplaces, or unrelated religious content unless a future product decision explicitly adds them.

---

## 1. Product Source of Truth

### Visual baseline

Use the **original Stitch prototype supplied with this repository** as the visual source of truth. Its working design language is the `Aetherial Astrolabe` system.

Preserve its strongest characteristics:

- deep graphite / OLED-friendly dark surfaces
- emerald-sage primary accent
- restrained warm tertiary accent
- floating translucent navigation and media controls
- soft continuous corners
- compact prayer instrumentation
- premium, quiet, technical-spiritual feeling

Do not randomly redesign the product while implementing it.

### Language rule

The application interface is **English-first**.

All normal UI must be English:

- navigation
- tab labels
- buttons
- settings
- status text
- error text
- prayer names
- radio UI
- widget labels

Arabic is reserved for authentic religious content where appropriate, especially Quran text and Arabic Adhkar.

### Main navigation

Keep the primary app navigation intentionally small:

1. Today
2. Quran
3. Prayer
4. Adhkar

Radio is a first-class feature, but it does not need to become a fifth root tab in v1. It can be entered from Today, Quran/Listen affordances, search/quick actions, widgets/controls, or a dedicated Radio route. The audio mini-player may persist above the tab bar while Quran audio or radio is active.

---

## 2. Apple Platform Baseline

Primary target:

- iPhone
- iOS 27 SDK
- Xcode 27
- Swift 6.4 language mode
- SwiftUI
- strict Swift concurrency

Use current Apple APIs first. Avoid third-party frameworks for capabilities Apple already provides well.

Core Apple frameworks expected in the project:

- SwiftUI
- Observation
- Foundation
- SwiftData
- WidgetKit
- AppIntents
- CoreLocation
- AVFoundation / AVFAudio
- MediaPlayer
- UserNotifications
- Network
- OSLog
- MetricKit
- BackgroundTasks only when a real supported use case exists

Do not add a dependency merely to save a small amount of code. Every external package increases update, security, startup, and maintenance cost.

---

## 3. Architecture Style

Use a **feature-first modular architecture** with strict boundaries:

```text
Presentation (SwiftUI)
        ↓
Feature State / Actions / Use Cases
        ↓
Domain Protocols + Domain Models
        ↓
Repositories
        ↓
Platform + Local + Remote Data Sources
```

Rules:

- Views never call network clients directly.
- Views never calculate prayer times directly.
- Views never read CoreLocation directly.
- Views never control AVPlayer directly.
- Views never talk to SwiftData directly except through a feature/repository boundary.
- Feature code depends on protocols, not concrete infrastructure.
- Core/domain modules must not import SwiftUI unless the module is explicitly UI/design-system code.

Prefer simple native patterns over architecture ceremony.

State should normally use Swift Observation (`@Observable`) and unidirectional user actions. Keep mutable UI state on the main actor. Put long-running or shared mutable services behind actors.

---

## 4. Repository Layout

The target repository structure is:

```text
IslamicCompanion/
├── AGENTS.md
├── ARCHITECTURE.md
├── README.md
├── IslamicCompanion.xcodeproj
├── App/
│   ├── IslamicCompanionApp.swift
│   ├── AppEnvironment.swift
│   ├── AppRouter.swift
│   ├── AppLifecycle.swift
│   └── RootTabView.swift
│
├── DesignSystem/
│   ├── Tokens/
│   ├── Typography/
│   ├── Components/
│   ├── Materials/
│   ├── Icons/
│   └── Accessibility/
│
├── Domain/
│   ├── Models/
│   ├── Errors/
│   ├── Repositories/
│   └── UseCases/
│
├── Platform/
│   ├── Audio/
│   ├── Location/
│   ├── Notifications/
│   ├── Networking/
│   ├── Persistence/
│   ├── Logging/
│   ├── Metrics/
│   └── AppGroup/
│
├── Features/
│   ├── Today/
│   ├── Quran/
│   │   ├── QuranHome/
│   │   ├── Reader/
│   │   ├── Audio/
│   │   └── Downloads/
│   ├── Prayer/
│   │   ├── PrayerTimes/
│   │   ├── Tracker/
│   │   ├── Qibla/
│   │   └── Qiyam/
│   ├── Adhkar/
│   ├── Radio/
│   └── Settings/
│
├── Widgets/
│   ├── PrayerWidgets/
│   ├── QuranWidgets/
│   ├── AdhkarWidgets/
│   ├── QiyamWidgets/
│   ├── RadioWidgets/
│   ├── Intents/
│   └── SharedWidgetUI/
│
├── Resources/
│   ├── Quran/
│   ├── Adhkar/
│   ├── Radio/
│   ├── Localizable.xcstrings
│   └── Assets.xcassets
│
├── Tests/
│   ├── DomainTests/
│   ├── PrayerTests/
│   ├── QuranTests/
│   ├── RadioTests/
│   ├── WidgetTests/
│   └── PerformanceTests/
│
└── UITests/
```

If the project grows, these directories may become local Swift packages. Do not split into packages prematurely if it slows iteration; boundaries must exist logically from day one even if they initially live in one Xcode project.

---

## 5. Dependency Injection

Use one explicit composition root in `AppEnvironment`.

Example responsibilities:

```swift
struct AppEnvironment {
    let prayerRepository: any PrayerRepository
    let quranRepository: any QuranRepository
    let adhkarRepository: any AdhkarRepository
    let radioRepository: any RadioRepository
    let audioService: AudioService
    let locationService: LocationService
    let notificationService: NotificationService
    let widgetSnapshotStore: WidgetSnapshotStore
}
```

Requirements:

- dependencies are constructed once at app composition
- feature screens receive only what they need
- tests can inject deterministic fakes
- do not use hidden global service locators
- avoid uncontrolled singletons
- system singletons such as `AVAudioSession.sharedInstance()` must be wrapped inside platform services

---

## 6. Concurrency Rules

Swift 6.4 strict concurrency is mandatory.

Use:

- `@MainActor` for view-facing mutable state
- actors for shared mutable infrastructure
- structured concurrency
- cancellation-aware async APIs
- `AsyncSequence` where streams of state are natural

Avoid:

- arbitrary `Task.detached`
- fire-and-forget tasks with no owner
- callback pyramids when an async API exists
- mutable global state
- `DispatchQueue.main.async` as an architecture pattern

Every long-lived task needs a clear owner and cancellation path.

When a screen disappears, cancel work that is no longer useful unless it intentionally belongs to an app-level service such as active audio playback.

---

## 7. Stability / Crash Policy

Production paths must contain no casual crash primitives.

Forbidden except in test-only or provably unreachable initialization code:

- force unwrap `!`
- `try!`
- `fatalError()`
- `preconditionFailure()`
- forced downcasts

Handle recoverable errors explicitly.

Use typed domain errors where they improve behavior:

- network unavailable
- radio stream unavailable
- invalid/corrupt content
- audio interruption
- location unavailable
- compass unavailable
- download failure
- storage failure

The UI must degrade gracefully.

A failed radio station must not crash the app.
A failed Quran audio item must not crash the reader.
A missing location must not block the rest of the app.

---

## 8. Performance Rules

Performance is a product requirement, not a cleanup phase.

### Main thread

Never perform the following synchronously on the main thread:

- network calls
- large JSON decoding
- database migrations
- heavy Quran indexing
- file hashing
- large image decoding
- audio downloads
- stream probing

### Lazy rendering

Use lazy containers for long content:

- `LazyVStack`
- lazy Quran/surah lists
- incremental search results
- paged reader data
- lazy radio station artwork

Do not instantiate the full Quran UI hierarchy at launch.

### Launch

The first rendered Today screen must depend on cached/local state first.

Launch sequence:

1. render shell + cached snapshot
2. load essential local state
3. refresh prayer/location data if needed
4. refresh remote catalog/content in the background

Do not show a blocking full-screen spinner during a normal launch.

### Images

- prefer vector/SF Symbols for UI
- radio logos must be downsampled to their displayed size
- use a bounded cache
- no full-resolution image retention when a thumbnail is enough

### Audio

Never download an entire live radio stream into memory.
Never decode or buffer an entire Quran audio file in RAM.
Use streaming/file-backed playback APIs.

---

## 9. Memory Rules

Memory growth must be bounded.

Required practices:

- one app-level audio engine/player owner
- release replaced `AVPlayerItem` objects
- invalidate/remove observers
- use weak captures where ownership would otherwise cycle
- clear temporary buffers after use
- limit image cache cost/count
- avoid retaining full Quran page arrays in every feature state
- store identifiers in navigation state instead of large models
- avoid duplicated content caches across features

Use Instruments during development:

- Allocations
- Leaks
- Memory Graph
- Time Profiler
- Network
- Energy Log

Any monotonic memory growth during repeated open/close cycles is a release blocker until understood.

---

## 10. Logging and Diagnostics

Use `Logger` / OSLog categories, not random `print()` statements.

Suggested subsystems/categories:

- app.lifecycle
- prayer.engine
- prayer.tracker
- qibla
- quran.reader
- quran.audio
- radio.catalog
- radio.player
- downloads
- widgets
- persistence
- notifications

Never log:

- precise user location
- personally identifying data
- full private user state

Use MetricKit and Xcode/App Store diagnostics for crash, hang, launch, memory, and energy investigation before adding third-party tracking SDKs.

---

# FEATURE ARCHITECTURE

## 11. Today Feature

`Today` is an aggregation feature. It owns presentation, not domain truth.

It consumes projections from:

- Prayer repository
- Quran progress repository
- Adhkar progress repository
- Qiyam calculator
- active Audio/Radio player state

Do not duplicate prayer/Quran logic inside Today.

The Today feature must remain fast enough to be the launch destination.

---

## 12. Prayer Feature

Split the feature into distinct responsibilities.

### PrayerEngine

Responsibilities:

- calculate prayer times from date/location/settings
- support user-selectable calculation settings
- apply configured adjustments
- expose next prayer
- expose daily timeline

The engine is pure/domain logic and must have deterministic tests.

Do not make network access required for basic prayer calculations.

### PrayerTracker

Store completion state locally.

Suggested domain model:

```swift
enum PrayerKind: String, Codable, CaseIterable {
    case fajr, dhuhr, asr, maghrib, isha
}

enum PrayerCompletion: String, Codable {
    case completed
    case onTime
    case congregation
    case late
    case missed
}
```

Do not calculate a religious score.
Do not create public streaks or leaderboards.

### Qibla

Use Core Location for location and heading.

Architecture:

```text
CoreLocation
   ↓
LocationService actor
   ↓
QiblaCalculator (pure bearing math)
   ↓
QiblaFeatureModel
   ↓
SwiftUI compass
```

Prefer true heading when valid; fall back gracefully when only magnetic heading is available.

Handle:

- denied location
- reduced accuracy
- unavailable heading
- invalid heading
- calibration guidance

Do not fake compass alignment.

### Qiyam

Qiyam calculation must be a pure function based on the relevant sunset/Isha/Fajr night interval rules selected by the product team.

Keep calculation logic testable and separate from notifications.

---

## 13. Quran Feature

The Quran feature has four separate layers:

1. canonical text/content
2. reading/navigation
3. audio playback
4. offline downloads

### Canonical content

Quran text is sacred content. It must come from a verified, versioned source with known licensing and integrity checks.

Never let an AI model invent, rewrite, auto-correct, summarize, or silently alter Quran text.

Store content version and checksums.

### Reader

The reader must load only the required page/ayah range plus a small nearby prefetch window.

Do not keep every rendered Quran page alive.

Reader navigation state stores IDs/page numbers, not giant attributed-string objects.

### Quran audio

Use the shared `AudioService` infrastructure, with Quran-specific queue behavior layered above it.

Support eventually:

- play ayah
- play surah
- previous/next ayah
- repeat
- playback speed where technically appropriate
- sleep timer
- download

Only one media source may own active playback at a time. Starting radio stops Quran audio cleanly and vice versa.

---

## 14. Adhkar Feature

Adhkar content must also be versioned and reviewed.

Architecture:

```text
AdhkarContentRepository
        +
AdhkarProgressRepository
        ↓
AdhkarFeatureModel
        ↓
Focused one-item reader
```

Keep counters and completion local and lightweight.

No analytics event needs to contain the actual religious text being read.

---

# RADIO

## 15. Radio Product Requirements

Radio is a supported first-class feature.

v1 goals:

- multiple Egyptian stations
- Quran Radio as a featured/default religious station
- station favorites
- background playback
- Lock Screen / Control Center metadata
- remote play/pause controls
- resilient reconnection
- station artwork
- Now Playing metadata when supplied by the stream
- mini-player shared with Quran audio
- route to full Radio player
- graceful unavailable/offline state

Potential future work:

- station schedule
- CarPlay
- alarm/sleep timer
- recently played
- AirPlay enhancements

Do not implement recording or redistribution of copyrighted radio broadcasts unless rights explicitly allow it.

---

## 16. Radio Architecture

```text
Remote Radio Catalog
      ↓
RadioCatalogClient
      ↓
RadioRepository
   ↙       ↘
Cache     Favorites
      ↓
RadioFeatureModel
      ↓
Shared AudioService / AVPlayer
      ↓
Now Playing + Remote Commands
```

### RadioStation model

```swift
struct RadioStation: Identifiable, Codable, Sendable {
    let id: String
    let name: String
    let shortName: String?
    let frequencyMHz: Double?
    let category: RadioCategory
    let countryCode: String
    let city: String?
    let artworkURL: URL?
    let officialWebsiteURL: URL?
    let streamCandidates: [RadioStream]
    let isFeatured: Bool
    let isEnabled: Bool
}

struct RadioStream: Codable, Sendable {
    let url: URL
    let format: RadioStreamFormat
    let priority: Int
}
```

### Catalog rule

**Do not hard-code live stream URLs inside SwiftUI views or feature state.**

Ship a small fallback catalog in the app bundle, but use a versioned remote catalog for production so broken/changed station endpoints can be repaired without an App Store release.

Recommended catalog fields:

- schemaVersion
- generatedAt
- station ID
- display name
- frequency
- category
- artwork
- official website
- primary/fallback stream endpoints
- enabled/disabled state
- minimum app version if needed

Catalog refresh should be cached and conservative. Do not redownload it on every screen appearance.

### Stream validation

Prefer official broadcaster stream endpoints or explicitly licensed aggregation endpoints.

Before a station is enabled in the production catalog:

1. confirm the station identity
2. confirm the endpoint belongs to or is authorized by the broadcaster/aggregator
3. test HTTPS/TLS behavior
4. test format support in AVPlayer
5. test lock-screen/background playback
6. test reconnection
7. document source/licensing

Do not scrape random radio directories at runtime.

---

## 17. Initial Egyptian Radio Catalog

The following stations are approved as **catalog candidates**. Their current live stream URLs must still be verified before shipping.

### Featured Quran / religious

1. **Quran Radio Cairo — إذاعة القرآن الكريم من القاهرة**
   - Featured station
   - Official Egyptian Quran Radio service
   - Treat as the default Radio landing recommendation

### National / general Egyptian radio

2. **Radio Masr — 88.7 FM**

### Popular commercial stations

3. **Nogoum FM — 100.6 FM**
4. **Nile FM — 104.2 FM**
5. **El Radio 9090 — 90.9 FM**
6. **Mega FM — 92.7 FM**
7. **Nagham FM — 105.3 FM**
8. **Sha3by FM — 95.0 FM**
9. **Radio Hits — 88.2 FM**

These are seed candidates, not permission to ship an unverified third-party stream URL.

The catalog must make it trivial to add/remove stations without changing feature code.

---

## 18. Radio Playback Service

Use `AVPlayer`/AVFoundation behind a single app-level media service.

`AudioService` should be an actor or otherwise have strict serialized ownership of player mutation.

State example:

```swift
enum AudioSource: Sendable, Equatable {
    case quran(QuranPlaybackContext)
    case radio(stationID: String)
}

enum PlaybackState: Sendable, Equatable {
    case idle
    case preparing
    case playing
    case paused
    case buffering
    case failed(AudioError)
}
```

Required behavior:

- only one active source
- activate `AVAudioSession` only when playback begins
- use playback category for media
- support background audio capability
- handle interruptions
- handle route changes
- handle headphones/Bluetooth/AirPlay
- update `MPNowPlayingInfoCenter`
- register `MPRemoteCommandCenter`
- cleanly remove stale metadata when playback stops

### Reconnection

For live radio:

- detect player item failure/stall
- retry with bounded exponential backoff
- attempt next stream candidate when appropriate
- stop retrying after a defined limit
- expose an understandable Retry action

Never spin an infinite reconnect loop.

---

# WIDGETS

## 19. Widget Architecture

Widgets are first-class product surfaces.

Initial widget families:

- Next Prayer
- Prayer Day
- Quran Progress
- Adhkar Progress
- Qiyam / Last Third
- optional compact Radio Now Playing / favorite station launcher where platform behavior makes sense

Use WidgetKit + App Intents.

Widgets run in a separate process. Do not assume app memory or app dependency containers are available.

Create a tiny shared module that both app and widget extension can compile.

### Shared state

Use an App Group shared container.

The widget should consume small precomputed snapshots, not reconstruct the entire app domain on every timeline request.

Example:

```swift
struct WidgetSnapshot: Codable, Sendable {
    let generatedAt: Date
    let nextPrayer: PrayerWidgetSnapshot
    let todayPrayerStatus: [PrayerWidgetStatus]
    let quranProgress: QuranWidgetProgress
    let adhkarProgress: AdhkarWidgetProgress
    let qiyam: QiyamWidgetSnapshot
}
```

Write snapshots atomically.

Widget-critical interactive state may use a small App Group shared store. Long-term history remains in the app persistence layer.

### Widget interactions

Use `AppIntent` for true interactions such as marking a prayer complete where appropriate.

Use deep links for navigation actions such as:

- open Quran reader at current page
- open Qibla
- open Morning Adhkar
- open Radio station

Do not abuse Live Activities as an all-day prayer widget.

---

# DATA & PERSISTENCE

## 20. Persistence Strategy

Use two layers:

### SwiftData

For app-owned structured history/preferences where relational queries help:

- prayer history
- bookmarks
- Quran reading history
- Quran downloads metadata
- radio favorites/history
- settings where appropriate

### App Group shared snapshot/preferences

For tiny cross-process state required by widgets/App Intents:

- current-day prayer completion projection
- next prayer snapshot
- Quran daily progress summary
- Adhkar progress summary
- Qiyam time summary
- last selected radio station ID

Do not place large Quran databases or audio files in UserDefaults.

---

## 21. Offline Strategy

Must work offline:

- previously installed Quran text/reader data
- bookmarks
- prayer calculation
- prayer tracking
- Qibla calculation after location is available
- Adhkar content
- Qiyam calculation
- widgets from the last valid snapshot
- downloaded Quran audio

Requires internet:

- live radio
- new Quran audio streams/downloads
- remote catalog refresh

When offline, retain the last station list and clearly mark radio as unavailable rather than destroying the screen state.

---

# NOTIFICATIONS

## 22. Notifications

Local notifications are owned by a dedicated `NotificationService`.

Supported reminder categories:

- prayer time
- configurable pre-prayer reminder
- Morning Adhkar
- Evening Adhkar
- Qiyam / last third
- Quran daily goal

Do not schedule redundant notification floods.

When prayer settings/location significantly change, recalculate and replace future prayer notifications deterministically.

---

# DESIGN SYSTEM

## 23. Design Implementation Rules

Centralize design values in `DesignSystem`.

Do not scatter magic colors/radii throughout features.

Map the approved Stitch design tokens into semantic SwiftUI tokens, for example:

```text
AppColor.background
AppColor.surface
AppColor.surfaceElevated
AppColor.primary
AppColor.secondaryText
AppColor.warmAccent

AppRadius.small
AppRadius.card
AppRadius.large
AppRadius.capsule
```

The current approved dark visual baseline is derived from the original Stitch Aetherial Astrolabe design, including approximately:

- graphite background around `#111413`
- sage primary around `#9DD2B3`
- elevated surfaces around `#191C1B` → `#323534`
- restrained warm accent around `#E0C298`

These values are starting tokens, not permission to hardcode hex values in feature views.

Support Light and Dark appearance through semantic token sets even if the original reference is dark-first.

Use Apple materials and Liquid Glass effects selectively; do not stack expensive blur layers everywhere.

---

# SECURITY & PRIVACY

## 24. Privacy Rules

Collect the minimum data needed.

Location is used for:

- prayer times
- Qibla

Prefer on-device calculations.

No account is required in v1.

Do not send exact location to analytics.
Do not upload prayer history.
Do not upload Quran/Adhkar reading behavior by default.

If sync is later added, it must be explicit and documented.

Use HTTPS only for remote services unless a legacy radio stream has a documented exception and App Transport Security configuration has been reviewed carefully. Prefer not to add broad ATS exceptions.

---

# TESTING

## 25. Testing Strategy

Every feature needs tests proportional to risk.

### Pure unit tests

Mandatory for:

- prayer calculations
- next-prayer selection
- Qibla bearing
- Qiyam calculations
- Quran progress
- Adhkar counters
- widget timeline projection
- radio catalog decoding/fallback order

### Integration tests

Cover:

- persistence repositories
- App Group snapshots
- notification scheduling
- radio playback state machine with mocked player events
- download state machine

### UI tests

Critical flows:

1. app launch → Today
2. mark prayer complete
3. open Quran → resume reading
4. start Quran audio → background/foreground
5. open Qibla permission state
6. complete an Adhkar counter
7. open Radio → switch station → pause/resume
8. widget deep link

### Performance tests

Track:

- launch
- Today rendering
- Surah list scrolling
- Quran reader page changes
- memory after repeated reader open/close
- radio station switching

Do not declare a feature complete because it merely compiles.

---

# AGENT WORKFLOW

## 26. Before Editing

Every coding agent must:

1. read this file
2. inspect nearby code before inventing a new pattern
3. identify the feature/domain boundary involved
4. check current Apple documentation when using unfamiliar or newly changed iOS 27 APIs
5. preserve the approved visual language
6. avoid adding dependencies without explicit justification

---

## 27. While Editing

Agents must:

- make the smallest coherent change
- use existing design-system tokens
- preserve strict concurrency correctness
- add/update tests with behavior changes
- avoid unrelated cleanup in the same change
- keep public APIs narrow
- document non-obvious architecture decisions
- keep files focused; split oversized files by responsibility

If an implementation introduces a workaround for an Apple SDK issue, include a code comment with:

- why it exists
- affected OS/Xcode version
- a removal condition

---

## 28. Definition of Done

A change is not done until all relevant checks pass:

- builds with the repository's supported Xcode toolchain
- no new compiler warnings
- tests pass
- no new concurrency warnings
- accessibility labels exist for non-text controls
- Light/Dark appearance checked where UI changed
- Dynamic Type checked for new UI
- VoiceOver order is sensible
- no obvious retain cycle
- no unbounded retry/task loop
- no forced crash primitive in production path
- offline/error behavior checked where relevant

For audio/radio work also verify:

- lock screen
- app background
- interruption (phone/Siri equivalent simulator/device scenario)
- Bluetooth/headphone route change where practical
- station failure/retry

For widget work also verify:

- app not running
- stale snapshot
- Light/Dark/Tinted appearance
- deep link target
- interactive intent state refresh

---

## 29. Things Agents Must Not Do

- Do not replace the product architecture with a new framework without approval.
- Do not convert the app to React Native, Flutter, or a web wrapper.
- Do not introduce a generic "BaseViewModel" inheritance hierarchy.
- Do not create one massive `AppState` containing every feature.
- Do not put all services into global singletons.
- Do not fetch network data from SwiftUI `body`.
- Do not keep live stream endpoints inside view code.
- Do not make radio playback depend on a visible screen.
- Do not silently modify Quran text.
- Do not use AI-generated Quran verses or Adhkar as canonical content.
- Do not add intrusive analytics or ads.
- Do not add background modes that are not justified by a real feature.
- Do not use continuous timers when timeline/date-driven UI can be calculated efficiently.

---

## 30. Current Implementation Order

Build in this sequence:

### Phase 0 — Foundation

- Xcode project
- App shell
- DesignSystem
- AppEnvironment
- router
- logging
- persistence bootstrap
- App Group
- test targets

### Phase 1 — Prayer core

- location
- prayer engine
- Today prayer card
- prayer screen
- tracker
- notifications

### Phase 2 — Quran core

- verified text dataset
- Quran home
- reader
- bookmarks/progress
- basic Quran audio

### Phase 3 — Adhkar + Qiyam + Qibla

- canonical Adhkar data
- progress
- Qiyam calculation/reminder
- Qibla sensor flow

### Phase 4 — Widgets

- Next Prayer
- Prayer Day
- Quran Progress
- Adhkar
- Qiyam
- App Intents / deep links

### Phase 5 — Radio

- remote/fallback station catalog
- Radio screen
- shared player integration
- Now Playing
- remote commands
- reconnect/fallback
- favorites
- initial verified Egyptian stations

### Phase 6 — Hardening

- Instruments
- memory leak pass
- launch performance
- offline pass
- accessibility pass
- localization structure
- device testing
- crash/hang metrics

---

## 31. Documentation References

When platform behavior is uncertain, prefer Apple documentation over blog posts.

Key areas to verify in current docs:

- WidgetKit
- App Intents widget interactivity
- AVFoundation media playback
- AVAudioSession playback/background behavior
- CoreLocation heading/location behavior
- SwiftUI Observation
- Xcode 27 release notes

For radio station availability and metadata, prefer each broadcaster's official website or official app/listing. The production catalog must keep source/licensing notes outside the UI layer.

---

## 32. Final Principle

Optimize for a product that can be trusted every day.

The priority order is:

1. correctness
2. stability
3. religious-content integrity
4. performance
5. privacy
6. accessibility
7. design fidelity
8. feature count

A smaller reliable app is better than a large fragile one.
