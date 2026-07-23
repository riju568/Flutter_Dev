import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'dart:math' as math;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flame Rainbow GUI',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.purple,
        scaffoldBackgroundColor: Colors.black,
      ),
      home: const GameScreen(),
    );
  }
}

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late final RainbowGame _game;
  double _hueSpeed = 1.5;
  double _intensity = 0.8;
  bool _isPulseActive = true;
  String _statusText = 'System Active & Optimized';

  @override
  void initState() {
    super.initState();
    _game = RainbowGame();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GameWidget(game: _game),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.2),
                              ),
                            ),
                            child: const Icon(Icons.dashboard_rounded, color: Colors.white, size: 24),
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            'FLAME RAINBOW GUI',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.5,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.green.withOpacity(0.5)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Icon(Icons.circle, color: Colors.greenAccent, size: 10),
                            SizedBox(width: 6),
                            Text(
                              'OFFLINE 60 FPS',
                              style: TextStyle(
                                color: Colors.greenAccent,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.45),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Colors.white.withOpacity(0.15)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.5),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Controls & Hue Tuning',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              _statusText,
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.7),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Rainbow Speed: ${_hueSpeed.toStringAsFixed(1)}x',
                          style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 13),
                        ),
                        Slider(
                          value: _hueSpeed,
                          min: 0.2,
                          max: 5.0,
                          activeColor: Colors.purpleAccent,
                          inactiveColor: Colors.white24,
                          onChanged: (val) {
                            setState(() {
                              _hueSpeed = val;
                              _game.hueSpeed = val;
                            });
                          },
                        ),
                        Text(
                          'Effect Intensity: ${(_intensity * 100).toInt()}%',
                          style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 13),
                        ),
                        Slider(
                          value: _intensity,
                          min: 0.1,
                          max: 1.0,
                          activeColor: Colors.cyanAccent,
                          inactiveColor: Colors.white24,
                          onChanged: (val) {
                            setState(() {
                              _intensity = val;
                              _game.intensity = val;
                            });
                          },
                        ),

                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: _isPulseActive ? Colors.purpleAccent : Colors.grey[800],
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),
                                icon: Icon(_isPulseActive ? Icons.pause : Icons.play_arrow),
                                label: Text(_isPulseActive ? 'Pause Pulse' : 'Resume Pulse'),
                                onPressed: () {
                                  setState(() {
                                    _isPulseActive = !_isPulseActive;
                                    _game.togglePulse();
                                    _statusText = _isPulseActive ? 'Pulse Resumed' : 'Pulse Paused';
                                  });
                                },
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: OutlinedButton.icon(
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.white,
                                  side: BorderSide(color: Colors.white.withOpacity(0.3)),
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),
                                icon: const Icon(Icons.refresh),
                                label: const Text('Reset Defaults'),
                                onPressed: () {
                                  setState(() {
                                    _hueSpeed = 1.5;
                                    _intensity = 0.8;
                                    _isPulseActive = true;
                                    _game.resetDefaults();
                                    _statusText = 'Defaults Restored';
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
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
}
class RainbowGame extends FlameGame {
  double hueSpeed = 1.5;
  double intensity = 0.8;
  bool isPulseActive = true;
  late RainbowBackgroundComponent _background;
  @override
  Future<void> onLoad() async {
    await super.onLoad();
    _background = RainbowBackgroundComponent();
    add(_background);
  }

  void togglePulse() {
    isPulseActive = !isPulseActive;
    _background.isPulseActive = isPulseActive;
  }

  void resetDefaults() {
    hueSpeed = 1.5;
    intensity = 0.8;
    isPulseActive = true;
    _background.hueSpeed = hueSpeed;
    _background.intensity = intensity;
    _background.isPulseActive = isPulseActive;
  }

  @override
  void update(double dt) {
    super.update(dt);
    _background.hueSpeed = hueSpeed;
    _background.intensity = intensity;
  }
}

class RainbowBackgroundComponent extends PositionComponent with HasGameRef {
  double hueSpeed = 1.5;
  double intensity = 0.8;
  bool isPulseActive = true;
  double _time = 0.0;

  @override
  void update(double dt) {
    super.update(dt);
    if (isPulseActive) {
      _time += dt * hueSpeed;
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    final rect = Rect.fromLTWH(0, 0, gameRef.size.x, gameRef.size.y);
    final double hue1 = (_time * 30) % 360;
    final double hue2 = (_time * 30 + 120) % 360;
    final double hue3 = (_time * 30 + 240) % 360;

    final color1 = HSVColor.fromAHSV(1.0, hue1, 0.7, 0.3 * intensity).toColor();
    final color2 = HSVColor.fromAHSV(1.0, hue2, 0.8, 0.4 * intensity).toColor();
    final color3 = HSVColor.fromAHSV(1.0, hue3, 0.9, 0.5 * intensity).toColor();
    final paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [color1, color2, color3],
      ).createShader(rect);
    canvas.drawRect(rect, paint);
    for (int i = 0; i < 5; i++) {
      final angle = _time * 0.5 + i * (math.pi * 2 / 5);
      final x = gameRef.size.x / 2 + math.cos(angle) * (gameRef.size.x * 0.3);
      final y = gameRef.size.y / 2 + math.sin(angle * 0.8) * (gameRef.size.y * 0.3);
      final particlePaint = Paint()
        ..color = HSVColor.fromAHSV(0.25 * intensity, (hue1 + i * 40) % 360, 0.9, 0.9).toColor()
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 60);
      canvas.drawCircle(Offset(x, y), 80 + math.sin(_time + i) * 20, particlePaint);
    }
  }
}
