import 'dart:io';

import 'profileable_websocket.dart';
import 'websocket_frame_event.dart';

class WebSocketProfilerSummary {
  WebSocketProfilerSummary({
    required this.connections,
    required this.events,
    required this.sentBytes,
    required this.receivedBytes,
  });

  final int connections;
  final int events;
  final int sentBytes;
  final int receivedBytes;
}

class WebSocketProfiler {
  final Map<String, ProfileableWebSocket> _connections =
      <String, ProfileableWebSocket>{};
  int _nextConnection = 1;

  Future<ProfileableWebSocket> connect(
    Uri uri, {
    Iterable<String>? protocols,
    Map<String, dynamic>? headers,
    CompressionOptions compression = CompressionOptions.compressionDefault,
    HttpClient? customClient,
    int maxBufferedEvents = 200,
  }) async {
    final raw = await WebSocket.connect(
      uri.toString(),
      protocols: protocols,
      headers: headers,
      compression: compression,
      customClient: customClient,
    );
    final connectionId = 'ws_${_nextConnection++}';
    final socket = ProfileableWebSocket(
      raw,
      connectionId: connectionId,
      maxBufferedEvents: maxBufferedEvents,
    );
    register(socket);
    return socket;
  }

  void register(ProfileableWebSocket socket) {
    _connections[socket.connectionId] = socket;
    socket.done.whenComplete(() {
      _connections.remove(socket.connectionId);
    });
  }

  List<WebSocketFrameEvent> lastEvents({int count = 10}) {
    final all = <WebSocketFrameEvent>[
      for (final socket in _connections.values) ...socket.lastEvents(count),
    ]..sort((a, b) => a.timestamp.compareTo(b.timestamp));
    if (all.length <= count) {
      return all;
    }
    return all.sublist(all.length - count);
  }

  WebSocketProfilerSummary summary() {
    var events = 0;
    var sentBytes = 0;
    var receivedBytes = 0;
    for (final socket in _connections.values) {
      for (final event in socket.lastEvents(1 << 30)) {
        events++;
        if (event.direction == WebSocketFrameDirection.sent) {
          sentBytes += event.sizeBytes;
        } else {
          receivedBytes += event.sizeBytes;
        }
      }
    }
    return WebSocketProfilerSummary(
      connections: _connections.length,
      events: events,
      sentBytes: sentBytes,
      receivedBytes: receivedBytes,
    );
  }

  void reset() {
    _connections.clear();
    _nextConnection = 1;
  }
}

