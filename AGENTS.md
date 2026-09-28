# Repository Guidelines

## Project Structure & Module Organization

`LiveWallpaper/` contains the SwiftUI macOS application. The add-wallpaper workflow is grouped under `AddWallPaperScene/`, with drop-zone and editor code in its nested folders. Keep reusable UI in `Components/`, screen-level views in `Views/`, shared state and long-lived services in `Singletons/`, and utility code in `Helpers/`. Images and colors belong in `Assets.xcassets`; bundled ambient audio belongs in `Sounds/`. The app entry point is `LiveWallpaper/LiveWallpaperApp.swift`, while `AppConstant.swift` holds repository-wide constants. Xcode configuration, the shared scheme, signing, and deployment settings live in `LiveWallpaper.xcodeproj`. There is currently no test target.

## Design Work

For any task involving:

- UI/UX design
- SwiftUI view design
- layout changes
- visual styling
- component design
- interaction design
- screen redesign
- Penpot design work

use the project's Design skill before making changes.

The documents under `Design/` are the source of truth for the
LiveWallpaper design language.

Do not infer the intended design direction solely from existing
implementation.

## Coding Style & Naming Conventions

Use four-space indentation and standard Swift API design conventions. Name types in `UpperCamelCase`, properties and functions in `lowerCamelCase`, and SwiftUI components with a `View` suffix. Keep view bodies declarative; place workflow state in view models or sessions and media, persistence, and window behavior in focused managers. Prefer `private` for implementation details. No formatter or linter is configured, so use Xcode's Re-Indent command and follow nearby code.

## Security & Assets

Preserve the app sandbox and least-privilege entitlements. Do not commit personal media, credentials, provisioning profiles, or generated build output. Confirm new bundled sounds and images have suitable redistribution licenses and reasonable file sizes.
