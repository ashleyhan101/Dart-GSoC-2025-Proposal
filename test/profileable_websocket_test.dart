import 'dart:async';
import 'dart:io';

import 'package:test/test.dart';
import 'package:websocket_devtools_profiler_sample/websocket_profiler.dart';

void main() {
  test('event model toJson contains key fields', () {
    final event = WebSocketFrameEvent(
      id: 1,
      connectionId: 'ws_1',
      timestamp: DateTime.parse('2026-03-31T12:00:00.000Z'),
      direction: WebSocketFrameDirection.sent,
      type: WebSocketFrameType.text,
      sizeBytes: 5,
      elapsed: const Duration(milliseconds: 10),
      payloadPreview: 'hello',
    );

    final json = event.toJson();
    expect(json['id'], 1);
    expect(json['connectionId'], 'ws_1');
    expect(json['direction'], 'sent');
    expect(json['type'], 'text');
    expect(json['sizeBytes'], 5);
    expect(json['elapsedMs'], 10);
  });

  test('records sent event from add', () {
    final fake = FakeWebSocket();
    final socket = ProfileableWebSocket(fake, connectionId: 'ws_1');

    socket.add('hello');

    final events = socket.lastEvents();
    expect(events, hasLength(1));
    expect(events.single.direction, WebSocketFrameDirection.sent);
    expect(events.single.type, WebSocketFrameType.text);
    expect(events.single.sizeBytes, 5);
  });

  test('records received event through listen', () async {
    final fake = FakeWebSocket();
    final socket = ProfileableWebSocket(fake, connectionId: 'ws_1');
    final received = <dynamic>[];
    final sub = socket.listen(received.add);

    fake.emitIncoming('pong');
    await Future<void>.delayed(Duration.zero);
    await sub.cancel();

    expect(received, ['pong']);
    final events = socket.lastEvents();
    expect(events.last.direction, WebSocketFrameDirection.received);
  });

  test('keeps event order', () async {
    final fake = FakeWebSocket();
    final socket = ProfileableWebSocket(fake, connectionId: 'ws_1');
    final sub = socket.listen((_) {});

    socket.add('a');
    fake.emitIncoming('b');
    await Future<void>.delayed(Duration.zero);
    await sub.cancel();

    final events = socket.lastEvents();
    expect(events.map((e) => e.direction), [
      WebSocketFrameDirection.sent,
      WebSocketFrameDirection.received,
    ]);
  });

  test('lastEvents(n) returns newest subset', () {
    final fake = FakeWebSocket();
    final socket = ProfileableWebSocket(
      fake,
      connectionId: 'ws_1',
      maxBufferedEvents: 50,
    );

    for (var i = 0; i < 12; i++) {
      socket.add('m$i');
    }
    final subset = socket.lastEvents(5);

    expect(subset, hasLength(5));
    expect(subset.first.id, 8);
    expect(subset.last.id, 12);
  });

  test('frameEvents stream emits in real time', () async {
    final fake = FakeWebSocket();
    final socket = ProfileableWebSocket(fake, connectionId: 'ws_1');
    final emitted = <WebSocketFrameEvent>[];
    final sub = socket.frameEvents.listen(emitted.add);

    socket.add('x');
    await Future<void>.delayed(Duration.zero);
    await sub.cancel();

    expect(emitted, hasLength(1));
    expect(emitted.single.sizeBytes, 1);
  });

  test('sizeBytes uses utf8 length for text', () {
    final fake = FakeWebSocket();
    final socket = ProfileableWebSocket(fake, connectionId: 'ws_1');

    socket.add('你好');
    final event = socket.lastEvents().single;

    expect(event.sizeBytes, 6);
  });

  test('registry summary and reset work', () async {
    final profiler = WebSocketProfiler();
    final fake = FakeWebSocket();
    final socket = ProfileableWebSocket(fake, connectionId: 'ws_1');
    profiler.register(socket);
    final sub = socket.listen((_) {});

    socket.add('abc');
    fake.emitIncoming('xy');
    await Future<void>.delayed(Duration.zero);

    final summary = profiler.summary();
    expect(summary.connections, 1);
    expect(summary.events, 2);
    expect(summary.sentBytes, 3);
    expect(summary.receivedBytes, 2);

    sub.cancel();
    profiler.reset();
    expect(profiler.summary().connections, 0);
  });

  test('registry lastEvents keeps chronological order across sockets', () async {
    final profiler = WebSocketProfiler();
    final socketA = ProfileableWebSocket(FakeWebSocket(), connectionId: 'ws_1');
    final socketB = ProfileableWebSocket(FakeWebSocket(), connectionId: 'ws_2');
    profiler.register(socketA);
    profiler.register(socketB);

    socketA.add('a');
    await Future<void>.delayed(const Duration(milliseconds: 1));
    socketB.add('b');

    final events = profiler.lastEvents(count: 10);
    expect(events, hasLength(2));
    expect(events.first.payloadPreview, 'a');
    expect(events.last.payloadPreview, 'b');
  });
}

class FakeWebSocket extends Stream<dynamic> implements WebSocket {
  final StreamController<dynamic> _controller = StreamController<dynamic>();
  final List<dynamic> sent = <dynamic>[];
  final Completer<void> _done = Completer<void>();

  Duration? _pingInterval;
  int _readyState = WebSocket.open;
  int? _closeCode;
  String? _closeReason;

  void emitIncoming(dynamic event) {
    _controller.add(event);
  }

  @override
  StreamSubscription<dynamic> listen(
    void Function(dynamic event)? onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) {
    return _controller.stream.listen(
      onData,
      onError: onError,
      onDone: onDone,
      cancelOnError: cancelOnError,
    );
  }

  @override
  void add(dynamic event) {
    sent.add(event);
  }

  @override
  void addUtf8Text(List<int> bytes) {
    sent.add(bytes);
  }

  @override
  void addError(Object error, [StackTrace? stackTrace]) {}

  @override
  Future<void> addStream(Stream stream) async {
    await for (final event in stream) {
      add(event);
    }
  }

  @override
  Future close([int? closeCode, String? closeReason]) async {
    _readyState = WebSocket.closed;
    _closeCode = closeCode;
    _closeReason = closeReason;
    if (!_done.isCompleted) {
      _done.complete();
    }
    await _controller.close();
  }

  @override
  Future get done => _done.future;

  @override
  int? get closeCode => _closeCode;

  @override
  String? get closeReason => _closeReason;

  @override
  String get extensions => '';

  @override
  Duration? get pingInterval => _pingInterval;

  @override
  set pingInterval(Duration? interval) {
    _pingInterval = interval;
  }

  @override
  String? get protocol => '';

  @override
  int get readyState => _readyState;
}
