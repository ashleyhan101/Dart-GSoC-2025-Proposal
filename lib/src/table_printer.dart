import 'websocket_frame_event.dart';

class TablePrinter {
  String renderEvents(List<WebSocketFrameEvent> events) {
    final buffer = StringBuffer()
      ..writeln(
        '-------------------------------------------------------------------------------',
      )
      ..writeln('ID   TIME         DIR      TYPE     BYTES   ELAPSED   PREVIEW')
      ..writeln(
        '-------------------------------------------------------------------------------',
      );

    for (final event in events) {
      final time = event.timestamp.toIso8601String().substring(11, 23);
      final dir = event.direction == WebSocketFrameDirection.sent ? 'sent' : 'recv';
      final type = event.type.name;
      final bytes = '${event.sizeBytes}B';
      final elapsed = '+${event.elapsed.inMilliseconds}ms';
      buffer.writeln(
        '${event.id.toString().padRight(4)} '
        '${time.padRight(12)} '
        '${dir.padRight(8)} '
        '${type.padRight(8)} '
        '${bytes.padRight(7)} '
        '${elapsed.padRight(9)} '
        '${event.payloadPreview}',
      );
    }

    buffer.writeln(
      '-------------------------------------------------------------------------------',
    );
    return buffer.toString();
  }
}

