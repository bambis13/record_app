import 'dart:io';

import 'package:flutter/material.dart';
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

  Future<void> _switchRecording() async {
    if (_isRecording) {
      await recorder.stop();
    } else {
      await recorder.start(path: _recordFilePath, encoder: AudioEncoder.AAC);
    }
    bool isRecording = await recorder.isRecording();
    setState(() {
      _isRecording = isRecording;
    });
  }

  Future<void> _switchPlaying() async {
    bool isPlaying = !_isPlaying;
    setState(() {
      _isPlaying = isPlaying;
    });
  }

  @override
  void initState() {
    super.initState();
    initPermission();
    initRecorder();
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
      _recordFilePath = _recordsDirectory + 'record_app.aac';
    });
  }

  @override
  void dispose() {
    super.dispose();
    recorder.dispose();
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
