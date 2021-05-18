import 'dart:async';


class PlayerController {
  final StreamController<bool> _playSignal = StreamController();
  final StreamController<double> _volume = StreamController();
  Stream<bool> get playSignal => _playSignal.stream;
  Stream<double> get volume => _volume.stream;

  void play() {
    _playSignal.add(true);
  }

  void pause() {
    _playSignal.add(false);
  }

  void setVolume(double vol) {
    if(vol<0){
      _volume.add(0.0);
    } else if(vol>1){
      _volume.add(1.0);
    } else {
      _volume.add(vol);
    }
  }

  void dispose() {
    _playSignal.close();
    _volume.close();
  }
}
