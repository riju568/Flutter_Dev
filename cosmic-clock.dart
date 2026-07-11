import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'package:flame/components.dart';

void main() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: Scaffold(
      body: ComicClockWidget(),
    ),
  ));
}

class ComicClockWidget extends StatelessWidget {
  const ComicClockWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return GameWidget(
      game: ComicClockGame(),
    );
  }
}

class ComicClockGame extends FlameGame {
  @override
  Color backgroundColor() => const Color(0xFFFDE047);

  @override
  Future<void> onLoad() async {
    final clock = ComicClock()..opacity = 0.0;
    
    late LoadingScreen loading;
    loading = LoadingScreen(onFinished: () {
      remove(loading);
      add(clock);
    });
    add(loading);
  }

  @override
  void render(Canvas canvas) {
    final dotPaint = Paint()..color = Colors.black.withOpacity(0.08);
    double spacing = 25.0;
    
    for (double x = 0; x < size.x + spacing; x += spacing) {
      for (double y = 0; y < size.y + spacing; y += spacing) {
        // Shift every other row to create a dynamic halftone layout
        double offsetX = (y % (spacing * 2) == 0) ? 0 : spacing / 2;
        canvas.drawCircle(Offset(x + offsetX, y), 3.5, dotPaint);
      }
    }
    
    // Render the Flame components (Loading or Clock) on top
    super.render(canvas);
  }
}

class LoadingScreen extends PositionComponent {
  double opacity = 1.0;
  double _timer = 0;
  bool _fading = false;
  bool _finished = false;
  final VoidCallback onFinished;
  
  double rotationAngle = 0;
  double scaleFactor = 1.0;
  late Path starPath;

  LoadingScreen({required this.onFinished}) {
    // Generate a comic burst star path centered at 0,0
    starPath = Path();
    for (int i = 0; i < 16; i++) {
      double angle = (i * 22.5) * pi / 180;
      double r = i % 2 == 0 ? 80 : 40;
      double x = cos(angle) * r;
      double y = sin(angle) * r;
      if (i == 0) starPath.moveTo(x, y);
      else starPath.lineTo(x, y);
    }
    starPath.close();
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    this.size = size;
  }

  @override
  void update(double dt) {
    rotationAngle += dt * 2.5;
    scaleFactor = 1.0 + 0.1 * sin(_timer * 6); 
    
    if (!_fading) {
      _timer += dt;
      if (_timer > 2.5) { 
        _fading = true;
      }
    } else if (!_finished) {
      opacity -= dt * 2.5; 
      if (opacity <= 0) {
        opacity = 0;
        _finished = true;
        onFinished();
      }
    }
  }

  @override
  void render(Canvas canvas) {
    final center = size / 2;
    Color c(Color color) => color.withAlpha((color.alpha * opacity).toInt().clamp(0, 255));
    canvas.save();
    canvas.translate(center.x, center.y);
    canvas.scale(scaleFactor, scaleFactor);
    canvas.save();
    canvas.rotate(rotationAngle);
    
    final paintShadow = Paint()..color = c(Colors.black)..style = PaintingStyle.fill;
    final paintFill = Paint()..color = c(Colors.cyanAccent)..style = PaintingStyle.fill;
    final paintStroke = Paint()
      ..color = c(Colors.black)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..strokeJoin = StrokeJoin.round;

    // Hard drop-shadow
    canvas.save();
    canvas.translate(10, 10);
    canvas.drawPath(starPath, paintShadow);
    canvas.restore();

    canvas.drawPath(starPath, paintFill);
    canvas.drawPath(starPath, paintStroke);
    
    canvas.restore();
    final textSpan = TextSpan(
      text: 'LOADING...',
      style: TextStyle(
        color: c(Colors.white),
        fontSize: 36,
        fontWeight: FontWeight.w900,
        letterSpacing: 4,
        shadows: [
          Shadow(color: c(Colors.black), offset: const Offset(3, 3)),
          Shadow(color: c(Colors.black), offset: const Offset(-2, -2)),
          Shadow(color: c(Colors.black), offset: const Offset(3, -2)),
          Shadow(color: c(Colors.black), offset: const Offset(-2, 3)),
          Shadow(color: c(Colors.black), offset: const Offset(8, 8)), 
        ],
      ),
    );
    final textPainter = TextPainter(text: textSpan, textDirection: TextDirection.ltr);
    textPainter.layout();
    textPainter.paint(canvas, Offset(-textPainter.width / 2, 130));
    
    canvas.restore();
  }
}

class CalendarEvent {
  final String title;
  final DateTime time;
  final Color color;
  CalendarEvent(this.title, this.time, this.color);
}
class ComicClock extends PositionComponent {
  double opacity = 0.0;
  double scaleFactor = 0.8;
  late List<CalendarEvent> events;

  ComicClock() {
    final now = DateTime.now().toUtc();
    events = [
      CalendarEvent("SYNC", DateTime.utc(now.year, now.month, now.day, now.hour, (now.minute + 15) % 60), Colors.purpleAccent),
      CalendarEvent("MEET", DateTime.utc(now.year, now.month, now.day, (now.hour + 2) % 24, 0), Colors.greenAccent),
      CalendarEvent("WORK", DateTime.utc(now.year, now.month, now.day, (now.hour + 5) % 24, 30), Colors.deepOrangeAccent),
    ];
  }
  
  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    this.size = size;
  }
  
  @override
  void update(double dt) {
    if (opacity < 1.0) {
      opacity += dt;
      if (opacity > 1.0) opacity = 1.0;
      scaleFactor = 0.8 + 0.2 * sin(opacity * pi / 2);
    } else {
      scaleFactor = 1.0;
    }
  }

  @override
  void render(Canvas canvas) {
    final utcTime = DateTime.now().toUtc();
    final center = size / 2;
    final radius = min(size.x, size.y) * 0.35; 
    
    final int alpha = (opacity * 255).toInt().clamp(0, 255);
    Color c(Color color) => color.withAlpha((color.alpha * opacity).toInt().clamp(0, 255));
    
    final shadowOffset = Offset(radius * 0.05, radius * 0.05);
    final strokeWidth = radius * 0.035;
    
    final blackStroke = Paint()
      ..color = c(Colors.black)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeJoin = StrokeJoin.round
      ..strokeCap = StrokeCap.round;

    canvas.save();
    canvas.translate(center.x, center.y);
    canvas.scale(scaleFactor, scaleFactor);
    for (var ev in events) {
      double evHour = (ev.time.hour % 12) + ev.time.minute / 60;
      double angle = (evHour / 12) * 2 * pi - pi / 2;
      double evRadius = radius * 1.1; 
      Offset evPos = Offset(cos(angle) * evRadius, sin(angle) * evRadius);
      drawComicEventBadge(canvas, ev, evPos, radius * 0.22, c(ev.color), blackStroke, alpha);
    }
    canvas.drawCircle(shadowOffset, radius, Paint()..color = c(Colors.black));
    canvas.drawCircle(Offset.zero, radius, Paint()..color = c(Colors.white));
    Path glassPath = Path()
      ..moveTo(radius * -0.6, radius * -0.8)
      ..quadraticBezierTo(radius * -0.1, radius * -0.9, radius * 0.3, radius * -0.8)
      ..quadraticBezierTo(radius * -0.2, radius * -0.4, radius * -0.8, radius * -0.2)
      ..close();
    canvas.drawPath(glassPath, Paint()..color = Colors.white.withAlpha((90 * opacity).toInt().clamp(0, 255)));
    canvas.drawCircle(Offset.zero, radius, blackStroke);
    final numberStyle = TextStyle(
      color: c(Colors.white),
      fontSize: radius * 0.28,
      fontWeight: FontWeight.w900,
      shadows: [
        Shadow(color: c(Colors.black), offset: const Offset(2, 2)),
        Shadow(color: c(Colors.black), offset: const Offset(-2, -2)),
        Shadow(color: c(Colors.black), offset: const Offset(2, -2)),
        Shadow(color: c(Colors.black), offset: const Offset(-2, 2)),
        Shadow(color: c(Colors.black), offset: const Offset(5, 5)), // depth shadow
      ],
    );

    void drawNumber(String text, Offset pos) {
      final tp = TextPainter(
        text: TextSpan(text: text, style: numberStyle),
        textDirection: TextDirection.ltr,
      );
      tp.layout();
      tp.paint(canvas, Offset(pos.dx - tp.width / 2, pos.dy - tp.height / 2));
    }
    double textRadius = radius * 0.75;
    drawNumber('12', Offset(0, -textRadius));
    drawNumber('3', Offset(textRadius, 0));
    drawNumber('6', Offset(0, textRadius));
    drawNumber('9', Offset(-textRadius, 0));
    for (int i = 0; i < 60; i++) {
      if (i % 15 == 0) continue; // Avoid drawing over numbers
      double angle = (i * 6) * pi / 180 - pi / 2;
      bool isHour = i % 5 == 0;
      double length = isHour ? radius * 0.1 : radius * 0.05;
      double startR = radius * 0.95;
      double endR = startR - length;
      
      canvas.drawLine(
        Offset(cos(angle) * startR, sin(angle) * startR),
        Offset(cos(angle) * endR, sin(angle) * endR), 
        blackStroke..strokeWidth = isHour ? radius * 0.04 : radius * 0.02
      );
    }
    final textPainter = TextPainter(
      text: TextSpan(
        text: 'UTC TIME\n${utcTime.hour.toString().padLeft(2, '0')}:${utcTime.minute.toString().padLeft(2, '0')}',
        style: TextStyle(
          color: c(Colors.black),
          fontSize: radius * 0.13,
          fontWeight: FontWeight.w900,
          height: 1.2,
          letterSpacing: 2,
        ),
      ),
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    final boxRect = Rect.fromCenter(
      center: Offset(0, radius * 0.42),
      width: textPainter.width + radius * 0.15,
      height: textPainter.height + radius * 0.05,
    );
    canvas.drawRect(boxRect.translate(shadowOffset.dx/2, shadowOffset.dy/2), Paint()..color = c(Colors.black));
    canvas.drawRect(boxRect, Paint()..color = c(Colors.white));
    canvas.drawRect(boxRect, blackStroke..strokeWidth = radius * 0.015);
    textPainter.paint(canvas, Offset(-textPainter.width / 2, radius * 0.42 - textPainter.height / 2));
    double hourAngle = ((utcTime.hour % 12) + utcTime.minute / 60) * 30 * pi / 180 - pi / 2;
    double minAngle = (utcTime.minute + utcTime.second / 60) * 6 * pi / 180 - pi / 2;
    double secAngle = (utcTime.second + utcTime.millisecond / 1000) * 6 * pi / 180 - pi / 2;
    drawComicHand(canvas, hourAngle, radius * 0.5, radius * 0.09, c(Colors.pinkAccent), blackStroke, shadowOffset);
    drawComicHand(canvas, minAngle, radius * 0.75, radius * 0.07, c(Colors.cyanAccent), blackStroke, shadowOffset);
    drawComicHand(canvas, secAngle, radius * 0.9, radius * 0.02, c(Colors.yellowAccent), blackStroke, shadowOffset, hasCircle: true);
    canvas.drawCircle(shadowOffset, radius * 0.06, Paint()..color = c(Colors.black));
    canvas.drawCircle(Offset.zero, radius * 0.06, Paint()..color = c(Colors.redAccent));
    canvas.drawCircle(Offset.zero, radius * 0.06, blackStroke..strokeWidth = radius * 0.02);
    canvas.restore();
  }

  void drawComicEventBadge(Canvas canvas, CalendarEvent ev, Offset center, double size, Color color, Paint strokePaint, int alpha) {
    Path path = Path();
    int points = 8;
    for (int i = 0; i < points * 2; i++) {
      double angle = (i * pi) / points;
      double r = i % 2 == 0 ? size : size * 0.7;
      double x = center.dx + cos(angle) * r;
      double y = center.dy + sin(angle) * r;
      if (i == 0) path.moveTo(x, y);
      else path.lineTo(x, y);
    }
    path.close();
    
    canvas.save();
    canvas.translate(size * 0.2, size * 0.2);
    canvas.drawPath(path, Paint()..color = Colors.black.withAlpha(alpha));
    canvas.restore();
    
    canvas.drawPath(path, Paint()..color = color);
    canvas.drawPath(path, strokePaint..strokeWidth = size * 0.15);

    final tp = TextPainter(
      text: TextSpan(
        text: ev.title,
        style: TextStyle(
          color: Colors.black.withAlpha(alpha),
          fontSize: size * 0.45,
          fontWeight: FontWeight.w900,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    tp.layout();
    tp.paint(canvas, Offset(center.dx - tp.width / 2, center.dy - tp.height / 2));
  }

  void drawComicHand(Canvas canvas, double angle, double length, double width, Color color, Paint strokePaint, Offset shadowOffset, {bool hasCircle = false}) {
    canvas.save();
    canvas.rotate(angle);
    RRect handRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(-width, -width / 2, length + width * 1.5, width),
      Radius.circular(width / 2),
    );
    
    canvas.save();
    canvas.translate(shadowOffset.dx, shadowOffset.dy);
    canvas.drawRRect(handRect, Paint()..color = color.withAlpha(255).withOpacity(0.0) == Colors.transparent ? color : Colors.black.withAlpha(color.alpha));
    if (hasCircle) canvas.drawCircle(Offset(-width * 2, 0), width * 2, Paint()..color = Colors.black.withAlpha(color.alpha));
    canvas.restore();
    canvas.drawRRect(handRect, Paint()..color = color);
    canvas.drawRRect(handRect, strokePaint..strokeWidth = width * 0.35);
    if (hasCircle) {
      canvas.drawCircle(Offset(-width * 2, 0), width * 2, Paint()..color = color);
      canvas.drawCircle(Offset(-width * 2, 0), width * 2, strokePaint..strokeWidth = width * 0.35);
      canvas.drawCircle(Offset(length, 0), width * 2.5, Paint()..color = Colors.black.withAlpha(color.alpha));
      canvas.drawCircle(Offset(length, 0), width * 2.5, Paint()..color = color);
      canvas.drawCircle(Offset(length, 0), width * 2.5, strokePaint..strokeWidth = width * 0.35);
    }
    canvas.restore();
  }
}
