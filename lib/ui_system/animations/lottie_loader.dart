import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

/// Loads and plays a Lottie animation from the assets/lottie/ directory.
///
/// Usage:
///   LottieAssetWidget(asset: 'assets/lottie/loading.json', size: 160)
class LottieAssetWidget extends StatelessWidget {
  const LottieAssetWidget({
    super.key,
    required this.asset,
    this.size,
    this.repeat = true,
    this.fit = BoxFit.contain,
  });

  final String asset;
  final double? size;
  final bool repeat;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    final widget = Lottie.asset(
      asset,
      fit: fit,
      repeat: repeat,
      errorBuilder: (context, error, stackTrace) {
        return _fallbackIcon(context);
      },
    );
    if (size != null) {
      return SizedBox(width: size, height: size, child: widget);
    }
    return widget;
  }

  Widget _fallbackIcon(BuildContext context) {
    final name = asset.split('/').last.replaceAll('.json', '');
    final icon = switch (name) {
      'empty_trash' => Icons.delete_outline,
      'empty_search' => Icons.search_off,
      'export_success' => Icons.check_circle_outline,
      'loading' => Icons.hourglass_empty,
      _ => Icons.animation,
    };
    final color = switch (name) {
      'export_success' => const Color(0xFF4CAF50),
      _ => Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.38),
    };
    return Icon(icon, size: size ?? 64, color: color);
  }
}

/// Convenience widget combining a Lottie animation with a descriptive message.
///
/// Usage:
///   LottieEmptyState(
///     asset: 'assets/lottie/empty_trash.json',
///     message: '回收站是空的',
///   )
class LottieEmptyState extends StatelessWidget {
  const LottieEmptyState({
    super.key,
    required this.asset,
    required this.message,
    this.animationSize = 120,
    this.action,
  });

  final String asset;
  final String message;
  final double animationSize;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            LottieAssetWidget(asset: asset, size: animationSize, repeat: true),
            const SizedBox(height: 20),
            Text(
              message,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withValues(
                  alpha: 0.62,
                ),
              ),
              textAlign: TextAlign.center,
            ),
            if (action != null) ...[
              const SizedBox(height: 16),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}
