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
- **Backend**: TBD (Supabase or lightweight Vapor/Node API)
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

- Xcode project created at: ~/Documents/Coding/XCode/PlaceThatSign/
- GitHub repo initialised and pushed (main branch, clean .gitignore)
- Default SwiftUI template in place (ContentView.swift, PlaceThatSignApp.swift)
- No custom code written yet — starting from scratch

## Naming conventions

- SwiftUI views: PascalCase, suffix `View` (e.g. `SignListView`, `ARSignView`)
- Models: PascalCase, no suffix (e.g. `Sign`, `UserLocation`)
- ViewModels: suffix `ViewModel` (e.g. `SignListViewModel`)
- Services: suffix `Service` (e.g. `LocationService`, `SignService`)

## Future phases (do not build yet — context only)

**Phase 2**: Proximity push notifications (CoreLocation geofencing), community voting
(upvote/flag), user accounts + auth.

**Phase 3**: Premium sign skins (StoreKit 2), sign boosting (larger radius, ping nearby
users), Apple Vision Pro / Meta support via RealityKit visionOS target.

## What NOT to do

- Don't use MapKit as a substitute for AR — the AR view is the primary interface
- Don't manually convert GPS coordinates to AR space — use ARGeoAnchor
- Don't build a backend before AR is working with hardcoded data
- Don't add Phase 2/3 features before Phase 1 is solid
