import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:websocket_devtools_profiler_sample/websocket_profiler.dart';

Future<void> main(List<String> args) async {
  final useLocalOnly = args.contains('--local');
  final endpoint = args
      .where((arg) => arg != '--local')
      .firstOrNull ??
      'wss://echo.websocket.events';
  Uri uri = Uri.parse(endpoint);
  final profiler = WebSocketProfiler();
  HttpServer? localServer;

  stdout.writeln('WebSocket Profiler Sample');
  stdout.writeln('Connecting to $uri ...');
  late final ProfileableWebSocket socket;
  if (useLocalOnly) {
    stdout.writeln('Local mode enabled. Using ws://127.0.0.1:8765');
    localServer = await _startLocalEchoServer();
    uri = Uri.parse('ws://127.0.0.1:8765');
    socket = await profiler.connect(uri);
  } else {
    try {
      socket = await profiler.connect(uri);
    } on SocketException catch (e) {
      stdout.writeln('Remote WebSocket connection failed: ${e.message}');
      stdout.writeln('Falling back to local echo server on ws://127.0.0.1:8765');
      localServer = await _startLocalEchoServer();
      uri = Uri.parse('ws://127.0.0.1:8765');
      socket = await profiler.connect(uri);
    }
  }
  final printer = TablePrinter();

  stdout.writeln('Connected! ID: ${socket.connectionId}');
  stdout.writeln('Type messages and press enter.');
  stdout.writeln('Commands: /stats  /summary  /demo  /exit');

  final sub = socket.listen((dynamic message) {
    stdout.writeln('echo: $message');
  });

  final lines = stdin.transform(utf8.decoder).transform(const LineSplitter());
  await for (final line in lines) {
    final text = line.trim();
    if (text.isEmpty) {
      continue;
    }
    if (text == '/exit') {
      await socket.close();
      await sub.cancel();
      await localServer?.close(force: true);
      break;
    }
    if (text == '/stats') {
      stdout.writeln(printer.renderEvents(profiler.lastEvents(count: 10)));
      continue;
    }
    if (text == '/summary') {
      final summary = profiler.summary();
      stdout.writeln('Summary:');
      stdout.writeln('  Connections : ${summary.connections}');
      stdout.writeln('  Events      : ${summary.events}');
      stdout.writeln('  Sent        : ${summary.sentBytes}B');
      stdout.writeln('  Received    : ${summary.receivedBytes}B');
      continue;
    }
    if (text == '/demo') {
      const demoMessages = <String>['hello', 'websocket test', '你好'];
      for (final message in demoMessages) {
        socket.add(message);
        await Future<void>.delayed(const Duration(milliseconds: 150));
      }
      stdout.writeln(printer.renderEvents(profiler.lastEvents(count: 10)));
      continue;
    }

    socket.add(text);
    await Future<void>.delayed(const Duration(milliseconds: 150));
    stdout.writeln(printer.renderEvents(profiler.lastEvents(count: 10)));
  }
}

extension on Iterable<String> {
  String? get firstOrNull => isEmpty ? null : first;
}

Future<HttpServer> _startLocalEchoServer() async {
  final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 8765);
  server.listen((HttpRequest request) async {
    if (!WebSocketTransformer.isUpgradeRequest(request)) {
      request.response
        ..statusCode = HttpStatus.badRequest
        ..write('WebSocket upgrade required');
      await request.response.close();
      return;
    }
    final ws = await WebSocketTransformer.upgrade(request);
    ws.listen(
      (dynamic message) {
        ws.add(message);
      },
      onDone: () async {
        await ws.close();
      },
    );
  });
  return server;
}
