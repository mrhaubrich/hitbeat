import 'package:flutter_modular/flutter_modular.dart';
import 'package:hitbeat/src/modules/player/audio_player.dart';
import 'package:hitbeat/src/modules/player/interfaces/player.dart';

class PlayerModule extends Module {
  @override
  void exportedBinds(Injector i) {
    i.addSingleton<IAudioPlayer>(AudioPlayerJustAudio.new);
  }
}
