import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Record App',
      theme: ThemeData(
        primarySwatch: Colors.purple,
      ),
      home: const MyHomePage(title: 'Record App'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool _isRecording = false;
  bool _isPlaying = false;
  String _recordsDirectory = '';
  String _recordFilePath = '';
  final recorder = Record();
  final player = AudioPlayer();
  final _dateFormat = DateFormat('yyyy-MM-dd-hhmmss');
  late StreamSubscription<PlayerState> _playerStateSubscription;

  Future<void> _switchRecording() async {
    if (_isRecording) {
      await recorder.stop();
    } else {
      String fileName = _dateFormat.format(DateTime.now());
      String recordFilePath = _recordsDirectory + fileName + '.aac';
      await recorder.start(path: recordFilePath, encoder: AudioEncoder.AAC);
      setState(() {
        _recordFilePath = recordFilePath;
      });
    }
    bool isRecording = await recorder.isRecording();
    setState(() {
      _isRecording = isRecording;
    });
  }

  Future<void> _switchPlaying() async {
    await player.setFilePath(_recordFilePath);
    if (_isPlaying) {
      await player.stop();
    } else {
      player.play();
    }
  }

  @override
  void initState() {
    super.initState();
    initPermission();
    initRecorder();
    initPlayer();
  }

  void initPermission() async {
    await Permission.microphone.request();
  }

  void initRecorder() async {
    final recordsDirectory =
        (await getApplicationDocumentsDirectory()).path + '/records/';
    await Directory(recordsDirectory).create(recursive: true);

    setState(() {
      _recordsDirectory = recordsDirectory;
    });
  }

  void initPlayer() async {
    _playerStateSubscription = player.playerStateStream.listen((state) {
      setState(() {
        _isPlaying = state.playing;
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    recorder.dispose();
    player.dispose();
    _playerStateSubscription.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                _isRecording ? 'Recording' : _recordFilePath,
                style: Theme.of(context).textTheme.headline6,
              ),
              TextButton(
                  onPressed: _switchPlaying,
                  child: _isPlaying ? const Text('stop') : const Text('play'))
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
            onPressed: _switchRecording,
            tooltip: _isRecording ? 'stop' : 'start',
            child: _isRecording
                ? const Icon(Icons.stop_rounded)
                : const Icon(Icons.fiber_manual_record)));
  }
}
