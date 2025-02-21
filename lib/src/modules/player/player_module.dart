import 'package:flutter_modular/flutter_modular.dart';
import 'package:hitbeat/src/modules/player/audio_player.dart';
import 'package:hitbeat/src/modules/player/interfaces/metadata_extractor.dart';
import 'package:hitbeat/src/modules/player/interfaces/player.dart';
import 'package:hitbeat/src/modules/player/metadata_extractor.dart';
import 'package:hitbeat/src/services/cover_cache_service.dart';

/// A module that provides the player dependencies
class PlayerModule extends Module {
  @override
  void exportedBinds(Injector i) {
    i
      ..addSingleton<IAudioPlayer>(AudioPlayerJustAudio.new)
      ..addSingleton<IMetadataExtractor>(MetadataExtractor.new)
      ..add<CoverCacheService>(CoverCacheService.new);
  }
}
