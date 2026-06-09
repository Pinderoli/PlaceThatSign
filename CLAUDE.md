# PlaceThatSign — Project Context for Claude

## What this app is

PlaceThatSign is an iOS app that lets users place virtual signs anchored to real-world GPS
coordinates, visible in AR. Inspired by Minecraft sign culture (2b2t servers) — short,
human messages left for strangers. "Jeff was here." "Lots of mud ahead." "I made it! 2026."

The AR layer is what makes it special: instead of scrolling a list of nearby posts, you
physically look around and see signs floating in the world at a distance.

## Developer

Oliver Pinder — Computer Science student, University of Kent.
Mac Mini M4, iPhone 17, Xcode 26.3+, macOS 26.2+.
GitHub: https://github.com/Pinderoli/PlaceThatSign

## Tech stack

- **Language**: Swift (SwiftUI for UI)
- **AR**: ARKit + RealityKit, ARGeoAnchor for GPS-to-AR coordinate bridging
- **Location**: CoreLocation
- **Backend**: Supabase (Swift SDK v2.47.0 via SPM)
- **Database**: PostgreSQL + PostGIS (geospatial radius queries)
- **Version control**: Git, GitHub (main branch)

## Build order (Phase 1 MVP — focus here)

1. SwiftUI app skeleton — navigation, "Place Sign" button, sign list view
2. CoreLocation integration — get and display live GPS coordinates
3. ARKit + ARGeoAnchor — place a hardcoded floating text sign at a fixed GPS coordinate
4. Backend + real data — once AR sign placement is working with fake data, wire to DB

Do NOT think about Phase 2 or 3 yet. Ship Phase 1 first.

## Architecture (Phase 1)

```
iOS App (SwiftUI + CoreLocation)
    ↓ renders via
ARKit + RealityKit (ARGeoAnchor — GPS coordinate → AR world anchor)
    ↓ fetches/posts signs from
Backend API (REST)
    ↓ stores in
PostgreSQL + PostGIS (lat/lng + radius query)
```

## Key technical note — GPS to AR bridge

ARKit's `ARGeoAnchor` is the core primitive. It accepts a CLLocationCoordinate2D and places
an AR anchor at that real-world GPS position. Requires iPhone with A12 chip or newer and
LiDAR is not required. This is supported natively on iPhone 17.

Do NOT try to manually convert GPS → local AR coordinates. Use ARGeoAnchor.

## Sign data model (working draft)

```swift
struct Sign: Identifiable, Codable {
    let id: UUID
    let latitude: Double
    let longitude: Double
    let message: String       // short, Minecraft-style
    let author: String        // "Oliver" or anonymous
    let createdAt: Date
}
```

## Current project state

- Xcode project at: ~/Documents/Home/XCode/PlaceThatSign/ (created 2026-06-08)
- GitHub repo live on main branch with clean .gitignore

**Phase 1, Step 1 — DONE**: SwiftUI app skeleton
- 3-tab `TabView` in `ContentView`: "My Signs" (tag 0), "AR" (tag 1, default), "Settings" (tag 2)
- `LocationService`, `SignService`, and `SupabaseService` instantiated in `ContentView`, injected as `@Observable` environment objects

**Phase 1, Step 2 — DONE**: CoreLocation integration
- `LocationService` requests `whenInUse` authorisation, publishes live `coordinate: CLLocationCoordinate2D?`
- Also exposes `authorizationStatus: CLAuthorizationStatus`
- Live GPS coordinate overlay displayed in `ARSignView` (shows "Acquiring GPS…" until fix)

**Phase 1, Step 3 — IN PROGRESS**: ARKit / ARGeoAnchor
- `ARSignView` still shows a black screen placeholder ("AR view coming soon") — no ARKit/RealityKit rendering yet
- "Place Sign" button IS wired up: opens `PlaceSignSheet` modal (message input, char count, validation)
- `placeSign()` calls `signService.place()` locally and fires a `SupabaseService.insertSign()` Task
- Error alert shown if placement rules are violated
- **Still needed**: Replace black screen with a real `ARView`/`ARGeoTrackingConfiguration`, add `ARGeoAnchor` per sign, render floating text entity in RealityKit

**Phase 1, Step 4 — IN PROGRESS**: Backend / real data
- `SupabaseService` fully scaffolded (`SupabaseService.swift`):
  - `insertSign()` — inserts a new sign row; called immediately on successful local placement
  - `fetchNearbySigns()` — fetches all rows and filters client-side by radius; **implemented but never called yet**
- Supabase Swift SDK v2.47.0 added via SPM
- Credentials injected via `Secrets.xcconfig` (gitignored) → `Info.plist` → `Bundle.main`; `Secrets.xcconfig.example` checked in as a template
- `SignService` still seeds 3 hardcoded signs on init (Canterbury/Kent coords) — no fetch-on-launch yet
- **Still needed**: Call `fetchNearbySigns()` on app launch / location fix to populate `SignService.signs` from Supabase; replace client-side radius filter with a PostGIS RPC once data grows
- Placement validation rules in `SignService`: 100-char message limit, 3 signs/day cap, 50 m minimum spacing — currently bypassed by `enforcePlacementLimits = false` dev toggle

**Other completed views/files**:
- `MySignsView` — segmented list/map picker; list shows message + lat/lng; map uses MapKit `Marker` + `UserAnnotation`
- `SettingsView` — static "Oliver" author name, version 0.1.0
- `Sign.swift` — model with `CodingKeys` mapping `createdAt` ↔ `created_at` for Supabase compatibility; `maxMessageLength = 100` static constant

## Naming conventions

- SwiftUI views: PascalCase, suffix `View` (e.g. `SignListView`, `ARSignView`)
- Models: PascalCase, no suffix (e.g. `Sign`, `UserLocation`)
- ViewModels: suffix `ViewModel` (e.g. `SignListViewModel`)
- Services: suffix `Service` (e.g. `LocationService`, `SignService`)

## Future phases (do not build yet — context only)

**Phase 2**: Proximity push notifications (CoreLocation geofencing), community voting
(upvote/flag), user accounts + auth.

Future — LiDAR surface snapping: On LiDAR devices use ARWorldTrackingConfiguration scene reconstruction to snap signs to real surfaces. Non-LiDAR devices get floating anchors at fixed height.

Auth approach: Passkeys via Apple's ASAuthorization framework + Supabase Auth WebAuthn. No email/password. Face ID on first launch generates a persistent user identity. device_id is the Phase 1 placeholder.

**Phase 3**: Premium sign skins (StoreKit 2), sign boosting (larger radius, ping nearby
users), Apple Vision Pro / Meta support via RealityKit visionOS target.

## What NOT to do

- Don't use MapKit as a substitute for AR — the AR view is the primary interface
- Don't manually convert GPS coordinates to AR space — use ARGeoAnchor
- Don't add server-side PostGIS queries or auth before AR is working end-to-end
- Don't add Phase 2/3 features before Phase 1 is solid
