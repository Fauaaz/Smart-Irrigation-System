import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

// ─── Entry point ────────────────────────────────────────────────────────────
void main() {
  runApp(const IrrigationApp());
}

// ─── Root widget ─────────────────────────────────────────────────────────────
class IrrigationApp extends StatelessWidget {
  const IrrigationApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Irrigation',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF00E676),
          brightness: Brightness.dark,
          surface: const Color(0xFF1A1C1E),
          primary: const Color(0xFF00E676),
        ),
        scaffoldBackgroundColor: const Color(0xFF111315),
        // Fix: Changed CardTheme to CardThemeData for professional standards
        cardTheme: CardThemeData(
          color: const Color(0xFF1E2022),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: Color(0xFF2C2F33), width: 1),
          ),
        ),
      ),
      home: const IrrigationDashboard(),
    );
  }
}

// ─── Dashboard page ──────────────────────────────────────────────────────────
class IrrigationDashboard extends StatefulWidget {
  const IrrigationDashboard({super.key});

  @override
  State<IrrigationDashboard> createState() => _IrrigationDashboardState();
}

class _IrrigationDashboardState extends State<IrrigationDashboard> {
  bool _pumpOn = false;
  double _flowRate = 0.0;
  double _pressure = 0.0;
  double _soilMoisture = 25.0;
  int _uptimeSeconds = 0;

  Timer? _sensorTimer;
  Timer? _uptimeTimer;
  final Random _rng = Random();

  final List<String> _log = [
    'System initialised — all sensors online',
    'Awaiting pump activation',
  ];

  final List<double> _zoneMoisture = [05, 15, 10, 20];
  final List<String> _zoneNames = [
    'Zone A — Front lawn',
    'Zone B — Garden',
    'Zone C — Back yard',
    'Zone D — Greenhouse',
  ];

  // High-contrast Status Palette
  final List<Color> _zoneColors = [
    const Color(0xFF00BFA5), // Teal
    const Color(0xFF00B0FF), // Blue
    const Color(0xFFFFAB40), // Orange
    const Color(0xFFFF5252), // Red
  ];

  final List<double> _flowHistory = List<double>.generate(
    16,
    (_) => 0.0,
    growable: true,
  );

  @override
  void initState() {
    super.initState();
    _sensorTimer = Timer.periodic(const Duration(milliseconds: 1200), (_) {
      if (_pumpOn) _updateSensors();
    });
  }

  @override
  void dispose() {
    _sensorTimer?.cancel();
    _uptimeTimer?.cancel();
    super.dispose();
  }

  void _updateSensors() {
    setState(() {
      _flowRate = 6.0 + _rng.nextDouble() * 1.6;
      _pressure = 1.6 + _rng.nextDouble() * 0.3;
      _soilMoisture = (_soilMoisture + 0.4 + _rng.nextDouble() * 0.3).clamp(
        0,
        100,
      );

      _flowHistory.removeAt(0);
      _flowHistory.add(_flowRate);

      for (int i = 0; i < _zoneMoisture.length; i++) {
        _zoneMoisture[i] = (_zoneMoisture[i] + 0.3 + _rng.nextDouble() * 0.2)
            .clamp(0, 100);
      }
    });
  }

  void _togglePump(bool value) {
    setState(() {
      _pumpOn = value;
      // Cancel any existing timer to prevent multiple timers running at once
      _uptimeTimer?.cancel();

      if (_pumpOn) {
        _uptimeSeconds = 0;
        _uptimeTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
          // Check if the widget is still mounted before calling setState
          if (mounted) {
            setState(() => _uptimeSeconds++);
          }
        });
        _addLog('Pump activated — irrigation started');
      } else {
        _flowRate = 0;
        _pressure = 0;
        for (int i = 0; i < _flowHistory.length; i++) _flowHistory[i] = 0;
        _addLog('Pump deactivated — system idle');
      }
    });
  }

  void _addLog(String message) {
    final now = TimeOfDay.now();
    final h = now.hour.toString().padLeft(2, '0');
    final m = now.minute.toString().padLeft(2, '0');
    setState(() {
      _log.insert(0, '$h:$m  $message');
      if (_log.length > 8) _log.removeLast();
    });
  }

  String get _uptimeFormatted {
    final h = (_uptimeSeconds ~/ 3600).toString().padLeft(2, '0');
    final m = ((_uptimeSeconds % 3600) ~/ 60).toString().padLeft(2, '0');
    final s = (_uptimeSeconds % 60).toString().padLeft(2, '0');
    return '$h:$m:$s';
  }

  Color _moistureColor(double pct) {
    if (pct < 40) return const Color(0xFFFFAB40);
    if (pct > 75) return const Color(0xFF00B0FF);
    return const Color(0xFF00E676);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF1A1C1E),
        surfaceTintColor: Colors.transparent,
        titleSpacing: 20,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF00E676).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.waves_rounded,
                color: Color(0xFF00E676),
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Smart Irrigation Console',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
                Text(
                  'LIVE TELEMETRY ACTIVE',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF00E676),
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          children: [
            _buildPumpCard(),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _buildFlowCard()),
                const SizedBox(width: 12),
                Expanded(child: _buildPressureCard()),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _buildMoistureCard()),
                const SizedBox(width: 12),
                Expanded(child: _buildUptimeCard()),
              ],
            ),
            const SizedBox(height: 12),
            _buildZonesCard(),
            const SizedBox(height: 12),
            _buildLogCard(),
          ],
        ),
      ),
    );
  }

  // ─── Card builders ────────────────────────────────────────────────────────

  Widget _buildPumpCard() {
    return _cardShell(
      child: Row(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 400),
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              color: _pumpOn
                  ? const Color(0xFF00E676).withOpacity(0.15)
                  : const Color(0xFF2C2F33),
              border: Border.all(
                color: _pumpOn
                    ? const Color(0xFF00E676).withOpacity(0.5)
                    : const Color(0xFF3E4247),
                width: 1.5,
              ),
            ),
            child: Icon(
              _pumpOn ? Icons.bolt_rounded : Icons.power_settings_new_rounded,
              color: _pumpOn ? const Color(0xFF00E676) : Colors.white24,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Master Pump Control',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _pumpOn ? 'STATUS: IRRIGATING' : 'STATUS: STANDBY',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.8,
                    color: _pumpOn ? const Color(0xFF00E676) : Colors.white24,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: _pumpOn,
            onChanged: _togglePump,
            activeTrackColor: const Color(0xFF00E676).withOpacity(0.3),
            activeColor: const Color(0xFF00E676),
            inactiveTrackColor: const Color(0xFF2C2F33),
          ),
        ],
      ),
    );
  }

  Widget _buildFlowCard() {
    final maxVal = _flowHistory
        .reduce((a, b) => a > b ? a : b)
        .clamp(1.0, double.infinity);
    return _cardShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _cardLabel('Flow Rate'),
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                _flowRate.toStringAsFixed(1),
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 4),
              const Text(
                'L/m',
                style: TextStyle(fontSize: 12, color: Colors.white38),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 32,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(_flowHistory.length, (i) {
                final h = (_flowHistory[i] / maxVal * 32).clamp(2.0, 32.0);
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 1.5),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      height: h,
                      decoration: BoxDecoration(
                        color: const Color(
                          0xFF00E676,
                        ).withOpacity(0.2 + (i / 20)),
                        borderRadius: BorderRadius.circular(1),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPressureCard() {
    return _cardShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _cardLabel('Water Pressure'),
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                _pressure.toStringAsFixed(2),
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 4),
              const Text(
                'bar',
                style: TextStyle(fontSize: 12, color: Colors.white38),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: (_pressure / 2.5).clamp(0.0, 1.0),
              minHeight: 6,
              backgroundColor: const Color(0xFF2C2F33),
              valueColor: const AlwaysStoppedAnimation<Color>(
                Color(0xFF00B0FF),
              ),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'THRESHOLD: 2.5 BAR',
            style: TextStyle(
              fontSize: 8,
              fontWeight: FontWeight.bold,
              color: Colors.white24,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMoistureCard() {
    return _cardShell(
      child: Column(
        children: [
          _cardLabel('Avg Moisture'),
          const SizedBox(height: 12),
          SizedBox(
            height: 70,
            width: 120,
            child: CustomPaint(
              painter: _GaugePainter(
                percent: _soilMoisture,
                color: _moistureColor(_soilMoisture),
              ),
              child: Align(
                alignment: const Alignment(0, 0.4),
                child: Text(
                  '${_soilMoisture.round()}%',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUptimeCard() {
    return _cardShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _cardLabel('Session Timer'),
          const SizedBox(height: 4),
          Text(
            _uptimeFormatted,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontFamily: 'monospace',
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: _pumpOn
                  ? const Color(0xFF00E676).withOpacity(0.1)
                  : Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              _pumpOn ? 'ACTIVE' : 'IDLE',
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.bold,
                color: _pumpOn ? const Color(0xFF00E676) : Colors.white38,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildZonesCard() {
    return _cardShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _cardLabel('Zone Telemetry'),
          const SizedBox(height: 12),
          ...List.generate(_zoneNames.length, (i) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _zoneNames[i],
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Colors.white70,
                        ),
                      ),
                      Text(
                        '${_zoneMoisture[i].round()}%',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: _zoneColors[i],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(2),
                    child: LinearProgressIndicator(
                      value: _zoneMoisture[i] / 100,
                      minHeight: 4,
                      backgroundColor: const Color(0xFF2C2F33),
                      valueColor: AlwaysStoppedAnimation<Color>(_zoneColors[i]),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildLogCard() {
    return _cardShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _cardLabel('Event Log'),
          const SizedBox(height: 8),
          ..._log.map(
            (entry) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '>',
                    style: TextStyle(
                      color: Color(0xFF00E676),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      entry,
                      style: const TextStyle(
                        fontSize: 11,
                        color: Colors.white54,
                        height: 1.3,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Shared helpers ───────────────────────────────────────────────────────

  Widget _cardShell({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E2022),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF2C2F33)),
      ),
      child: child,
    );
  }

  Widget _cardLabel(String text) {
    return Text(
      text.toUpperCase(),
      style: const TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w900,
        letterSpacing: 1.5,
        color: Colors.white24,
      ),
    );
  }
}

// ─── Gauge painter ────────────────────────────────────────────────────────────
class _GaugePainter extends CustomPainter {
  final double percent;
  final Color color;
  const _GaugePainter({required this.percent, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    const strokeW = 10.0;
    final cx = size.width / 2;
    final cy = size.height - 4;
    final radius = size.width / 2 - strokeW;
    final rect = Rect.fromCircle(center: Offset(cx, cy), radius: radius);

    // Background Arc
    canvas.drawArc(
      rect,
      pi,
      pi,
      false,
      Paint()
        ..color = const Color(0xFF2C2F33)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeW
        ..strokeCap = StrokeCap.round,
    );

    // Filled Arc
    if (percent > 0) {
      canvas.drawArc(
        rect,
        pi,
        pi * (percent / 100),
        false,
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeW
          ..strokeCap = StrokeCap.round,
      );
    }
  }

  @override
  bool shouldRepaint(_GaugePainter old) =>
      old.percent != percent || old.color != color;
}
