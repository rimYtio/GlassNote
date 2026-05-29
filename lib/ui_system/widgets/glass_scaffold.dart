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
  });

  final String title;
  final Widget body;
  final List<Widget> actions;
  final Widget? leading;

  @override
  Widget build(BuildContext context) {
    final effectiveLeading =
        leading ??
        (Navigator.of(context).canPop()
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  HapticFeedback.lightImpact();
                  Navigator.of(context).pop();
                },
              )
            : null);

    final colorScheme = Theme.of(context).colorScheme;
    final isLight = Theme.of(context).brightness == Brightness.light;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // Layer 1: Warm pink/lavender orb (top-right, 300×300, blur 200, 15% opacity)
          Positioned(
            top: -80,
            right: -60,
            child: ClipRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 200, sigmaY: 200),
                child: Container(
                  width: 300,
                  height: 300,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0x26F0D0E0),
                  ),
                ),
              ),
            ),
          ),

          // Layer 2: Sky blue orb (bottom-center, 350×350, blur 200, 15% opacity)
          Align(
            alignment: Alignment.bottomCenter,
            child: Transform.translate(
              offset: const Offset(0, 120),
              child: ClipRect(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 200, sigmaY: 200),
                  child: Container(
                    width: 350,
                    height: 350,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0x26B0D8F0),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Layer 3: Ethereal gradient overlay
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isLight ? const [
                  Color.fromRGBO(215, 235, 252, 0.32),
                  Color.fromRGBO(235, 245, 255, 0.15),
                  Color.fromRGBO(255, 255, 255, 0.05),
                ] : [
                  colorScheme.surfaceContainerHighest.withValues(alpha: 0.15),
                  colorScheme.surface.withValues(alpha: 0.08),
                  colorScheme.surfaceContainerLowest.withValues(alpha: 0.03),
                ],
              ),
              border: Border.all(
                color: isLight 
                    ? Colors.white.withValues(alpha: 0.22)
                    : colorScheme.outlineVariant.withValues(alpha: 0.12),
                width: 1.0,
              ),
            ),
          ),

          // Layer 4: Grain texture (1.5% opacity)
          Positioned.fill(
            child: CustomPaint(painter: _GrainPainter()),
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
