import 'package:flutter_modular/flutter_modular.dart';
import 'package:hitbeat/src/modules/player/audio_player.dart';
import 'package:hitbeat/src/modules/player/interfaces/metadata_extractor.dart';
import 'package:hitbeat/src/modules/player/interfaces/player.dart';
import 'package:hitbeat/src/modules/player/metadata_extractor.dart';

/// A module that provides the player dependencies
class PlayerModule extends Module {
  @override
  void exportedBinds(Injector i) {
    i
      ..addSingleton<IAudioPlayer>(AudioPlayerJustAudio.new)
      ..add<IMetadataExtractor>(MetadataExtractor.new);
  }
}
