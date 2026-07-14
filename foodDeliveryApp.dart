import 'dart:async';
import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
  ));

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const ZomatoMasterApp());
}

class ZomatoMasterApp extends StatelessWidget {
  const ZomatoMasterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Zomato V5',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFFE23744),
        scaffoldBackgroundColor: const Color(0xFFF4F4F6),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: false,
        ),
      ),
      home: const AuthStateWrapper(),
    );
  }
}

class AuthStateWrapper extends StatelessWidget {
  const AuthStateWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const LoadingSkeleton();
        }
        if (snapshot.hasData && snapshot.data != null) {
          return const MainNavigationScreen();
        }
        return const PhoneAuthScreen();
      },
    );
  }
}

class PhoneAuthScreen extends StatefulWidget {
  const PhoneAuthScreen({super.key});

  @override
  State<PhoneAuthScreen> createState() => _PhoneAuthScreenState();
}

class _PhoneAuthScreenState extends State<PhoneAuthScreen> {
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  void _triggerHaptic() => HapticFeedback.lightImpact();

  Future<void> _authenticate() async {
    _triggerHaptic();
    if (_phoneController.text.length < 7 || _passwordController.text.length < 6) return;

    setState(() => _isLoading = true);
    final dummyEmail = "${_phoneController.text.replaceAll(RegExp(r'[^0-9]'), '')}@zomatoclone.com";

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: dummyEmail,
        password: _passwordController.text,
      );
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: dummyEmail,
          password: _passwordController.text,
        );
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: ${e.message}')));
        }
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(Icons.room_service_rounded, size: 90, color: Color(0xFFE23744)),
              const SizedBox(height: 48),
              const Text('Enter your details',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, letterSpacing: -0.5)),
              const SizedBox(height: 32),
              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: _glassInputDecoration('Phone Number', Icons.phone),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: _glassInputDecoration('Password', Icons.lock),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _isLoading ? null : _authenticate,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE23744),
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 5,
                  shadowColor: const Color(0xFFE23744).withOpacity(0.5),
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text('Login securely',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _glassInputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: Colors.grey[600]),
      filled: true,
      fillColor: const Color(0xFFF4F4F6),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
      focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFE23744), width: 2)),
    );
  }
}

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});
  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: const [DeliveryTab(), Center(child: Text('Profile Settings'))],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: const Color(0xFFE23744),
        onTap: (i) {
          HapticFeedback.selectionClick();
          setState(() => _currentIndex = i);
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.delivery_dining_rounded), label: 'Delivery'),
          BottomNavigationBarItem(icon: Icon(Icons.person_rounded), label: 'Profile'),
        ],
      ),
    );
  }
}

class DeliveryTab extends StatelessWidget {
  const DeliveryTab({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              children: [
                const Icon(Icons.location_on, color: Color(0xFFE23744), size: 28),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Home',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Colors.grey[800])),
                    Text('123 Tech Street, Dev City', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                  ],
                ),
                const Spacer(),
                CircleAvatar(backgroundColor: Colors.grey[300], child: const Icon(Icons.person, color: Colors.white)),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('restaurants')
                  .snapshots(includeMetadataChanges: true),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const LoadingSkeleton();

                final isOffline = snapshot.metadata.isFromCache;
                final docs = snapshot.data!.docs;

                return CustomScrollView(
                  physics: const BouncingScrollPhysics(),
                  slivers: [
                    if (isOffline)
                      SliverToBoxAdapter(
                        child: Container(
                          color: Colors.orange[100],
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.cloud_off, size: 16, color: Colors.deepOrange),
                              SizedBox(width: 8),
                              Text('Offline mode. Viewing saved data.',
                                  style: TextStyle(
                                      color: Colors.deepOrange, fontWeight: FontWeight.bold, fontSize: 12)),
                            ],
                          ),
                        ),
                      ),
                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final data = docs[index].data() as Map<String, dynamic>;
                          return _buildPremiumCard(context, docs[index].id, data);
                        },
                        childCount: docs.length,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumCard(BuildContext context, String id, Map<String, dynamic> data) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        Navigator.push(context, MaterialPageRoute(builder: (_) => OrderScreen(restaurantId: id, data: data)));
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, 10))],
        ),
        child: Column(
          children: [
            Hero(
              tag: 'hero_$id',
              child: Container(
                height: 180,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                  gradient: LinearGradient(colors: [Colors.grey[300]!, Colors.grey[400]!]),
                ),
                alignment: Alignment.bottomRight,
                padding: const EdgeInsets.all(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4)]),
                  child: Text('${data['eta']} min',
                      style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12)),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(data['name'] ?? 'Restaurant',
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
                      const SizedBox(height: 4),
                      Text(data['food_type'] ?? 'Cuisine',
                          style: TextStyle(color: Colors.grey[600], fontSize: 14, fontWeight: FontWeight.w500)),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(color: Colors.green[600], borderRadius: BorderRadius.circular(12)),
                    child: Row(
                      children: [
                        Text('${data['rating'] ?? 'NEW'}',
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 14)),
                        const SizedBox(width: 4),
                        const Icon(Icons.star, color: Colors.white, size: 14),
                      ],
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

class LoadingSkeleton extends StatelessWidget {
  const LoadingSkeleton({super.key});
  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.3, end: 1.0),
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeInOut,
      builder: (context, opacity, child) => Opacity(opacity: opacity, child: child),
      child: ListView.builder(
        itemCount: 4,
        padding: const EdgeInsets.all(16),
        itemBuilder: (_, __) => Container(
          margin: const EdgeInsets.only(bottom: 24),
          height: 250,
          decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(24)),
        ),
      ),
    );
  }
}

class OrderScreen extends StatelessWidget {
  final String restaurantId;
  final Map<String, dynamic> data;
  OrderScreen({super.key, required this.restaurantId, required this.data});

  final _nameCtrl = TextEditingController(text: "John Doe");
  final _phoneCtrl = TextEditingController();

  Future<void> _placeOrder(BuildContext context) async {
    HapticFeedback.heavyImpact();

    final orderRef = await FirebaseFirestore.instance.collection('orders').add({
      'restaurantName': data['name'],
      'customerName': _nameCtrl.text,
      'whatsappNumber': _phoneCtrl.text,
      'status': 'Preparing',
      'driverLocation': {'x': 100.0, 'y': 600.0},
      'timestamp': FieldValue.serverTimestamp(),
    });

    if (context.mounted) {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (_) => TrackingScreen(orderId: orderRef.id, phone: _phoneCtrl.text)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            iconTheme: const IconThemeData(color: Colors.white),
            flexibleSpace: FlexibleSpaceBar(
              background: Hero(tag: 'hero_$restaurantId', child: Container(color: Colors.grey[400])),
              title: Text(data['name'],
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      shadows: [Shadow(color: Colors.black54, blurRadius: 10)])),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Delivery Info', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
                  const SizedBox(height: 24),
                  TextField(
                      controller: _nameCtrl,
                      decoration: InputDecoration(
                          labelText: 'Recipient Name',
                          filled: true,
                          fillColor: Colors.grey[100],
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none))),
                  const SizedBox(height: 16),
                  TextField(
                      controller: _phoneCtrl,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                          labelText: 'WhatsApp Number',
                          filled: true,
                          fillColor: Colors.grey[100],
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none))),
                  const SizedBox(height: 48),
                  ElevatedButton(
                    onPressed: () => _placeOrder(context),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE23744),
                        minimumSize: const Size(double.infinity, 60),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                    child: const Text('Confirm Order',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}

class TrackingScreen extends StatefulWidget {
  final String orderId;
  final String phone;
  const TrackingScreen({super.key, required this.orderId, required this.phone});

  @override
  State<TrackingScreen> createState() => _TrackingScreenState();
}

class _TrackingScreenState extends State<TrackingScreen> {
  late CityTrackerGame _game;
  Timer? _sim;
  double dX = 100, dY = 600;

  @override
  void initState() {
    super.initState();
    _game = CityTrackerGame();
    _sim = Timer.periodic(const Duration(seconds: 1), (t) {
      dY -= 20;
      dX += 5;
      String status = 'Preparing';
      if (dY < 450) status = 'On the Way';
      if (dY < 150) {
        status = 'Arrived';
        t.cancel();
      }

      FirebaseFirestore.instance.collection('orders').doc(widget.orderId).update({
        'driverLocation': {'x': dX, 'y': dY},
        'status': status,
      });
    });
  }

  @override
  void dispose() {
    _sim?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('orders')
            .doc(widget.orderId)
            .snapshots(includeMetadataChanges: true),
        builder: (context, snapshot) {
          final data = snapshot.data?.data() as Map<String, dynamic>? ?? {};
          final status = data['status'] ?? 'Connecting...';
          final isOffline = snapshot.metadata.isFromCache;

          if (data['driverLocation'] != null) {
            _game.updatePosition(Vector2(
                data['driverLocation']['x'].toDouble(), data['driverLocation']['y'].toDouble()));
          }

          return Stack(
            children: [
              Positioned.fill(child: GameWidget(game: _game)),
              if (isOffline)
                Positioned(
                  top: 50,
                  left: 20,
                  right: 20,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                        color: Colors.orange,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 10)]),
                    child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Icon(Icons.sync_problem, color: Colors.white, size: 20),
                      SizedBox(width: 8),
                      Text('Syncing offline data...',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ]),
                  ),
                ),
              Align(
                alignment: Alignment.bottomCenter,
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                    child: Container(
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.85),
                        border: Border(top: BorderSide(color: Colors.white.withOpacity(0.5), width: 1.5)),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                    color: const Color(0xFFE23744),
                                    borderRadius: BorderRadius.circular(20),
                                    boxShadow: [
                                      BoxShadow(
                                          color: const Color(0xFFE23744).withOpacity(0.4),
                                          blurRadius: 15,
                                          offset: const Offset(0, 5))
                                    ]),
                                child: const Icon(Icons.two_wheeler_rounded, color: Colors.white, size: 36),
                              ),
                              const SizedBox(width: 20),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(status.toUpperCase(),
                                        style: const TextStyle(
                                            color: Color(0xFFE23744),
                                            fontWeight: FontWeight.w900,
                                            letterSpacing: 1.5)),
                                    const SizedBox(height: 6),
                                    const Text('Arriving soon',
                                        style: TextStyle(
                                            fontSize: 26, fontWeight: FontWeight.w900, color: Colors.black87)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 32),
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton.icon(
                                  icon: const Icon(Icons.chat_bubble_rounded),
                                  label: const Text('WhatsApp'),
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF25D366),
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(vertical: 18),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                      elevation: 0),
                                  onPressed: () => launchUrl(Uri.parse(
                                      "whatsapp://send?phone=${widget.phone}&text=Ready for food!")),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: ElevatedButton.icon(
                                  icon: const Icon(Icons.fingerprint),
                                  label: const Text('Auth Delivery'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: status == 'Arrived' ? Colors.black : Colors.black12,
                                    foregroundColor: status == 'Arrived' ? Colors.white : Colors.black38,
                                    padding: const EdgeInsets.symmetric(vertical: 18),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                    elevation: 0,
                                  ),
                                  onPressed: status == 'Arrived'
                                      ? () {
                                          HapticFeedback.heavyImpact();
                                          Navigator.pop(context);
                                        }
                                      : null,
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              )
            ],
          );
        },
      ),
    );
  }
}

class CityTrackerGame extends FlameGame {
  late TrackerSprite driver;

  @override
  Color backgroundColor() => const Color(0xFFCAD2D3);

  @override
  Future<void> onLoad() async {
    super.onLoad();
    driver = TrackerSprite(position: Vector2(100, 600));
    add(driver);
  }

  @override
  void render(Canvas canvas) {
    final buildingPaint = Paint()..color = const Color(0xFFDDE4E5)..style = PaintingStyle.fill;
    final highlightPaint = Paint()..color = Colors.white..style = PaintingStyle.fill;

    for (int x = -50; x < 600; x += 120) {
      for (int y = -50; y < 900; y += 120) {
        canvas.drawRRect(
            RRect.fromRectAndRadius(Rect.fromLTWH(x.toDouble(), y.toDouble(), 90, 90), const Radius.circular(16)),
            buildingPaint);
        canvas.drawRRect(
            RRect.fromRectAndRadius(Rect.fromLTWH(x.toDouble(), y.toDouble(), 85, 85), const Radius.circular(16)),
            highlightPaint);
      }
    }

    final routePaint = Paint()
      ..color = const Color(0xFFE23744).withOpacity(0.3)
      ..strokeWidth = 12
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    canvas.drawLine(const Offset(100, 600), const Offset(120, 100), routePaint);

    super.render(canvas);
  }

  void updatePosition(Vector2 newPos) => driver.targetPosition = newPos;
}

class TrackerSprite extends PositionComponent {
  Vector2 targetPosition;
  double pulse = 0;

  TrackerSprite({required Vector2 position})
      : targetPosition = position,
        super(position: position, size: Vector2(50, 50));

  @override
  void update(double dt) {
    super.update(dt);
    position.lerp(targetPosition, dt * 4.0);
    pulse = (pulse + dt * 3) % 2;
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    final center = Offset(size.x / 2, size.y / 2);

    canvas.drawCircle(center, 15 + (pulse * 15),
        Paint()..color = const Color(0xFFE23744).withOpacity((2 - pulse) / 4));
    canvas.drawCircle(Offset(center.dx, center.dy + 4), 14, Paint()..color = Colors.black26);
    canvas.drawCircle(center, 16, Paint()..color = Colors.white);
    canvas.drawCircle(center, 10, Paint()..color = const Color(0xFFE23744));
  }
}

--------------pubspec.yaml----------------

dependencies:
  flutter:
    sdk: flutter
  firebase_core: ^3.0.0
  firebase_auth: ^5.0.0
  cloud_firestore: ^5.0.0
  flame: ^1.16.0
 
  url_launcher: ^6.3.0

-----------------------------------------

