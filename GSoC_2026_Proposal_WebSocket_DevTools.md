# GSoC 2026 Proposal

## Project Information
- **Title:** Add WebSocket Support to Flutter DevTools Network Panel
- **Organization:** Dart
- **Project Idea:** Add WebSocket/GRPC Support to Flutter DevTools Network panel
- **Potential Mentor(s):** Elliott Brooks (`elliottbrooks@google.com`), Samuel Rawlins (`srawlins@google.com`)
- **Project Size:** Medium (175 hours)

## Applicant Information
- **Name:** Ashley (Yazhen) Han
- **Email:** `ashleyhan.neu1019@gmail.com`
- **GitHub:** `https://github.com/ashleyhan101`
- **LinkedIn:** `https://www.linkedin.com/in/yazhen-han-764756197/`
- **Location / Timezone:** Santa Clara, CA, USA / America-Los_Angeles (UTC-7/UTC-8)
- **University / Program:** Northeastern University, M.S. in Computer Science

## Synopsis
The DevTools Network panel is strongest for HTTP workflows, while WebSocket diagnostics are still limited for practical frame-level debugging. This project will implement first-class WebSocket profiling across the Dart runtime toolchain: instrumentation in `dart:io`, exposure via VM Service / developer tooling APIs, and DevTools Network panel integration for inspection and filtering.

I have already completed a working sample project that records WebSocket frame events (`sent`/`recv`, type, bytes, timestamp), provides a CLI demo, and includes tests. During GSoC, I will use this sample event model as a validation baseline and implement production-grade runtime + tooling integration.

## Problem and Motivation
Many Flutter/Dart applications depend on long-lived WebSocket connections (chat, live data, push updates). HTTP-style request/response visualization is insufficient for this traffic pattern. Developers need reliable visibility into frame-level behavior and timing to diagnose correctness and performance issues.

This project focuses on WebSocket first. gRPC is treated as optional extension work, since instrumentation for gRPC is expected to live in the Dart gRPC package layer and likely expands scope beyond a medium project.

## Current Understanding (Architecture Constraints)
- WebSocket/gRPC do not currently expose enough profiling detail for tooling use out of the box.
- This is not a DevTools-only UI task; it requires runtime instrumentation and service exposure.
- VM Service protocol is event-stream oriented (`streamListen`/`streamNotify`) and suitable for incremental event integration.
- `dart:io` is non-web; this project targets VM/non-web Flutter contexts.

## Prototype Completed (Good Sample Project)
Implemented in this repository:
- `ProfileableWebSocket` that intercepts `add()` and `listen()`
- Typed frame model (`timestamp`, `direction`, `type`, `sizeBytes`, `connectionId`)
- Multi-connection registry and recent-event query
- CLI demo (`/demo`, `/stats`, `/summary`, `/exit`)
- Local fallback echo server mode (`--local`) for deterministic demos
- Automated test suite

Key files:
- `lib/src/profileable_websocket.dart`
- `lib/src/websocket_frame_event.dart`
- `lib/src/websocket_profiler.dart`
- `bin/main.dart`
- `test/profileable_websocket_test.dart`
- `docs/sample_project_evidence.md`

Verified results:
- `dart test` => `+9: All tests passed!`
- CLI sample captures and displays bidirectional frame events and byte totals.

## Repository / Evidence Links
- **Primary Repository:** [replace with final URL]
- **Secret Gist (if required by mentors):** [replace with final URL]
- **Terminal Screenshot (sample run):** [replace with final URL]
- **Optional Demo Video:** [replace with final URL]

## Technical Plan

### 1) Runtime Instrumentation (`dart:io`)
- Add/extend WebSocket profiling hooks to capture frame-level metadata.
- Keep capture asynchronous and lightweight.
- Track per-connection context and frame direction.

### 2) Service Exposure (VM Service / developer APIs)
- Expose recorded WebSocket profiling data for tooling consumption.
- Reuse existing profiling/event infrastructure where possible for lower risk.
- Ensure backward-compatible event evolution.

### 3) DevTools Network Integration
- Surface WebSocket events as first-class entries in Network workflows.
- Support essential inspection fields (direction, type, bytes, timing, connection).
- Fit into current search/filter interaction patterns.

### 4) Validation and Metrics
- Verify via targeted tests and sample apps.
- Measure overhead and reliability of event capture.
- Validate diagnostic usefulness with reproducible scenarios.

## Worth-Tracking Event Policy (Initial)
For first-class support, I will prioritize stable, high-signal metadata:
- connection id
- timestamp / elapsed
- direction (`sent` / `recv`)
- frame type (`text` / `binary` / `unknown`)
- size in bytes
- bounded payload preview (safe/truncated)

This keeps the MVP useful while controlling overhead and privacy/sensitivity concerns.

## Deliverables

### Required (Medium Scope)
1. WebSocket profiling instrumentation path in runtime layer (`dart:io` side).
2. VM Service/developer-tooling exposure of WebSocket profiling data.
3. DevTools Network panel integration for WebSocket details (MVP level).
4. Tests + documentation + sample usage notes.

### Optional (Only if core is stable)
1. gRPC exploratory integration plan or partial prototype.
2. Advanced UX refinements in DevTools (extra filtering/grouping).
3. Additional package-level integrations where applicable.

## Evaluation Plan
I will report:
1. **Instrumentation correctness:** event ordering and field accuracy in tests.
2. **Tooling reliability:** successful event retrieval/consumption rate.
3. **Runtime overhead:** basic latency/memory overhead under synthetic load.
4. **Debug usefulness score:** benchmark scenarios scored via predefined rubric (signal quality, actionability, non-flakiness).

## Risks and Mitigations
1. **Scope expansion across runtime + tooling layers**  
Mitigation: strict WebSocket-first scope, optionalize gRPC.
2. **Event volume overhead**  
Mitigation: bounded buffers, minimal MVP fields, controlled sampling if needed.
3. **Integration complexity across repositories/components**  
Mitigation: stage-by-stage milestones with early integration checkpoints.
4. **Ambiguity in final event schema**  
Mitigation: prototype-backed schema proposal and early mentor feedback loop.

## Timeline (12 Weeks, 175 Hours)

### Community Bonding
- Align exact scope and acceptance criteria with mentors.
- Finalize event schema draft and integration checkpoints.
- Map relevant code paths in SDK + DevTools.

### Week 1-2
- Runtime-side WebSocket event model and capture hooks.
- Unit tests for frame metadata correctness and ordering.

### Week 3-4
- VM Service/developer API exposure path.
- End-to-end retrieval prototype from running app to tooling client.

### Week 5-6 (Midterm)
- Working pipeline: runtime capture -> service exposure -> consumable data output.
- Midterm demo with reproducible sample and verification tests.

### Week 7-8
- DevTools Network panel MVP integration for WebSocket data display.
- Basic filtering and details surface alignment.

### Week 9-10
- Stabilization, edge-case handling, performance checks.
- Additional integration tests and documentation improvements.

### Week 11
- Code freeze for core deliverables.
- Final bug fixes, docs, and reproducibility checks.

### Week 12
- Final polish and submission artifacts.
- Optional stretch work only if all required deliverables are complete.

## Why I Am a Good Fit
I already built a non-trivial, runnable WebSocket profiling sample aligned to this project’s required direction, including event interception, event modeling, CLI diagnostics, and tests. I also bring backend/distributed systems engineering experience, which is useful for building reliable observability pipelines and balancing diagnostics with runtime overhead.

## Submission Checklist
- [ ] Fill all repository/evidence links.
- [ ] Attach screenshot(s) of sample run and test results.
- [ ] Confirm mentor-facing draft by email (if requested).
- [ ] Export final proposal to PDF.
- [ ] Submit before **March 31, 2026, 18:00 UTC**.

Reference: GSoC timeline  
`https://developers.google.com/open-source/gsoc/timeline`

