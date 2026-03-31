# GSoC 2026 Proposal (Final Draft)

## Project Information
- **Title:** WebSocket Support for Flutter DevTools Network Panel
- **Organization:** Dart
- **Idea:** Add WebSocket/GRPC Support to Flutter DevTools Network panel
- **Potential Mentor(s):** Elliott Brooks (`elliottbrooks@google.com`), Samuel Rawlins (`srawlins@google.com`) *(subject to availability)*
- **Size:** Medium (175 hours)

## Applicant
- **Name:** Ashley (Yazhen) Han
- **Email:** `ashleyhan.neu1019@gmail.com`
- **GitHub:** `https://github.com/ashleyhan101`
- **Timezone:** America/Los_Angeles (UTC-7/UTC-8)
- **Program:** Northeastern University, M.S. Computer Science

## Summary
This project adds first-class WebSocket observability to the Flutter DevTools Network panel by implementing an end-to-end path: runtime event capture in `dart:io`, service exposure for tooling (VM Service / developer APIs), and DevTools UI integration for inspection/filtering.

The project is scoped WebSocket-first for medium size. gRPC is optional extension work.

## Why This Matters
HTTP request/response visualization is not enough for long-lived real-time connections. Many Flutter apps rely on WebSocket traffic (chat, live feeds, push updates), but developers need frame-level diagnostics (direction, size, timing, type) to debug behavior and performance issues effectively.

## Good Sample Project (Initial Prototype Completed)
I built a working sample project demonstrating frame-level WebSocket profiling:
- `ProfileableWebSocket` intercepts outgoing (`add`) and incoming (`listen`) traffic.
- Captured event fields: `connectionId`, `timestamp`, `direction`, `type`, `sizeBytes`, `payloadPreview`.
- CLI demo supports `/demo`, `/stats`, `/summary`, `/exit`.
- Local fallback mode (`--local`) enables deterministic demos without external DNS.
- Test suite: **9 tests passing** (`dart test`).

Main files:
- `lib/src/profileable_websocket.dart`
- `lib/src/websocket_frame_event.dart`
- `lib/src/websocket_profiler.dart`
- `bin/main.dart`
- `test/profileable_websocket_test.dart`
- `docs/sample_project_evidence.md`

## Links
- **Repository:** [replace with final URL]
- **Secret gist / sample evidence:** [replace with final URL]
- **Terminal screenshot:** [replace with final URL]
- **Optional demo video:** [replace with final URL]

## Technical Plan
### 1) Runtime Instrumentation (`dart:io`)
- Add/extend WebSocket profiling hooks for frame-level metadata capture.
- Preserve async behavior and low-overhead recording.

### 2) Tooling Exposure (VM Service / developer APIs)
- Expose WebSocket profiling events for tool consumption.
- Reuse existing profiling/event patterns where possible.

### 3) DevTools Network Integration
- Display WebSocket events as first-class network entries.
- Surface key fields: direction, type, bytes, timing, connection.
- Align with existing Network filtering and detail inspection UX.

### 4) Validation
- Unit/integration tests for event correctness and ordering.
- Reproducible demo scenarios and overhead checks.

## Deliverables
### Required
1. Runtime WebSocket profiling path (`dart:io` layer).
2. VM Service/developer exposure for captured WebSocket data.
3. DevTools Network MVP support for WebSocket event display.
4. Tests, documentation, and reproducible demo artifacts.

### Optional
1. gRPC exploratory path (package-level instrumentation direction).
2. Additional UX enhancements in DevTools.

## Evaluation
1. **Correctness:** event ordering and metadata accuracy.
2. **Reliability:** successful capture-to-consumption workflow.
3. **Overhead:** latency/memory impact under synthetic load.
4. **Qualitative usefulness:** curated benchmark assessment for signal quality and actionability, with maintainer/mentor feedback where available.

## Risks and Mitigation
- **Cross-layer complexity:** staged milestones with early integration checkpoints.
- **Scope growth:** WebSocket-first core; gRPC optional.
- **Event-volume overhead:** bounded buffers and minimal MVP fields.

## Timeline (12 Weeks, 175 Hours)
### Community Bonding
- Finalize scope, schema, and acceptance criteria with mentors.

### Week 1-2
- Implement/validate runtime WebSocket event model and hooks.

### Week 3-4
- Implement VM Service/developer tooling exposure path.

### Week 5-6 (Midterm)
- End-to-end pipeline demo: capture -> service exposure -> consumable output.

### Week 7-8
- DevTools Network MVP integration for WebSocket event display.

### Week 9-10
- Stabilization, edge cases, and performance checks.

### Week 11
- Code freeze for required scope, finalize docs/tests.

### Week 12
- Final polish and submission; optional work only if core is complete.

## Why I’m a Good Fit
I already implemented a concrete prototype aligned with this project’s core technical direction (frame event capture + tooling-oriented output + tests). My backend/distributed systems experience helps me build robust observability features while managing runtime overhead and integration complexity.

## Submission Checklist
- [ ] Fill repository/evidence URLs.
- [ ] Attach screenshot(s) and test output evidence.
- [ ] Export to PDF and submit.
- [ ] Submit before **March 31, 2026, 18:00 UTC**.

Deadline reference: [Google Summer of Code 2026 Timeline](https://developers.google.com/open-source/gsoc/timeline).
