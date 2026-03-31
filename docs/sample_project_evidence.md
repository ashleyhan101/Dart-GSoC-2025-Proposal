# Good Sample Project Evidence (WebSocket Profiler)

## Goal
Demonstrate frame-level WebSocket profiling with:
- outgoing frame interception (`add`)
- incoming frame interception (`listen`)
- event buffering and query (`lastEvents`)
- CLI visibility of recent traffic

## Run

```bash
dart pub get
dart test
dart run bin/main.dart --local
```

## Demo Sequence

In CLI:

```text
/demo
/summary
/exit
```

Expected behavior:
- CLI prints 3 echoed messages (`hello`, `websocket test`, `你好`)
- `/demo` prints recent frame events with sent/recv directions
- `/summary` prints aggregate event and byte counts

## Representative Output

```text
WebSocket Profiler Sample
Connecting to wss://echo.websocket.events ...
Local mode enabled. Using ws://127.0.0.1:8765
Connected! ID: ws_1
Type messages and press enter.
Commands: /stats  /summary  /demo  /exit
echo: hello
echo: websocket test
echo: 你好
-------------------------------------------------------------------------------
ID   TIME         DIR      TYPE     BYTES   ELAPSED   PREVIEW
-------------------------------------------------------------------------------
1    22:28:58.684 sent     text     5B      +5ms      hello
2    22:28:58.691 recv     text     5B      +12ms     hello
3    22:28:58.841 sent     text     14B     +162ms    websocket test
4    22:28:58.842 recv     text     14B     +164ms    websocket test
5    22:28:58.995 sent     text     6B      +317ms    你好
6    22:28:59.000 recv     text     6B      +321ms    你好
-------------------------------------------------------------------------------

Summary:
  Connections : 1
  Events      : 6
  Sent        : 25B
  Received    : 25B
```

## Test Coverage (Sample Scope)

- Event model serialization (`toJson`) is stable
- Outgoing events are recorded
- Incoming events are recorded
- Event order is preserved
- `lastEvents(n)` returns expected subset
- `frameEvents` stream emits in real-time
- UTF-8 byte-size accounting is correct
- Registry summary aggregates bytes and counts
- Registry reset clears tracked state

