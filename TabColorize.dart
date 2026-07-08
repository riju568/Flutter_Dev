import 'package:flutter/material.dart';

void main() {
  runApp(const PremiumAppEngine());
}

class PremiumAppEngine extends StatelessWidget {
  const PremiumAppEngine({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Premium Motion Hub',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xff060913),
      ),
      home: const PerspectiveGalleryScreen(),
    );
  }
}

class PerspectiveGalleryScreen extends StatefulWidget {
  const PerspectiveGalleryScreen({super.key});

  @override
  State<PerspectiveGalleryScreen> createState() =>
      _PerspectiveGalleryScreenState();
}

class _PerspectiveGalleryScreenState extends State<PerspectiveGalleryScreen> {
  Offset _pointerOffset = Offset.zero;
  bool _isHovering = false;
  int _activeCardIndex = 0;

  final List<Map<String, dynamic>> _galleryData = [
    {
      'title': 'Quantum Neural Core',
      'tag': 'AI SYNAPSE',
      'color1': const Color(0xff6366f1),
      'color2': const Color(0xffa855f7),
      'metric': '98.4 Flops',
    },
    {
      'title': 'Bionic Fluid Dynamics',
      'tag': 'VECTOR GRID',
      'color1': const Color(0xff06b6d4),
      'color2': const Color(0xff3b82f6),
      'metric': '0.002s Latency',
    },
    {
      'title': 'Astral Mesh Pipeline',
      'tag': '3D RENDER ENGINE',
      'color1': const Color(0xfff43f5e),
      'color2': const Color(0xffec4899),
      'metric': '144 FPS Lock',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          // LAYER 1: Ambient background matching active item color
          Positioned.fill(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 500),
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.center,
                  radius: 1.3,
                  colors: [
                    _galleryData[_activeCardIndex]['color1'].withOpacity(0.12),
                    const Color(0xff060913),
                  ],
                ),
              ),
            ),
          ),

          // LAYER 2: Main Layout
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Clean Custom Navigation Header
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24.0,
                    vertical: 16.0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.04),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.08),
                          ),
                        ),
                        child: const Row(
                          children: [
                            Icon(
                              Icons.blur_on_rounded,
                              color: Color(0xff818cf8),
                              size: 18,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'WORKSPACE ENGINE v4.2',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.8,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(
                          Icons.grid_view_rounded,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),

                const Spacer(),

                Center(
                  child: MouseRegion(
                    onEnter: (_) => setState(() => _isHovering = true),
                    onExit: (_) => setState(() {
                      _isHovering = false;
                      _pointerOffset = Offset.zero;
                    }),
                    onHover: (details) {
                      final RenderBox box =
                          context.findRenderObject() as RenderBox;
                      final Offset localPos = box.globalToLocal(
                        details.position,
                      );
                      setState(() {
                        _pointerOffset = Offset(
                          (localPos.dx - size.width / 2) / (size.width / 2),
                          (localPos.dy - size.height / 2) / (size.height / 2),
                        );
                      });
                    },
                    child: GestureDetector(
                      onPanUpdate: (details) {
                        setState(() {
                          _pointerOffset = Offset(
                            (details.localPosition.dx - 155) / 155,
                            (details.localPosition.dy - 210) / 210,
                          ).clamp(const Offset(-1, -1), const Offset(1, 1));
                        });
                      },
                      onPanEnd: (_) =>
                          setState(() => _pointerOffset = Offset.zero),
                      child: Transform(
                        transform: Matrix4.identity()
                          ..setEntry(3, 2, 0.0018) // Perspective depth mapping
                          ..rotateX(_isHovering ? -_pointerOffset.dy * 0.35 : 0)
                          ..rotateY(_isHovering ? _pointerOffset.dx * 0.35 : 0),
                        alignment: FractionalOffset.center,
                        child: Container(
                          height: 420,
                          width: 310,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(32),
                            boxShadow: [
                              BoxShadow(
                                color: _galleryData[_activeCardIndex]['color1']
                                    .withOpacity(0.25),
                                blurRadius: 40,
                                offset: const Offset(0, 15),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(32),
                            child: Stack(
                              children: [
                                // Solid dynamic core palette background
                                Positioned.fill(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          _galleryData[_activeCardIndex]['color1'],
                                          _galleryData[_activeCardIndex]['color2'],
                                        ],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                    ),
                                  ),
                                ),

                                // Geometric Matrix Grid Lining
                                Positioned.fill(
                                  child: Opacity(
                                    opacity: 0.10,
                                    child: CustomPaint(
                                      painter: CardGridPainter(),
                                    ),
                                  ),
                                ),

                                // Title Text Panel overlay
                                Positioned(
                                  bottom: 0,
                                  left: 0,
                                  right: 0,
                                  child: Container(
                                    padding: const EdgeInsets.all(24),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          Colors.black.withValues(alpha: 0.85),
                                          Colors.black.withValues(alpha: 0.0),
                                        ],
                                        begin: Alignment.bottomCenter,
                                        end: Alignment.topCenter,
                                      ),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          _galleryData[_activeCardIndex]['tag'],
                                          style: const TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w900,
                                            letterSpacing: 2,
                                            color: Colors.white60,
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          _galleryData[_activeCardIndex]['title'],
                                          style: const TextStyle(
                                            fontSize: 24,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                            height: 1.1,
                                          ),
                                        ),
                                        const SizedBox(height: 12),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              'METRIC METADATA',
                                              style: TextStyle(
                                                fontSize: 9,
                                                color: Colors.white.withValues(
                                                  alpha: 0.4,
                                                ),
                                                letterSpacing: 0.5,
                                              ),
                                            ),
                                            Text(
                                              _galleryData[_activeCardIndex]['metric'],
                                              style: const TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                const Spacer(),

                // LAYER 4: Navigation Tabs Selector
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'SELECT CORE MATRIX PIPELINE',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5,
                          color: Colors.white38,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: List.generate(_galleryData.length, (index) {
                          final bool isActive = _activeCardIndex == index;
                          return Expanded(
                            child: GestureDetector(
                              onTap: () =>
                                  setState(() => _activeCardIndex = index),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 250),
                                margin: EdgeInsets.only(
                                  right: index == _galleryData.length - 1
                                      ? 0
                                      : 10,
                                ),
                                height: 48,
                                decoration: BoxDecoration(
                                  color: isActive
                                      ? Colors.white.withValues(alpha: 0.08)
                                      : Colors.white.withValues(alpha: 0.02),
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: isActive
                                        ? _galleryData[index]['color1']
                                              .withOpacity(0.6)
                                        : Colors.white.withValues(alpha: 0.05),
                                    width: isActive ? 1.5 : 1,
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    '0${index + 1}',
                                    style: TextStyle(
                                      color: isActive
                                          ? Colors.white
                                          : Colors.white38,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        }),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

extension OffsetClampExtension on Offset {
  Offset clamp(Offset min, Offset max) {
    final dx = this.dx.clamp(min.dx, max.dx).toDouble();
    final dy = this.dy.clamp(min.dy, max.dy).toDouble();
    return Offset(dx, dy);
  }
}

class CardGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 1.0;

    const int steps = 12;
    final double stepWidth = size.width / steps;
    final double stepHeight = size.height / steps;

    for (int i = 0; i <= steps; i++) {
      canvas.drawLine(
        Offset(i * stepWidth, 0),
        Offset(i * stepWidth, size.height),
        paint,
      );
      canvas.drawLine(
        Offset(0, i * stepHeight),
        Offset(size.width, i * stepHeight),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
