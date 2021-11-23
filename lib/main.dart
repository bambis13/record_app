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
  final recorder = Record();

  Future<void> _switchRecording() async {
    final appDirectory = (await getApplicationDocumentsDirectory()).path;
    final recordsDirectory = '$appDirectory/records';

    File(recordsDirectory).create(recursive: true);
    if (_isRecording) {
      await recorder.stop();
    } else {
      await recorder.start(path: '$recordsDirectory/record_app.mp4');
    }
    bool isRecording = await recorder.isRecording();
    setState(() {
      _isRecording = isRecording;
    });
  }

  @override
  void initState() {
    super.initState();
    initPermission();
  }

  void initPermission() async {
    await Permission.microphone.request();
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
                _isRecording ? 'Recording' : 'Not Recording',
                style: Theme.of(context).textTheme.headline4,
              ),
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
