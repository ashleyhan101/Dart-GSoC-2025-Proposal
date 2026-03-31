enum WebSocketFrameDirection { sent, received }

enum WebSocketFrameType { text, binary, unknown }

class WebSocketFrameEvent {
  WebSocketFrameEvent({
    required this.id,
    required this.connectionId,
    required this.timestamp,
    required this.direction,
    required this.type,
    required this.sizeBytes,
    required this.elapsed,
    required this.payloadPreview,
  });

  final int id;
  final String connectionId;
  final DateTime timestamp;
  final WebSocketFrameDirection direction;
  final WebSocketFrameType type;
  final int sizeBytes;
  final Duration elapsed;
  final String payloadPreview;

  Map<String, Object> toJson() {
    return {
      'id': id,
      'connectionId': connectionId,
      'timestamp': timestamp.toIso8601String(),
      'direction': direction.name,
      'type': type.name,
      'sizeBytes': sizeBytes,
      'elapsedMs': elapsed.inMilliseconds,
      'payloadPreview': payloadPreview,
    };
  }
}

