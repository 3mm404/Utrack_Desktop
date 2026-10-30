import 'package:flutter/material.dart';
import '../design/ui_palette.dart';
import 'cover_image_stub.dart' if (dart.library.io) 'cover_image_io.dart';

/// Zone decoration is independent of the currently playing song artwork.
class ZoneArtwork extends StatelessWidget {
  const ZoneArtwork({
    super.key,
    this.path,
    required this.width,
    required this.height,
    required this.label,
  });
  final String? path;
  final double width, height;
  final String label;
  @override
  Widget build(BuildContext context) {
    final palette = UiPalette.of(context);
    final fallback = DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            palette.accent.withValues(alpha: .20),
            palette.input,
            palette.elevated,
          ],
        ),
      ),
      child: Center(
        child: Icon(
          Icons.speaker_group_outlined,
          size: 48,
          color: palette.muted,
        ),
      ),
    );
    final provider = path == null || path!.isEmpty
        ? null
        : localCoverImage(path!);
    return Semantics(
      container: true,
      excludeSemantics: true,
      image: true,
      label: 'Fondo de $label',
      child: SizedBox(
        width: width,
        height: height,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: provider == null
              ? fallback
              : Image(
                  image: ResizeImage.resizeIfNeeded(
                    (width * MediaQuery.devicePixelRatioOf(context)).round(),
                    null,
                    provider,
                  ),
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => fallback,
                ),
        ),
      ),
    );
  }
}
