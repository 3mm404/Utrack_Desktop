import 'package:flutter/material.dart';

/// Lightweight opaque surfaces: no texture bitmaps or backdrop filters.
class AppSurface extends StatelessWidget {
  const AppSurface({
    super.key,
    required this.child,
    this.panel = false,
    this.dark,
    this.finish,
  });
  final Widget child;
  final bool panel;
  final bool? dark;
  final List<Color>? finish;
  @override
  Widget build(BuildContext context) {
    final isDark = dark ?? Theme.of(context).brightness == Brightness.dark;
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors:
              finish ??
              (isDark
                  ? [const Color(0xff252c36), const Color(0xff171d26)]
                  : panel
                  ? [const Color(0xfffefefe), const Color(0xfff6f7fa)]
                  : [
                      const Color(0xffeee8e0),
                      const Color(0xfff4f5f8),
                      const Color(0xffe7eef3),
                      const Color(0xfff7ede2),
                    ]),
        ),
      ),
      child: child,
    );
  }
}

class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.vintage = false,
    this.finish,
  });
  final Widget child;
  final bool vintage;
  final List<Color>? finish;
  @override
  Widget build(BuildContext context) => RepaintBoundary(
    child: Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Theme.of(context).brightness == Brightness.light
              ? Colors.white
              : const Color(0xff3b4554),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xff253047).withValues(alpha: .08),
            blurRadius: 18,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(19),
        child: AppSurface(panel: true, finish: finish, child: child),
      ),
    ),
  );
}

class AppFrame extends StatelessWidget {
  const AppFrame({super.key, required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.all(MediaQuery.sizeOf(context).width >= 900 ? 18 : 0),
    child: ClipRRect(
      borderRadius: BorderRadius.circular(
        MediaQuery.sizeOf(context).width >= 900 ? 24 : 0,
      ),
      child: child,
    ),
  );
}
