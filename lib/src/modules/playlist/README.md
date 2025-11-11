# Playlist Module

This module provides playlist management functionality for HitBeat, including the ability to create, edit, and delete playlists, as well as automatic persistence of the current playing queue.

## Features

### User Playlists
- Create custom playlists with name and description
- Add/remove tracks from playlists
- Delete playlists
- View all playlists with track counts

### Current Queue Persistence
The module includes a special "current queue" playlist that automatically saves the playing queue to the database. This means:
- When you close the app, your current queue is saved
- When you reopen the app, your queue is restored exactly as it was
- The queue is updated automatically as you add or remove tracks

## Database Schema

### Playlists Table
- `id`: Primary key
- `name`: Playlist name
- `description`: Optional description
- `is_special`: Flag for system playlists (like current queue)
- `created_at`: Creation timestamp
- `updated_at`: Last modification timestamp

### PlaylistTracks Table
- `playlist_id`: Reference to playlist
- `track_id`: Reference to track
- `position`: Track position in playlist (0-based)
- Primary key: `(playlist_id, track_id, position)`

## Services

### PlaylistService
Main service for playlist operations:
- `createPlaylist({name, description})`: Create a new playlist
- `getAllPlaylists()`: Get all user playlists
- `getPlaylistById(id)`: Get a specific playlist with tracks
- `updatePlaylist({id, name, description})`: Update playlist details
- `deletePlaylist(id)`: Delete a playlist
- `addTrackToPlaylist({playlistId, trackId, position})`: Add track
- `removeTrackFromPlaylist({playlistId, trackId, position})`: Remove track
- `clearPlaylist(playlistId)`: Clear all tracks from playlist

### Queue Operations
- `getCurrentQueue()`: Get the current queue playlist
- `saveCurrentQueue(tracks)`: Save the playing queue
- `loadCurrentQueue()`: Load the saved queue
- `addToCurrentQueue(trackId)`: Add track to queue
- `clearCurrentQueue()`: Clear the queue

### QueuePersistenceService
Automatically manages queue persistence:
- Listens to audio player tracklist changes
- Debounces saves (2 second delay) to avoid excessive DB writes
- Loads saved queue on app startup
- `initialize()`: Start the service
- `saveNow()`: Manually trigger an immediate save
- `dispose()`: Clean up resources

## Usage

### Creating a Playlist
```dart
final playlistService = Modular.get<PlaylistService>();
final playlistId = await playlistService.createPlaylist(
  name: 'My Favorites',
  description: 'My favorite songs',
);
```

### Adding Tracks to a Playlist
```dart
await playlistService.addTrackToPlaylist(
  playlistId: playlistId,
  trackId: trackId,
  position: 0, // Optional, defaults to end
);
```

### Working with the Current Queue
The queue is automatically managed, but you can also interact with it directly:

```dart
// Save current player state
final audioPlayer = Modular.get<IAudioPlayer>();
await playlistService.saveCurrentQueue(audioPlayer.tracklist);

// Load saved queue
final tracks = await playlistService.loadCurrentQueue();
audioPlayer.concatTracks(tracks);
```

### Queue Persistence Integration
The `QueuePersistenceService` is automatically initialized in `AppWidget` and:
1. Loads the saved queue on startup
2. Listens to tracklist changes
3. Automatically saves after 2 seconds of inactivity

To manually save (e.g., before app close):
```dart
final queuePersistence = Modular.get<QueuePersistenceService>();
await queuePersistence.saveNow();
```

## Migration

This module introduces schema version 2 with the following changes:
- Added `Playlists` table
- Added `PlaylistTracks` junction table

The migration is handled automatically by Drift when the app runs with the new schema.

## UI Components

### PlaylistPage
Main page showing all user playlists with:
- Create button in app bar
- Empty state with call-to-action
- List of playlists with track counts
- Delete functionality
- Placeholder for navigation to playlist detail

### Future Enhancements
- Playlist detail page with track list
- Drag-and-drop reordering of tracks
- Playlist cover art
- Share playlists
- Import/export playlists
- Smart playlists based on criteria
