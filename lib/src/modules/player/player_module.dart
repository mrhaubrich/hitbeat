import 'package:flutter_modular/flutter_modular.dart';
import 'package:hitbeat/src/modules/player/audio_player_soloud.dart';
import 'package:hitbeat/src/modules/player/interfaces/metadata_extractor.dart';
import 'package:hitbeat/src/modules/player/interfaces/player.dart';
import 'package:hitbeat/src/modules/player/metadata_extractor.dart';
import 'package:hitbeat/src/services/cover_cache_service.dart';
// import 'audio_player_soloud.dart'; // Uncomment to switch to SoLoud backend

/// A module that provides the player dependencies
class PlayerModule extends Module {
  @override
  void exportedBinds(Injector i) {
    i
      // To switch to SoLoud backend, replace the following line with:
      ..addSingleton<IAudioPlayer>(AudioPlayerSoLoud.new)
      // ..addSingleton<IAudioPlayer>(AudioPlayerJustAudio.new)
      ..addSingleton<IMetadataExtractor>(MetadataExtractor.new)
      ..add<CoverCacheService>(CoverCacheService.new);
  }
}
