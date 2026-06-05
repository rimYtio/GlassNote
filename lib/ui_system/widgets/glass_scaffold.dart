import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class GlassScaffold extends StatelessWidget {
  const GlassScaffold({
    required this.title,
    required this.body,
    super.key,
    this.actions = const [],
    this.leading,
    this.resizeToAvoidBottomInset,
  });

  final String title;
  final Widget body;
  final List<Widget> actions;
  final Widget? leading;
  final bool? resizeToAvoidBottomInset;

  @override
  Widget build(BuildContext context) {
    final effectiveLeading =
        leading ??
        (Navigator.of(context).canPop()
            ? IconButton(
                tooltip: '返回',
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  HapticFeedback.lightImpact();
                  Navigator.of(context).pop();
                },
              )
            : null);

    final isLight = Theme.of(context).brightness == Brightness.light;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      body: Stack(
        children: [
          // Layer 0: Background vertical gradient
          if (isLight)
            Positioned.fill(
              child: IgnorePointer(
                child: DecoratedBox(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Color(0xFFEAF1F7), Color(0xFFDDE7F1)],
                    ),
                  ),
                ),
              ),
            ),

          // Layer 1: Warm pink/lavender orb (top-right, 420×420, blur 200, ~40% opacity)
          Positioned(
            top: -100,
            right: -80,
            child: IgnorePointer(
              child: ClipRect(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 200, sigmaY: 200),
                  child: Stack(
                    children: [
                      Container(
                        width: 420,
                        height: 420,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0x66F0D5DF),
                        ),
                      ),
                      Container(
                        width: 420,
                        height: 420,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            center: Alignment.center,
                            radius: 0.8,
                            colors: [
                              Colors.white.withValues(alpha: 0.0),
                              const Color.fromRGBO(176, 140, 155, 0.22),
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

          // Layer 2: Sky blue orb (bottom-center, 460×460, blur 200, ~35% opacity)
          Align(
            alignment: Alignment.bottomCenter,
            child: IgnorePointer(
              child: Transform.translate(
                offset: const Offset(0, 120),
                child: SizedBox(
                  key: const ValueKey('glass-background-blue-orb'),
                  width: 460,
                  height: 460,
                  child: ClipRect(
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 200, sigmaY: 200),
                      child: Stack(
                        children: [
                          Container(
                            width: 460,
                            height: 460,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Color(0x59C0DEF2),
                            ),
                          ),
                          Container(
                            width: 460,
                            height: 460,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: RadialGradient(
                                center: Alignment.center,
                                radius: 0.8,
                                colors: [
                                  Colors.white.withValues(alpha: 0.0),
                                  const Color.fromRGBO(140, 180, 210, 0.22),
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

          // Layer 3: Ethereal gradient overlay
          IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isLight
                      ? const [
                          Color.fromRGBO(240, 246, 252, 0.20),
                          Color.fromRGBO(228, 238, 248, 0.10),
                          Color.fromRGBO(232, 239, 246, 0.0),
                        ]
                      : const [
                          Color.fromRGBO(255, 255, 255, 0.04),
                          Color.fromRGBO(255, 255, 255, 0.02),
                          Color.fromRGBO(255, 255, 255, 0.0),
                        ],
                ),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.18),
                  width: 1.0,
                ),
              ),
            ),
          ),

          // Layer 4: Grain texture (1.5% opacity)
          Positioned.fill(
            child: IgnorePointer(child: CustomPaint(painter: _GrainPainter())),
          ),

          // Layer 5: Content
          SafeArea(
            bottom: false,
            child: Column(
              children: [
                GlassToolbar(
                  title: title,
                  leading: effectiveLeading,
                  actions: actions,
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                    child: body,
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

class GlassToolbar extends StatelessWidget {
  const GlassToolbar({
    required this.title,
    super.key,
    this.leading,
    this.actions = const [],
  });

  final String title;
  final Widget? leading;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 4),
      child: Row(
        children: [
          SizedBox(width: 48, child: leading),
          Expanded(
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
            ),
          ),
          ...actions,
        ],
      ),
    );
  }
}

class _GrainPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.black.withValues(alpha: 0.015);
    final rng = math.Random(42); // fixed seed for consistency
    final area = size.width * size.height;
    final numDots = (area * 0.08).toInt().clamp(0, 8000);
    for (int i = 0; i < numDots; i++) {
      final x = rng.nextDouble() * size.width;
      final y = rng.nextDouble() * size.height;
      final alpha = 0.005 + rng.nextDouble() * 0.01;
      paint.color = Colors.black.withValues(alpha: alpha);
      canvas.drawCircle(Offset(x, y), 0.5, paint);
    }
  }

  @override
  bool shouldRepaint(_GrainPainter oldDelegate) => false;
}
