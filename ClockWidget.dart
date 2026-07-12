import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'package:flame/components.dart';

void main() {
  runApp(const SystemTimeFlameApp());
}
class SystemTimeFlameApp extends StatelessWidget {
  const SystemTimeFlameApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.system, // Force adherence to OS system settings
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      home: const Scaffold(
        body: Center(
          child: TimeArtWidget(),
        ),
      ),
    );
  }
}
class TimeArtWidget extends StatefulWidget {
  const TimeArtWidget({super.key});

  @override
  State<TimeArtWidget> createState() => _TimeArtWidgetState();
}

class _TimeArtWidgetState extends State<TimeArtWidget> {
  late final TimeArtGame _game;

  @override
  void initState() {
    super.initState();
    _game = TimeArtGame();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final isDarkMode = MediaQuery.of(context).platformBrightness == Brightness.dark;
    _game.updateTheme(isDarkMode);
  }

  @override
  Widget build(BuildContext context) {
    return GameWidget(game: _game);
  }
}

class TimeArtGame extends FlameGame {
  bool isDark = false;

  void updateTheme(bool isDarkMode) {
    isDark = isDarkMode;
  }
  @override
  Color backgroundColor() => isDark ? const Color(0xFF121212) : const Color(0xFFF5F5F5);

  @override
  Future<void> onLoad() async {
    add(GenerativeTimeComponent());
  }
}

class GenerativeTimeComponent extends Component with HasGameRef<TimeArtGame> {
  @override
  void render(Canvas canvas) {
    final now = DateTime.now();
    final center = gameRef.size / 2;
    final seconds = now.second + now.millisecond / 1000;
    final minutes = now.minute + seconds / 60;
    final hours = (now.hour % 12) + minutes / 60;
    final isDark = gameRef.isDark;
    final hourColor = isDark ? Colors.white70 : Colors.black87;
    final minColor = isDark ? Colors.cyanAccent : Colors.blue.shade800;
    final secColor = isDark ? Colors.pinkAccent : Colors.red.shade600;
    _drawOrbitRing(canvas, center, hours / 12, 80, hourColor, 8);
    _drawOrbitRing(canvas, center, minutes / 60, 120, minColor, 5);
    _drawOrbitRing(canvas, center, seconds / 60, 160, secColor, 3);
  }
  void _drawOrbitRing(
      Canvas canvas, Vector2 center, double progress, double radius, Color color, double strokeWidth) {
    final trackPaint = Paint()
      ..color = color.withOpacity(0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    canvas.drawCircle(center.toOffset(), radius, trackPaint);
    final angle = progress * 2 * pi - (pi / 2); // -pi/2 starts it at the top (12 o'clock)
    final dotX = center.x + cos(angle) * radius;
    final dotY = center.y + sin(angle) * radius;
    final dotPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(dotX, dotY), strokeWidth * 1.5 + 4, dotPaint);
  }
}
