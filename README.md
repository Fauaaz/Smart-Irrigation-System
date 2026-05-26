# 💧 Smart Irrigation System — Flutter GUI

A cross-platform Smart Irrigation dashboard built with Flutter and Dart.
Designed as a GUI demonstration project covering **UI design**, **user interaction**, and **data visualization**.

---

## 📋 Project Overview

| Detail | Info |
|---|---|
| **Topic** | Cross-Platform Tools & GUI Development |
| **Framework** | Flutter (Dart) |
| **Platforms** | Android, iOS, Web, Windows, Linux, macOS |
| **Theme** | Dark industrial control panel |

---

## ✨ Features

### 🎛️ Pump Control
- ON/OFF toggle switch for the main irrigation pump
- Animated status indicator with green glow when active
- Live status text updates (Active / Standby)

### 📊 System Status Panel
- **Flow Rate** — live L/min reading with animated bar chart history
- **Water Pressure** — bar value with a glowing progress indicator
- **Soil Moisture** — semi-circle arc gauge with colour coding (Dry / Optimal / Saturated)
- **Session Uptime** — counts how long the pump has been running (hh:mm)

### 🗺️ Zone Monitoring
- Four irrigation zones (Front lawn, Garden beds, Back yard, Greenhouse)
- Individual moisture level bars, each colour-coded
- Values update live when the pump is active

### 📝 Activity Log
- Timestamped log of all pump events
- Colour-coded entries (green = activated, amber = deactivated)

---

## 🗂️ Project Structure

```
your_project/
├── lib/
│   └── main.dart        ← All app code lives here
├── pubspec.yaml         ← Dependencies and project config
├── android/             ← Auto-generated (do not edit)
├── ios/                 ← Auto-generated (do not edit)
├── web/                 ← Auto-generated (do not edit)
└── README.md            ← This file
```

> **Note:** For this project, all code is contained in a single `lib/main.dart` file.
> No external packages are required beyond the Flutter SDK.

---

## 🚀 Getting Started

### Prerequisites
- [Flutter SDK](https://docs.flutter.dev/get-started/install) installed
- A connected device, emulator, or browser

### Run the app

**On a connected Android phone:**
```bash
flutter devices       # confirm your device is listed
flutter run           # select your device when prompted
```

**In a web browser:**
```bash
flutter run -d chrome
```

**On Windows desktop:**
```bash
flutter run -d windows
```

**Build a standalone Android APK:**
```bash
flutter build apk --release
# Output: build/app/outputs/flutter-apk/app-release.apk
```

---

## 🧱 Key Flutter Concepts Used

| Concept | Where it's used |
|---|---|
| `StatefulWidget` | Dashboard — holds all live data |
| `setState()` | Triggers UI redraw when sensor data changes |
| `Timer.periodic` | Simulates live sensor updates every 1.2 seconds |
| `AnimatedContainer` | Pump indicator smooth colour transition |
| `CustomPainter` | Soil moisture arc gauge |
| `LinearProgressIndicator` | Pressure bar and zone bars |
| `Switch` | Pump ON/OFF toggle |
| `SingleChildScrollView` | Makes the dashboard scrollable on small screens |

---

## 🎨 Colour Palette

| Colour | Hex | Usage |
|---|---|---|
| Background | `#0D1117` | App background |
| Surface | `#161B22` | Card backgrounds |
| Green | `#39D353` | Active pump, optimal moisture |
| Blue | `#58A6FF` | Pressure, saturated moisture |
| Amber | `#F0B429` | Dry soil warning |
| Red | `#FF6B6B` | Greenhouse zone |
| Text Primary | `#E6EDF3` | Main text |
| Text Secondary | `#8B949E` | Labels and descriptions |

---

## 👥 Group Demonstration Checklist

- [x] GUI design — dark themed dashboard with cards, gauges, and charts
- [x] User interaction — pump toggle updates all panels in real time
- [x] Visualization — flow chart, arc gauge, zone bars, live log

---

## 📱 Cross-Platform Demo (for presentation)

Run the same code on two platforms side by side to demonstrate cross-platform capability:

1. `flutter run -d chrome` — web browser
2. `flutter run` with Android phone plugged in — mobile app

No code changes needed between platforms.
