
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class BusTrackingScreen extends StatefulWidget {
  const BusTrackingScreen({super.key});

  @override
  State<BusTrackingScreen> createState() => _BusTrackingScreenState();
}

class _BusTrackingScreenState extends State<BusTrackingScreen> {
  bool _isLive = false;
  final _channel = WebSocketChannel.connect(
    Uri.parse('ws://localhost:3000'),
  );
  String _latestMessage = '';
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _channel.stream.listen((message) {
      setState(() {
        _latestMessage = message;
      });
    });
  }

  void _toggleLiveMode() {
    setState(() {
      _isLive = !_isLive;
      if (_isLive) {
        _startSendingLocation();
      } else {
        _stopSendingLocation();
      }
    });
  }

  void _startSendingLocation() {
    _timer = Timer.periodic(const Duration(seconds: 2), (timer) {
      // Simulate sending location data
      final locationData = '{"latitude": 12.9716, "longitude": 77.5946}';
      _channel.sink.add(locationData);
    });
  }

  void _stopSendingLocation() {
    _timer?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('Latest message from server: $_latestMessage'),
            const SizedBox(height: 20),
            SwitchListTile(
              title: const Text('Live Mode'),
              value: _isLive,
              onChanged: (value) {
                _toggleLiveMode();
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _channel.sink.close();
    _timer?.cancel();
    super.dispose();
  }
}
