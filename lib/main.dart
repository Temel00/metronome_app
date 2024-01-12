import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:audio_session/audio_session.dart';
import 'dart:developer' as devtools show log;

void main() {
  runApp(MaterialApp(
    title: 'Flutter Demo',
    theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
        sliderTheme: const SliderThemeData(
            showValueIndicator: ShowValueIndicator.always)),
    home: const HomePage(),
  ));
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

Future<void> _configureAudioSession() async {
  final audioSession = await AudioSession.instance;
  await audioSession.configure(const AudioSessionConfiguration.music());
}

class _HomePageState extends State<HomePage> {
  final _player = AudioPlayer();
  bool _isPlaying = false;
  double _speed = 1.0; // Initial speed

  @override
  void initState() {
    _configureAudioSession();
    _loadAudio();
    super.initState();
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  Future<void> _loadAudio() async {
    await _player
        .setAsset('assets/ClickThree.mp3')
        .then((value) => devtools.log('$value'));
  }

  void _playOrPause() async {
    if (_isPlaying) {
      await _player.pause();
    } else {
      try {
        _player.setLoopMode(LoopMode.one);
        await _player.play();
        // Enable looping
      } catch (e) {
        devtools.log('Error in playPause: $e');
      }
    }
    setState(() => _isPlaying = !_isPlaying);
  }

  void _stop() async {
    await _player.stop();
    setState(() => _isPlaying = false);
  }

  void _adjustSpeed(double newSpeed) {
    _player.setSpeed(newSpeed);
    setState(() => _speed = newSpeed);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home Title')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: _playOrPause,
              child: Text(_isPlaying ? 'Pause' : 'Play'),
            ),
            ElevatedButton(
              onPressed: _stop,
              child: const Text('Stop'),
            ),
            Slider(
              value: _speed,
              min: 0.5,
              max: 2.0,
              onChanged: _adjustSpeed,
              label: (_speed * 50).roundToDouble().toString(),
              thumbColor: Colors.blue,
            ),
          ],
        ),
      ),
    );
  }
}
