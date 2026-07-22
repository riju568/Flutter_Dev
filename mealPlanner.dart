import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import 'package:flame/palette.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyOfflineGameApp());
}

class MyOfflineGameApp extends StatelessWidget {
  const MyOfflineGameApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flame Advanced Offline',
      theme: ThemeData.dark(useMaterial3: true),
      debugShowCheckedModeBanner: false,
      home: const FakeLoginScreen(),
    );
  }
}
class FakeLoginScreen extends StatefulWidget {
  const FakeLoginScreen({super.key});

  @override
  State<FakeLoginScreen> createState() => _FakeLoginScreenState();
}

class _FakeLoginScreenState extends State<FakeLoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String _errorMessage = '';

  void _handleLogin() {
    if (_usernameController.text.isNotEmpty && _passwordController.text == 'password') {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const GameWrapperScreen()),
      );
    } else {
      setState(() {
        _errorMessage = 'Invalid credentials. Password is "password".';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login to Play')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.security, size: 80, color: Colors.greenAccent),
              const SizedBox(height: 30),
              TextField(
                controller: _usernameController,
                decoration: const InputDecoration(labelText: 'Username', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Password', border: OutlineInputBorder()),
              ),
              if (_errorMessage.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(_errorMessage, style: const TextStyle(color: Colors.redAccent)),
              ],
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _handleLogin,
                style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
                child: const Text('Login', style: TextStyle(fontSize: 18)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
class GameWrapperScreen extends StatelessWidget {
  const GameWrapperScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Avoid Enemies, Get Coins!'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => const FakeLoginScreen()),
            ),
          )
        ],
      ),
      // We use GameWidget.controlled to easily access overlays
      body: GameWidget<MyAdvancedGame>.controlled(
        gameFactory: MyAdvancedGame.new,
        overlayBuilderMap: {
          'Hud': (context, game) => HudOverlay(game: game),
          'GameOver': (context, game) => GameOverOverlay(game: game),
        },
        initialActiveOverlays: const ['Hud'],
      ),
    );
  }
}

// HUD: Displays Score and Health using Flutter Widgets
class HudOverlay extends StatelessWidget {
  final MyAdvancedGame game;
  const HudOverlay({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          ValueListenableBuilder<int>(
            valueListenable: game.scoreNotifier,
            builder: (context, score, child) => Text(
              'Score: $score',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.yellow),
            ),
          ),
          ValueListenableBuilder<int>(
            valueListenable: game.healthNotifier,
            builder: (context, health, child) => Row(
              children: List.generate(
                3,
                (index) => Icon(
                  index < health ? Icons.favorite : Icons.favorite_border,
                  color: Colors.redAccent,
                  size: 32,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Game Over Menu
class GameOverOverlay extends StatelessWidget {
  final MyAdvancedGame game;
  const GameOverOverlay({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(color: Colors.black87, borderRadius: BorderRadius.circular(16)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('GAME OVER', style: TextStyle(fontSize: 40, color: Colors.red, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Text('Final Score: ${game.scoreNotifier.value}', style: const TextStyle(fontSize: 24, color: Colors.white)),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                game.overlays.remove('GameOver');
                game.resetGame();
              },
              child: const Text('Try Again', style: TextStyle(fontSize: 20)),
            ),
          ],
        ),
      ),
    );
  }
}
class MyAdvancedGame extends FlameGame with HasCollisionDetection {
  // Notifiers allow Flutter UI to react to Flame game state changes
  final scoreNotifier = ValueNotifier<int>(0);
  final healthNotifier = ValueNotifier<int>(3);

  late JoystickComponent joystick;
  late Player player;

  @override
  Future<void> onLoad() async {
    super.onLoad();

    final knobPaint = BasicPalette.blue.withAlpha(200).paint();
    final backgroundPaint = BasicPalette.blue.withAlpha(100).paint();
    
    joystick = JoystickComponent(
      knob: CircleComponent(radius: 20, paint: knobPaint),
      background: CircleComponent(radius: 50, paint: backgroundPaint),
      margin: const EdgeInsets.only(left: 40, bottom: 40),
    );

    // 2. Setup Player
    player = Player(joystick)..position = size / 2;
    
    add(player);
    add(joystick);

    // 3. Spawn Items and Enemies
    for (int i = 0; i < 5; i++) { add(Coin()); }
    for (int i = 0; i < 3; i++) { add(Enemy()); }
  }

  void takeDamage() {
    if (healthNotifier.value > 0) {
      healthNotifier.value -= 1;
      if (healthNotifier.value <= 0) {
        pauseEngine(); // Stop the game loop
        overlays.add('GameOver'); // Show Flutter UI
      }
    }
  }

  void resetGame() {
    scoreNotifier.value = 0;
    healthNotifier.value = 3;
    player.position = size / 2;
    resumeEngine();
  }
}
class Player extends PositionComponent with HasGameRef<MyAdvancedGame>, CollisionCallbacks {
  final JoystickComponent joystick;
  final double speed = 250.0;
  static final Paint _paint = BasicPalette.cyan.paint();

  Player(this.joystick) : super(size: Vector2.all(40), anchor: Anchor.center);

  @override
  Future<void> onLoad() async {
    add(RectangleHitbox()); // Enables collisions
  }

  @override
  void render(Canvas canvas) => canvas.drawRect(size.toRect(), _paint);

  @override
  void update(double dt) {
    super.update(dt);
    // Move using joystick input
    if (!joystick.delta.isZero()) {
      position.add(joystick.relativeDelta * speed * dt);
    }
    
    // Keep player inside screen bounds
    position.clamp(Vector2.zero() + (size / 2), gameRef.size - (size / 2));
  }
}

class Coin extends PositionComponent with HasGameRef<MyAdvancedGame>, CollisionCallbacks {
  static final Paint _paint = BasicPalette.yellow.paint();
  final Random random = Random();

  Coin() : super(size: Vector2.all(20), anchor: Anchor.center);

  @override
  Future<void> onLoad() async {
    add(RectangleHitbox());
    _randomizePosition();
  }

  void _randomizePosition() {
    position = Vector2(
      random.nextDouble() * (gameRef.size.x - 50) + 25,
      random.nextDouble() * (gameRef.size.y - 50) + 25,
    );
  }

  @override
  void render(Canvas canvas) => canvas.drawOval(size.toRect(), _paint);
  @override
  void onCollisionStart(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollisionStart(intersectionPoints, other);
    if (other is Player) {
      gameRef.scoreNotifier.value += 10; // Increase score
      _randomizePosition(); // Move to new spot instead of deleting
    }
  }
}
class Enemy extends PositionComponent with HasGameRef<MyAdvancedGame>, CollisionCallbacks {
  static final Paint _paint = BasicPalette.red.paint();
  final Random random = Random();
  late Vector2 velocity;
  final double speed = 150.0;

  Enemy() : super(size: Vector2.all(30), anchor: Anchor.center);
  @override
  Future<void> onLoad() async {
    add(RectangleHitbox());
    position = Vector2(random.nextDouble() * gameRef.size.x, 50);
    velocity = Vector2(random.nextBool() ? 1 : -1, random.nextBool() ? 1 : -1)..normalize();
  }

  @override
  void render(Canvas canvas) => canvas.drawRect(size.toRect(), _paint);

  @override
  void update(double dt) {
    super.update(dt);
    position.add(velocity * speed * dt);
    if (position.x <= width / 2 || position.x >= gameRef.size.x - width / 2) velocity.x *= -1;
    if (position.y <= height / 2 || position.y >= gameRef.size.y - height / 2) velocity.y *= -1;
  }
  @override
  void onCollisionStart(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollisionStart(intersectionPoints, other);
    if (other is Player) {
      gameRef.takeDamage();
      other.position.add(velocity * 50);
    }
  }
}
