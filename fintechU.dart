import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
  ));
  runApp(const GooglePayCloneApp());
}

class GooglePayCloneApp extends StatelessWidget {
  const GooglePayCloneApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PayEngine Sovereign',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF8FAFC),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF4F46E5),
        ),
        textTheme: const TextTheme(
          headlineMedium: TextStyle(fontWeight: FontWeight.w900, letterSpacing: -1.5, color: Color(0xFF0F172A)),
          titleLarge: TextStyle(fontWeight: FontWeight.w800, letterSpacing: -0.5, color: Color(0xFF0F172A)),
        ),
      ),
      home: const AuthenticationWrapper(),
    );
  }
}
class TransactionModel {
  final String id;
  final String contactName;
  final String type;
  final String message;
  final double amount;

  const TransactionModel({
    required this.id,
    required this.contactName,
    required this.type,
    required this.message,
    required this.amount,
  });

  factory TransactionModel.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? const {};
    return TransactionModel(
      id: doc.id,
      contactName: data['contactName'] ?? '',
      type: data['type'] ?? 'chat',
      message: data['message'] ?? '',
      amount: (data['amount'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
class AuthenticationWrapper extends StatelessWidget {
  const AuthenticationWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: SovereignLoadingPlaceholder()));
        }
        if (snapshot.hasData) {
          return const MainNavigationController();
        }
        return const SovereignLoginScreen();
      },
    );
  }
}

class SovereignLoadingPlaceholder extends StatelessWidget {
  const SovereignLoadingPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF8FAFC),
      child: Center(
        child: SizedBox(
          width: 48,
          height: 48,
          child: CircularProgressIndicator(
            strokeWidth: 3,
            valueColor: AlwaysStoppedAnimation<Color>(const Color(0xFF4F46E5).withOpacity(0.6)),
          ),
        ),
      ),
    );
  }
}

class SovereignLoginScreen extends StatefulWidget {
  const SovereignLoginScreen({super.key});

  @override
  State<SovereignLoginScreen> createState() => _SovereignLoginScreenState();
}

class _SovereignLoginScreenState extends State<SovereignLoginScreen> {
  final ValueNotifier<bool> _loadingState = ValueNotifier<bool>(false);

  void _authenticateSandbox() async {
    HapticFeedback.mediumImpact();
    _loadingState.value = true;
    try {
      await FirebaseAuth.instance.signInAnonymously();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Sandbox Access Denied: $e')));
      }
    } finally {
      if (mounted) {
        _loadingState.value = false;
      }
    }
  }

  @override
  void dispose() {
    _loadingState.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFFFFFFF), Color(0xFFEEF2FF)],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  height: 68,
                  width: 68,
                  decoration: BoxDecoration(
                    color: const Color(0xFF4F46E5),
                    borderRadius: BorderRadius.circular(22),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF4F46E5).withOpacity(0.25),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      )
                    ],
                  ),
                  child: const Icon(Icons.token_rounded, size: 34, color: Colors.white),
                ),
              ),
              const SizedBox(height: 40),
              Text('Sovereign Pay', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontSize: 44)),
              const SizedBox(height: 12),
              const Text(
                'Zero-overhead transactional matrix featuring synchronized relational rendering loops.',
                style: TextStyle(color: Color(0xFF475569), fontSize: 15, height: 1.6),
              ),
              const SizedBox(height: 56),
              ValueListenableBuilder<bool>(
                valueListenable: _loadingState,
                builder: (context, isLoading, _) {
                  return ElevatedButton(
                    onPressed: isLoading ? null : _authenticateSandbox,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0F172A),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                      elevation: 0,
                    ),
                    child: isLoading 
                        ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : const Text('Access Runtime Terminal', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, letterSpacing: 0.3)),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MainNavigationController extends StatefulWidget {
  const MainNavigationController({super.key});

  @override
  State<MainNavigationController> createState() => _MainNavigationControllerState();
}

class _MainNavigationControllerState extends State<MainNavigationController> {
  int _currentIndex = 0;
  final List<Widget> _screens = const [
    DashboardScreen(),
    PaymentHistoryScreen(),
    RewardsGameScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        indicatorColor: const Color(0xFFE0E7FF),
        labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
        onDestinationSelected: (index) {
          if (index != _currentIndex) {
            HapticFeedback.selectionClick();
            setState(() => _currentIndex = index);
          }
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.compass_calibration_outlined, size: 22), selectedIcon: Icon(Icons.compass_calibration_rounded, color: Color(0xFF4F46E5)), label: 'Wallet'),
          NavigationDestination(icon: Icon(Icons.insert_chart_outlined_rounded, size: 22), selectedIcon: Icon(Icons.insert_chart_rounded, color: Color(0xFF4F46E5)), label: 'Metrics'),
          NavigationDestination(icon: Icon(Icons.gamepad_outlined, size: 22), selectedIcon: Icon(Icons.gamepad_rounded, color: Color(0xFF4F46E5)), label: 'Arcade'),
        ],
      ),
    );
  }
}

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final ValueNotifier<bool> _obscureBalance = ValueNotifier<bool>(false);

  final List<Map<String, String>> mockContacts = const [
    {'name': 'Alex Rivera', 'initials': 'AR', 'color': '0xFF4F46E5'},
    {'name': 'Beatriz Cruz', 'initials': 'BC', 'color': '0xFF10B981'},
    {'name': 'Charlie Kim', 'initials': 'CK', 'color': '0xFFF59E0B'},
    {'name': 'Diana Prince', 'initials': 'DP', 'color': '0xFFEF4444'},
    {'name': 'Evan Wright', 'initials': 'EW', 'color': '0xFF8B5CF6'},
  ];

  @override
  void dispose() {
    _obscureBalance.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              sliver: SliverToBoxAdapter(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Sovereign Node', style: theme.textTheme.titleLarge?.copyWith(fontSize: 22, fontWeight: FontWeight.w900)),
                    IconButton(
                      icon: const Icon(Icons.logout_rounded, color: Color(0xFF64748B), size: 22),
                      onPressed: () {
                        HapticFeedback.heavyImpact();
                        FirebaseAuth.instance.signOut();
                      },
                    )
                  ],
                ),
              ),
            ),
            
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.horizontal(24),
                child: Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(36),
                    boxShadow: [
                      BoxShadow(color: const Color(0xFF0F172A).withOpacity(0.12), blurRadius: 24, offset: const Offset(0, 12))
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Available Capital Assets', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 13, fontWeight: FontWeight.w600, letterSpacing: 0.5)),
                          GestureDetector(
                            onTap: () {
                              HapticFeedback.lightImpact();
                              _obscureBalance.value = !_obscureBalance.value;
                            },
                            child: const Icon(Icons.all_inclusive_rounded, color: Colors.white, size: 20),
                          )
                        ],
                      ),
                      const SizedBox(height: 16),
                      ValueListenableBuilder<bool>(
                        valueListenable: _obscureBalance,
                        builder: (context, isObscured, _) {
                          return AnimatedCrossFade(
                            firstChild: const Text('\$84,192.00', style: TextStyle(color: Colors.white, fontSize: 38, fontWeight: FontWeight.w900, letterSpacing: -1.0)),
                            secondChild: const Text('••••••', style: TextStyle(color: Colors.white, fontSize: 38, fontWeight: FontWeight.w900, letterSpacing: 3.0)),
                            crossFadeState: isObscured ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                            duration: const Duration(milliseconds: 200),
                          );
                        },
                      ),
                      const SizedBox(height: 32),
                      Row(
                        children: [
                          Container(height: 8, width: 8, decoration: const BoxDecoration(color: Color(0xFF10B981), shape: BoxShape.circle)),
                          const SizedBox(width: 8),
                          const Text('NODE INSTANCE ONLINE', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 1.2)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildDynamicActionNode(context, Icons.qr_code_scanner_rounded, 'Scan QR', () {
                      HapticFeedback.mediumImpact();
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const QRScannerSimScreen()));
                    }),
                    _buildDynamicActionNode(context, Icons.swap_horizontal_circle_rounded, 'Transfer', () => HapticFeedback.lightImpact()),
                    _buildDynamicActionNode(context, Icons.widgets_rounded, 'Services', () => HapticFeedback.lightImpact()),
                    _buildDynamicActionNode(context, Icons.shield_rounded, 'Vault', () => HapticFeedback.lightImpact()),
                  ],
                ),
              ),
            ),

            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              sliver: SliverToBoxAdapter(
                child: Text('Instant Transmissions', style: theme.textTheme.titleLarge?.copyWith(fontSize: 16, fontWeight: FontWeight.w900)),
              ),
            ),

            SliverPadding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              sliver: SliverToBoxAdapter(
                child: SizedBox(
                  height: 110,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.horizontal(24),
                    physics: const BouncingScrollPhysics(),
                    itemCount: mockContacts.length,
                    itemBuilder: (context, index) {
                      final contact = mockContacts[index];
                      final avatarColor = Color(int.parse(contact['color']!));
                      return Padding(
                        padding: const EdgeInsets.trailing(22),
                        child: GestureDetector(
                          onTap: () {
                            HapticFeedback.mediumImpact();
                            Navigator.push(context, MaterialPageRoute(builder: (_) => ChatAndPayScreen(contactName: contact['name']!)));
                          },
                          child: Column(
                            children: [
                              CircleAvatar(
                                radius: 28,
                                backgroundColor: avatarColor.withOpacity(0.12),
                                child: Text(contact['initials']!, style: TextStyle(fontWeight: FontWeight.w900, color: avatarColor, fontSize: 14)),
                              ),
                              const SizedBox(height: 10),
                              Text(contact['name']!.split(' ')[0], style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Color(0xFF1E293B))),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildDynamicActionNode(BuildContext context, IconData icon, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(26),
              boxShadow: [BoxShadow(color: const Color(0xFF0F172A).withOpacity(0.025), blurRadius: 16, offset: const Offset(0, 8))],
            ),
            child: Icon(icon, size: 26, color: const Color(0xFF4F46E5)),
          ),
          const SizedBox(height: 10),
          Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Color(0xFF475569))),
        ],
      ),
    );
  }
}
class QRScannerSimScreen extends StatefulWidget {
  const QRScannerSimScreen({super.key});

  @override
  State<QRScannerSimScreen> createState() => _QRScannerSimScreenState();
}

class _QRScannerSimScreenState extends State<QRScannerSimScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(duration: const Duration(seconds: 2), vsync: this)..repeat(reverse: true);
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF090D16),
      appBar: AppBar(backgroundColor: Colors.transparent, foregroundColor: Colors.white, title: const Text('Unified Core Scanner', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold))),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(44),
                border: Border.all(color: Colors.white.withOpacity(0.08), width: 2),
              ),
              child: RepaintBoundary(
                child: AnimatedBuilder(
                  animation: _animController,
                  builder: (context, child) {
                    return CustomPaint(size: Size.infinite, painter: ModernScannerLinePainter(_animController.value));
                  },
                ),
              ),
            ),
            const SizedBox(height: 64),
            ElevatedButton(
              onPressed: () {
                HapticFeedback.heavyImpact();
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const ChatAndPayScreen(contactName: "Sovereign Retail Terminal")));
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: const Color(0xFF090D16), padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18))),
              child: const Text('Capture Mock Verification Sync', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.2)),
            )
          ],
        ),
      ),
    );
  }
}

class ModernScannerLinePainter extends CustomPainter {
  final double animationValue;
  ModernScannerLinePainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = const LinearGradient(colors: [Colors.transparent, Color(0xFF4F46E5), Colors.transparent]).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..strokeWidth = 5.0;
    final y = size.height * animationValue;
    canvas.drawLine(Offset(6, y), Offset(size.width - 6, y), paint);
  }

  @override
  bool shouldRepaint(covariant ModernScannerLinePainter oldDelegate) => oldDelegate.animationValue != animationValue;
}
class ChatAndPayScreen extends StatefulWidget {
  final String contactName;
  const ChatAndPayScreen({required this.contactName, super.key});

  @override
  State<ChatAndPayScreen> createState() => _ChatAndPayScreenState();
}

class _ChatAndPayScreenState extends State<ChatAndPayScreen> {
  final TextEditingController _messageController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();

  void _dispatchTransaction({required String type, double amount = 0.0}) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final dataNode = {
      'senderId': user.uid,
      'contactName': widget.contactName,
      'type': type,
      'message': type == 'chat' ? _messageController.text.trim() : 'Transferred asset value totaling \$${amount.toStringAsFixed(2)}',
      'amount': amount,
      'timestamp': FieldValue.serverTimestamp(),
    };

    _messageController.clear();
    await FirebaseFirestore.instance.collection('transactions').add(dataNode);
  }

  @override
  void dispose() {
    _messageController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(title: Text(widget.contactName, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)), elevation: 0, backgroundColor: Colors.white),
      body: Column(
        children: [
          Expanded(child: _ChatStreamView(contactName: widget.contactName)),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: const BoxDecoration(color: Colors.white, border: Border(top: BorderSide(color: Color(0xFFF1F5F9)))),
            child: SafeArea(
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.add_link_rounded, color: Color(0xFF4F46E5), size: 26),
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      _openPaymentMatrix(context);
                    },
                  ),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.horizontal(20),
                      decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(32)),
                      child: TextField(
                        controller: _messageController,
                        decoration: const InputDecoration(hintText: 'Type transaction payload metadata...', border: InputBorder.none, hintStyle: TextStyle(fontSize: 14, color: Color(0xFF94A3B8))),
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  IconButton(
                    icon: const Icon(Icons.arrow_forward_rounded, color: Color(0xFF4F46E5)),
                    onPressed: () {
                      if (_messageController.text.trim().isNotEmpty) {
                        HapticFeedback.mediumImpact();
                        _dispatchTransaction(type: 'chat');
                      }
                    },
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  void _openPaymentMatrix(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(36))),
      builder: (context) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 24, right: 24, top: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Sovereign Payment Routing to ${widget.contactName}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF64748B))),
            const SizedBox(height: 16),
            TextField(
              controller: _amountController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              textAlign: TextAlign.center,
              autofocus: true,
              style: const TextStyle(fontSize: 54, fontWeight: FontWeight.w900, color: Color(0xFF0F172A), letterSpacing: -1.0),
              decoration: const InputDecoration(hintText: '\$0.00', border: InputBorder.none),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                final balanceValue = double.tryParse(_amountController.text) ?? 0.0;
                if (balanceValue > 0) {
                  HapticFeedback.heavyImpact();
                  _dispatchTransaction(type: 'payment', amount: balanceValue);
                  _amountController.clear();
                  Navigator.pop(context);
                }
              },
              style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 56), backgroundColor: const Color(0xFF0F172A), foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18))),
              child: const Text('Execute Financial Transfer Protocol', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.2)),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _ChatStreamView extends StatelessWidget {
  final String contactName;
  const _ChatStreamView({required this.contactName});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('transactions')
          .where('contactName', isEqualTo: contactName)
          .orderBy('timestamp', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: SovereignLoadingPlaceholder());
        
        final docs = snapshot.data!.docs;
        if (docs.isEmpty) return const Center(child: Text('No previous transactions.', style: TextStyle(color: Color(0xFF94A3B8))));

        return ListView.builder(
          reverse: true,
          padding: const EdgeInsets.all(24),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final model = TransactionModel.fromDoc(docs[index]);
            final bool isPayment = model.type == 'payment';

            return Align(
              alignment: isPayment ? Alignment.center : Alignment.centerRight,
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 8),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                decoration: BoxDecoration(
                  color: isPayment ? const Color(0xFFEEF2FF) : Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(20),
                    topRight: const Radius.circular(20),
                    bottomLeft: const Radius.circular(20),
                    bottomRight: isPayment ? const Radius.circular(20) : const Radius.circular(4),
                  ),
                  border: isPayment ? Border.all(color: const Color(0xFFC7D2FE)) : null,
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.015), blurRadius: 8, offset: const Offset(0, 4))],
                ),
                child: Text(
                  model.message,
                  textAlign: isPayment ? TextAlign.center : TextAlign.start,
                  style: TextStyle(
                    fontSize: 14, 
                    fontWeight: isPayment ? FontWeight.w800 : FontWeight.w600, 
                    color: isPayment ? const Color(0xFF3730A3) : const Color(0xFF334155),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class PaymentHistoryScreen extends StatelessWidget {
  const PaymentHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Resource Analytics', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)), elevation: 0, backgroundColor: Colors.transparent),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('transactions').limit(30).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: SovereignLoadingPlaceholder());
          final docs = snapshot.data!.docs;

          return CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Container(
                    padding: const EdgeInsets.all(28),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(32)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Volumetric Asset Flow', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: Color(0xFF0F172A))),
                        const SizedBox(height: 28),
                        SizedBox(
                          height: 150,
                          width: double.infinity,
                          child: RepaintBoundary(
                            child: CustomPaint(painter: AdvancedExpenditureChartPainter()),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                sliver: SliverToBoxAdapter(child: Text('Audit Ledger', style: theme.textTheme.titleLarge?.copyWith(fontSize: 15, fontWeight: FontWeight.w900, color: const Color(0xFF475569)))),
              ),

              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    if (docs.isEmpty) {
                      return const Center(child: Padding(padding: EdgeInsets.all(32.0), child: Text('No metrics localized.')));
                    }
                    final model = TransactionModel.fromDoc(docs[index]);
                    final bool isPayment = model.type == 'payment';

                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: isPayment ? const Color(0xFFECFDF5) : const Color(0xFFF1F5F9),
                          child: Icon(isPayment ? Icons.arrow_outward_rounded : Icons.currency_exchange, color: isPayment ? const Color(0xFF10B981) : const Color(0xFF4F46E5), size: 16),
                        ),
                        title: Text(model.contactName, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: Color(0xFF1E293B))),
                        subtitle: Text(model.message, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                        trailing: isPayment 
                            ? Text('\$${model.amount.toStringAsFixed(2)}', style: const TextStyle(color: Color(0xFF10B981), fontWeight: FontWeight.w900))
                            : const Text('Data', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 11, fontWeight: FontWeight.bold)),
                      ),
                    );
                  },
                  childCount: docs.length,
                ),
              )
            ],
          );
        },
      ),
    );
  }
}

class AdvancedExpenditureChartPainter extends CustomPainter {
  static final Paint _gridPaint = Paint()
    ..color = const Color(0xFFF1F5F9)
    ..strokeWidth = 1.0;

  static final Paint _linePaint = Paint()
    ..color = const Color(0xFF4F46E5)
    ..strokeWidth = 4.5
    ..style = PaintingStyle.stroke
    ..strokeCap = StrokeCap.round;

  @override
  void paint(Canvas canvas, Size size) {
    for (var i = 1; i <= 3; i++) {
      final y = size.height * (i / 4);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), _gridPaint);
    }

    final areaPaint = Paint()
      ..shader = LinearGradient(
        colors: [const Color(0xFF4F46E5).withOpacity(0.12), const Color(0xFF4F46E5).withOpacity(0.0)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    final splinePath = Path();
    splinePath.moveTo(0, size.height * 0.9);
    splinePath.cubicTo(size.width * 0.2, size.height * 0.8, size.width * 0.25, size.height * 0.15, size.width * 0.5, size.height * 0.35);
    splinePath.cubicTo(size.width * 0.7, size.height * 0.5, size.width * 0.75, size.height * 0.05, size.width, size.height * 0.1);

    final areaPath = Path.from(splinePath);
    areaPath.lineTo(size.width, size.height);
    areaPath.lineTo(0, size.height);
    areaPath.close();

    canvas.drawPath(areaPath, areaPaint);
    canvas.drawPath(splinePath, _linePaint);
  }

  @override
  bool shouldRepaint(covariant AdvancedExpenditureChartPainter oldDelegate) => false;
}
class RewardsGameScreen extends StatefulWidget {
  const RewardsGameScreen({super.key});

  @override
  State<RewardsGameScreen> createState() => _RewardsGameScreenState();
}

class _RewardsGameScreenState extends State<RewardsGameScreen> {
  final ValueNotifier<int> _scoreTracker = ValueNotifier<int>(0);
  late final SovereignCashbackEngine _gameEngine;

  @override
  void initState() {
    super.initState();
    _gameEngine = SovereignCashbackEngine(scoreNotifier: _scoreTracker);
  }

  @override
  void dispose() {
    _scoreTracker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Arcade Ledger Rewards', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)), elevation: 0, backgroundColor: Colors.transparent),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
              decoration: BoxDecoration(color: const Color(0xFFEEF2FF), borderRadius: BorderRadius.circular(24)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Intercept tokens to credit dividend balances.', style: TextStyle(fontWeight: FontWeight.w800, color: Color(0xFF3730A3), fontSize: 12)),
                  ValueListenableBuilder<int>(
                    valueListenable: _scoreTracker,
                    builder: (context, currentScore, _) {
                      return Text('\$${(currentScore * 0.10).toStringAsFixed(2)}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF4F46E5)));
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Container(
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(36), border: Border.all(color: const Color(0xFFE2E8F0))),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(36),
                  child: RepaintBoundary(
                    child: GameWidget(game: _gameEngine),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class SovereignCashbackEngine extends FlameGame with HasTapCallbacks {
  final ValueNotifier<int> scoreNotifier;
  double _timer = 0.0;
  final math.Random _rng = math.Random();
  
  final List<PhysicsToken> _tokenPool = [];

  SovereignCashbackEngine({required this.scoreNotifier});

  @override
  Color backgroundColor() => const Color(0xFFFFFFFF);

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    for (int i = 0; i < 12; i++) {
      final token = PhysicsToken(
        onCollected: () {
          HapticFeedback.lightImpact();
          scoreNotifier.value += 5;
        },
      );
      _tokenPool.add(token);
      add(token);
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    _timer += dt;
    if (_timer > 0.65) {
      _timer = 0.0;
      final xCoordinate = _rng.nextDouble() * (size.x - 50) + 25;
      
      final pooledToken = _tokenPool.firstWhere(
        (token) => !token.isActive,
        orElse: () => _tokenPool.first,
      );
      
      pooledToken.activateToken(xCoordinate);
    }
  }
}

class PhysicsToken extends CircleComponent with TapCallbacks {
  final VoidCallback onCollected;
  bool isActive = false;
  static const double descentConstant = 350.0;
  static final Paint _sharedTokenPaint = Paint()..color = const Color(0xFF4F46E5);

  PhysicsToken({required this.onCollected})
      : super(radius: 16, paint: _sharedTokenPaint) {
    position = Vector2(-200, -200);
  }

  void activateToken(double x) {
    position.setValues(x, -20);
    isActive = true;
  }

  @override
  void render(Canvas canvas) {
    if (isActive) super.render(canvas);
  }

  @override
  void update(double dt) {
    if (!isActive) return;
    super.update(dt);
    position.y += descentConstant * dt;
    if (position.y > 900) {
      isActive = false;
      position.setValues(-200, -200);
    }
  }

  @override
  void onTapDown(TapDownEvent event) {
    if (!isActive) return;
    isActive = false;
    position.setValues(-200, -200);
    onCollected();
  }
}
