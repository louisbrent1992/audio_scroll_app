import 'package:just_audio/just_audio.dart';
import 'dart:async';

class AudioPlayerService {
  final AudioPlayer _audioPlayer = AudioPlayer();
  StreamSubscription<Duration>? _positionSubscription;
  StreamSubscription<Duration>? _durationSubscription;
  StreamSubscription<PlayerState>? _playerStateSubscription;
  
  // Streams
  Stream<Duration> get positionStream => _audioPlayer.positionStream;
  Stream<Duration?> get durationStream => _audioPlayer.durationStream;
  Stream<PlayerState> get playerStateStream => _audioPlayer.playerStateStream;
  
  // Current state
  Duration get currentPosition => _audioPlayer.position;
  Duration? get duration => _audioPlayer.duration;
  bool get isPlaying => _audioPlayer.playing;
  bool get isPaused => !_audioPlayer.playing;
  
  // Playback speed
  double _playbackSpeed = 1.0;
  double get playbackSpeed => _playbackSpeed;
  
  Future<void> loadAudio(String url) async {
    try {
      await _audioPlayer.setUrl(url);
    } catch (e) {
      throw Exception('Failed to load audio: $e');
    }
  }
  
  Future<void> play() async {
    await _audioPlayer.play();
  }
  
  Future<void> pause() async {
    await _audioPlayer.pause();
  }
  
  Future<void> stop() async {
    await _audioPlayer.stop();
  }
  
  Future<void> seek(Duration position) async {
    await _audioPlayer.seek(position);
  }
  
  Future<void> setSpeed(double speed) async {
    _playbackSpeed = speed;
    await _audioPlayer.setSpeed(speed);
  }
  
  Future<void> dispose() async {
    await _positionSubscription?.cancel();
    await _durationSubscription?.cancel();
    await _playerStateSubscription?.cancel();
    await _audioPlayer.dispose();
  }
}

