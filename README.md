# websocket_devtools_profiler_sample

Sample project for the Dart GSoC idea:
Add WebSocket support to the Flutter DevTools Network panel.

## What this sample demonstrates

- A `ProfileableWebSocket` wrapper that intercepts:
  - outgoing frames via `add` / `addUtf8Text`
  - incoming frames via `listen`
- A typed `WebSocketFrameEvent` model.
- A small in-memory event buffer.
- A `WebSocketProfiler` registry for tracking multiple connections.
- A CLI demo that sends messages and prints the last events table.
- Unit tests using a mock WebSocket.

## Run

```bash
dart pub get
dart test
dart run bin/main.dart
```

Force local-only mode (no external DNS/network dependency):

```bash
dart run bin/main.dart --local
```

Default echo endpoint:
`wss://echo.websocket.events`

If DNS or internet access is unavailable, the CLI automatically falls back
to a local echo server at `ws://127.0.0.1:8765`.

## CLI commands

- Any text: send a message.
- `/stats`: print recent events.
- `/summary`: print connection and byte totals.
- `/demo`: send preset messages (`hello`, `websocket test`, `你好`) and print stats.
- `/exit`: close and exit.
