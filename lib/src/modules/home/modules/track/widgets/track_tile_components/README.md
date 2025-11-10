# Track Tile Components

This directory contains the modular components that make up the `TrackListTileEnhanced` widget.

## Component Architecture

The track tile has been split into focused, single-responsibility components:

### Core Components

- **`track_tile_container.dart`** - Outer container with styling (shadows, borders, margins)
- **`track_tile_content.dart`** - Main content layout orchestrator with interaction handling

### Display Components

- **`track_album_avatar.dart`** - Album cover image with pulse animation for playing tracks
- **`track_number_indicator.dart`** - Track number or equalizer icon for playing state
- **`track_info_section.dart`** - Track name, artist, and album information display
- **`track_duration.dart`** - Duration formatter and display
- **`track_action_button.dart`** - Play/pause button with hover animation

## Component Flow

```
TrackListTileEnhanced (main orchestrator)
  └─ TrackTileContainer (styling wrapper)
      └─ TrackTileContent (layout & interaction)
          ├─ TrackNumberIndicator
          ├─ TrackAlbumAvatar
          ├─ TrackInfoSection
          ├─ TrackDuration
          └─ TrackActionButton
```

## Usage

The main widget `TrackListTileEnhanced` handles:
- Animation controllers for hover/press effects
- Stream subscriptions to player state
- Composition of all sub-components

All visual components are independent and can be:
- Tested in isolation
- Reused in other contexts
- Modified without affecting other parts

## Design Decisions

1. **Public vs Private**: Components in this directory are public to allow testing and potential reuse. The main widget state class remains private.

2. **State Management**: Only stateful components (`TrackAlbumAvatar`) maintain their own state. Others are stateless and receive props from parent.

3. **Theme Access**: All components access theme via `Theme.of(context)` rather than passing theme as props.

4. **Naming**: Prefixed with "Track" to namespace them and indicate their domain.
