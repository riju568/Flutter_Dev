import 'package:flutter/material.dart';

void main() {
  runApp(const SafeTapCounterApp());
}

class SafeTapCounterApp extends StatelessWidget {
  const SafeTapCounterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Zero-Loop Tap Counter',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(brightness: Brightness.dark, useMaterial3: true),
      home: const SafeCounterScreen(),
    );
  }
}

class SafeCounterScreen extends StatefulWidget {
  const SafeCounterScreen({super.key});

  @override
  State<SafeCounterScreen> createState() => _SafeCounterScreenState();
}

class _SafeCounterScreenState extends State<SafeCounterScreen> {
  int _counter = 0;

  void _handleScreenTap() {
    setState(() {
      _counter++;
    });
  }

  void _handleReset() {
    setState(() {
      _counter = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff121212),
      body: Stack(
        children: [
          // Full-screen structural Tap Target
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: _handleScreenTap,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'TAP COUNT',
                      style: TextStyle(
                        fontSize: 14,
                        letterSpacing: 6.0,
                        fontWeight: FontWeight.w600,
                        color: Colors.white.withValues(alpha: 0.4),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      '$_counter',
                      style: const TextStyle(
                        fontSize: 120,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Tap anywhere to count',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withValues(alpha: 0.3),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Reset Action Button aligned to safely clear state
          Positioned(
            top: MediaQuery.paddingOf(context).top + 16,
            right: 16,
            child: IconButton(
              icon: const Icon(Icons.refresh_rounded, size: 28),
              color: Colors.white.withValues(alpha: 0.6),
              onPressed: _handleReset,
            ),
          ),
        ],
      ),
    );
  }
}
