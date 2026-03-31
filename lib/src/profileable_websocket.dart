import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'websocket_frame_event.dart';

class ProfileableWebSocket extends Stream<dynamic> implements WebSocket {
  ProfileableWebSocket(
    this._inner, {
    required this.connectionId,
    this.maxBufferedEvents = 200,
  }) : _startedAt = DateTime.now();

  final WebSocket _inner;
  final DateTime _startedAt;
  final List<WebSocketFrameEvent> _buffer = <WebSocketFrameEvent>[];
  final StreamController<WebSocketFrameEvent> _eventController =
      StreamController<WebSocketFrameEvent>.broadcast();

  final String connectionId;
  final int maxBufferedEvents;
  int _nextEventId = 1;

  Stream<WebSocketFrameEvent> get frameEvents => _eventController.stream;

  List<WebSocketFrameEvent> lastEvents([int count = 10]) {
    if (count <= 0) {
      return <WebSocketFrameEvent>[];
    }
    if (_buffer.length <= count) {
      return List<WebSocketFrameEvent>.from(_buffer);
    }
    return _buffer.sublist(_buffer.length - count);
  }

  @override
  StreamSubscription<dynamic> listen(
    void Function(dynamic event)? onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) {
    return _inner.listen(
      (dynamic event) {
        _record(WebSocketFrameDirection.received, event);
        if (onData != null) {
          onData(event);
        }
      },
      onError: onError,
      onDone: onDone,
      cancelOnError: cancelOnError,
    );
  }

  @override
  void add(dynamic event) {
    _record(WebSocketFrameDirection.sent, event);
    _inner.add(event);
  }

  @override
  void addUtf8Text(List<int> bytes) {
    _record(WebSocketFrameDirection.sent, bytes);
    _inner.addUtf8Text(bytes);
  }

  @override
  void addError(Object error, [StackTrace? stackTrace]) {
    _inner.addError(error, stackTrace);
  }

  @override
  Future<void> addStream(Stream<dynamic> stream) => _inner.addStream(stream);

  @override
  Future close([int? closeCode, String? closeReason]) =>
      _inner.close(closeCode, closeReason);

  @override
  Future get done => _inner.done;

  @override
  String get extensions => _inner.extensions;

  @override
  int? get closeCode => _inner.closeCode;

  @override
  String? get closeReason => _inner.closeReason;

  @override
  String? get protocol => _inner.protocol;

  @override
  int get readyState => _inner.readyState;

  @override
  Duration? get pingInterval => _inner.pingInterval;

  @override
  set pingInterval(Duration? pingInterval) {
    _inner.pingInterval = pingInterval;
  }

  void _record(WebSocketFrameDirection direction, dynamic event) {
    final now = DateTime.now();
    final frameType = _typeFor(event);
    final size = _sizeFor(event);
    final loggedEvent = WebSocketFrameEvent(
      id: _nextEventId++,
      connectionId: connectionId,
      timestamp: now,
      direction: direction,
      type: frameType,
      sizeBytes: size,
      elapsed: now.difference(_startedAt),
      payloadPreview: _previewFor(event),
    );

    _buffer.add(loggedEvent);
    if (_buffer.length > maxBufferedEvents) {
      _buffer.removeAt(0);
    }
    _eventController.add(loggedEvent);
  }

  WebSocketFrameType _typeFor(dynamic event) {
    if (event is String) {
      return WebSocketFrameType.text;
    }
    if (event is List<int> || event is Uint8List || event is ByteBuffer) {
      return WebSocketFrameType.binary;
    }
    return WebSocketFrameType.unknown;
  }

  int _sizeFor(dynamic event) {
    if (event is String) {
      return utf8.encode(event).length;
    }
    if (event is Uint8List) {
      return event.lengthInBytes;
    }
    if (event is ByteBuffer) {
      return event.lengthInBytes;
    }
    if (event is List<int>) {
      return event.length;
    }
    return utf8.encode(event.toString()).length;
  }

  String _previewFor(dynamic event) {
    const limit = 48;
    final text = switch (event) {
      String value => value,
      Uint8List value => 'binary(${value.lengthInBytes}B)',
      ByteBuffer value => 'binary(${value.lengthInBytes}B)',
      List<int> value => 'binary(${value.length}B)',
      _ => event.toString(),
    };
    if (text.length <= limit) {
      return text;
    }
    return '${text.substring(0, limit)}...';
  }
}
