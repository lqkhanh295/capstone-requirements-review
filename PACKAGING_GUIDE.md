# Windows Desktop Build & Packaging Guide (Member 5 - TRUNG)

This guide documents the procedures for performance optimization, running integration tests, building release executables, and packaging the **Capstone Requirements Review Desktop Application** on Windows Desktop.

---

## 1. System Requirements & Prerequisites
- **Flutter SDK**: 3.13+ or higher with Windows desktop support enabled (`flutter config --enable-windows-desktop`).
- **Build Tools**: Visual Studio 2022 with **Desktop development with C++** workload installed.
- **Dart Compiler**: 3.0+ (supports isolates via `compute`).

---

## 2. Performance Optimization Architecture (NFR-001, NFR-002, NFR-003)

To ensure the application maintains a fluid 60 FPS user interface with zero freezing (No UI Freeze):
1. **Background Isolate Offloading**:
   - PDF Report generation (`PDFReportGenerator`) and CSV string formatting (`CSVReportGenerator`) execute inside dedicated Dart background isolates via `ReportExportService.generatePdfAsync()` and `ReportExportService.generateCsvAsync()`.
   - File parsing and AI quality analysis run on async isolate pools.
2. **Desktop Window Management (`window_manager`)**:
   - Minimum window dimensions are locked to `1200 x 800` pixels (`WindowConfig.minWindowSize`).
   - Default startup dimensions set to `1400 x 900`, centered on screen with desktop frame title.

---

## 3. Running Integration & Unit Tests

To run the full test suite including Dashboard calculations, PDF generation, CSV formatting, and Isolate async execution:

```bash
# Run all unit and integration tests
flutter test test/dashboard_export_test.dart
```

Expected output:
```
00:02 +4: All tests passed!
```

---

## 4. Building Release Binary on Windows Desktop

To build the optimized production release binary for Windows:

```bash
# 1. Fetch dependencies
flutter pub get

# 2. Build Windows Release executable
flutter build windows --release
```

The compiled release executable and dependency bundle will be located at:
```
build/windows/x64/runner/Release/
├── capstone_requirements_review.exe
├── data/
├── flutter_windows.dll
└── ...
```

---

## 5. Keyboard Shortcuts Summary

- `Ctrl + E` (or `Cmd + E` on macOS): Open Export Report Dialog (PDF / CSV).
- `Ctrl + F`: Quick focus search bar.
- `Ctrl + S`: Save review state.
- `Ctrl + Enter`: Trigger AI review analysis for selected requirement.
