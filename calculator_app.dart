/*
This code base own and maintained by Tanmoy Samnata using standardization atest stable version of Flutter is 3.44.6

*/

import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/services.dart';
import 'package:flame/text.dart';
import 'package:math_expressions/math_expressions.dart';
import 'dart:ui' as ui;

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(MaterialApp(debugShowCheckedModeBanner: false, home: Scaffold(body: GameWidget(game: CalculatorGame()))));
}

class CalculatorGame extends FlameGame with TapCallbacks {
  late DisplayComponent display;
  late KeyboardComponent keyboard;
  String currentExpression = '';
  String currentResult = '';
  bool _isLoaded = false;

  @override
  Color backgroundColor() => const Color(0xFF19191D);

  @override
  Future<void> onLoad() async {
    display = DisplayComponent()..size = Vector2(size.x, size.y * 0.28);
    keyboard = KeyboardComponent(onButtonPressed: _handleButtonPress)..size = Vector2(size.x, size.y * 0.72)..position = Vector2(0, size.y * 0.28);
    await add(display);
    await add(keyboard);
    display.cacheDisplay();
    keyboard.cacheStaticKeyboard();
    _isLoaded = true;
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    if (_isLoaded) {
      display.size = Vector2(size.x, size.y * 0.28);
      display.cacheDisplay();
      keyboard.size = Vector2(size.x, size.y * 0.72);
      keyboard.position = Vector2(0, size.y * 0.28);
      keyboard.cacheStaticKeyboard();
    }
  }

  void _handleButtonPress(String label, String mathValue) {
    if (label == 'AC') { currentExpression = ''; currentResult = ''; }
    else if (label == 'DEL') { if (currentExpression.isNotEmpty) currentExpression = currentExpression.substring(0, currentExpression.length - 1); }
    else if (label == '=') { _calculateResult(); }
    else { currentExpression += mathValue; }
    display.updateText(currentExpression, currentResult);
  }

  void _calculateResult() {
    if (currentExpression.isEmpty) return;
    try {
      String sanitized = currentExpression.replaceAll('×', '*').replaceAll('÷', '/').replaceAll('π', '3.14159').replaceAll('e', '2.71828');
      Parser p = Parser();
      Expression exp = p.parse(sanitized);
      double eval = exp.evaluate(EvaluationType.REAL, ContextModel());
      currentResult = eval.toStringAsFixed(8).replaceAll(RegExp(r'\.?0*$'), '');
    } catch (e) { currentResult = "Syntax Error"; }
  }
}

class DisplayComponent extends PositionComponent {
  ui.Picture? _cache;
  String expression = '', result = '';
  
  void updateText(String exp, String res) { expression = exp; result = res; cacheDisplay(); }

  void cacheDisplay() {
    _cache?.dispose();
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.x, size.y), Paint()..color = const Color(0xFF19191D));
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(20, 20, size.x - 40, size.y - 40), Radius.circular(15)), Paint()..color = const Color(0xFFD3E0DC));
    
    TextPainter(text: TextSpan(text: expression, style: const TextStyle(color: Colors.black, fontSize: 24)), textDirection: TextDirection.ltr)..layout(maxWidth: size.x - 60)..paint(canvas, const Offset(40, 40));
    TextPainter(text: TextSpan(text: result, style: const TextStyle(color: Colors.black, fontSize: 40, fontWeight: FontWeight.bold)), textDirection: TextDirection.ltr)..layout(maxWidth: size.x - 60)..paint(canvas, const Offset(40, 90));
    _cache = recorder.endRecording();
  }

  @override
  void render(Canvas canvas) { if (_cache != null) canvas.drawPicture(_cache!); }
}

class KeyboardComponent extends PositionComponent with TapCallbacks {
  final Function(String, String) onButtonPressed;
  KeyboardComponent({required this.onButtonPressed});
  ui.Picture? _cache;
  final List<ButtonDef> _buttons = [];

  @override
  Future<void> onLoad() async {
    const btnDk = Color(0xFF333336), btnNum = Color(0xFF28282A), btnOrg = Color(0xFFF19A38), btnPurp = Color(0xFF756BB1);
    
    // GUI Fix: Specific layout mapping for a professional look
    final layout = [
      ['SHIFT', '', btnOrg], ['ALPHA', '', btnPurp], ['◄', '', btnDk], ['►', '', btnDk], ['MODE', '', btnDk],
      ['CALC', '', btnDk], ['∫dx', '', btnDk], ['x⁻¹', '^', btnDk], ['Log', 'log(', btnDk], ['Ln', 'ln(', btnDk],
      ['x²', '^2', btnDk], ['√x', 'sqrt(', btnDk], ['Sin', 'sin(', btnDk], ['Cos', 'cos(', btnDk], ['Tan', 'tan(', btnDk],
      ['(', '(', btnDk], [')', ')', btnDk], ['7', '7', btnNum], ['8', '8', btnNum], ['9', '9', btnNum],
      ['DEL', '', btnOrg], ['AC', '', btnOrg], ['4', '4', btnNum], ['5', '5', btnNum], ['6', '6', btnNum],
      ['×', '*', btnDk], ['÷', '/', btnDk], ['1', '1', btnNum], ['2', '2', btnNum], ['3', '3', btnNum],
      ['+', '+', btnDk], ['-', '-', btnDk], ['0', '0', btnNum], ['.', '.', btnNum], ['=', '=', btnOrg],
    ];

    for (var b in layout) _buttons.add(ButtonDef(b[0] as String, b[1] as String, b[2] as Color));
  }

  void cacheStaticKeyboard() {
    _cache?.dispose();
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final w = (size.x - 30) / 5;
    final h = (size.y - 40) / 7;
    
    for (int i = 0; i < _buttons.length; i++) {
      final btn = _buttons[i];
      final x = 10 + (i % 5) * (w + 4);
      final y = 10 + (i ~/ 5) * (h + 4);
      btn.rect = Rect.fromLTWH(x, y, w, h);
      canvas.drawRRect(RRect.fromRectAndRadius(btn.rect!, Radius.circular(8)), Paint()..color = btn.color);
      btn.tp.paint(canvas, Offset(x + (w - btn.tp.width) / 2, y + (h - btn.tp.height) / 2));
    }
    _cache = recorder.endRecording();
  }

  @override
  void render(Canvas canvas) { if (_cache != null) canvas.drawPicture(_cache!); }

  @override
  void onTapDown(TapDownEvent event) {
    for (var b in _buttons) if (b.rect!.contains(event.localPosition.toOffset())) onButtonPressed(b.label, b.mathValue);
  }
}

class ButtonDef {
  final String label, mathValue;
  final Color color;
  late TextPainter tp;
  Rect? rect;
  ButtonDef(this.label, this.mathValue, this.color) {
    tp = TextPainter(text: TextSpan(text: label, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)), textDirection: TextDirection.ltr)..layout();
  }
}
-------------------------pubspec.yaml--------------------------
name: calculator_app
description: "A scientific calculator."
publish_to: 'none' 
version: 1.0.0+1

environment:
  sdk: '^3.12.0'

dependencies:
  flutter:
    sdk: flutter
  flame: ^1.16.0
  math_expressions: ^2.3.1

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.0

flutter:
  uses-material-design: true

-----------------------------------------------------------
