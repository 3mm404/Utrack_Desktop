import 'package:flutter/material.dart';
import '../design/ui_palette.dart';
import 'cover_image_stub.dart' if (dart.library.io) 'cover_image_io.dart';

class CoverArtwork extends StatelessWidget {
  const CoverArtwork({
    super.key,
    this.path,
    required this.label,
    this.size = 64,
  });

  final String? path;
  final String label;
  final double size;

  @override
  Widget build(BuildContext context) {
    final palette = UiPalette.of(context);
    final fallback = ColoredBox(
      color: palette.input,
      child: Center(
        child: Icon(
          Icons.album_outlined,
          color: palette.muted,
          size: size * .45,
        ),
      ),
    );
    final image = path == null || path!.isEmpty ? null : localCoverImage(path!);
    return Semantics(
      image: true,
      label: image == null ? 'Sin portada: $label' : 'Portada de $label',
      child: SizedBox.square(
        dimension: size,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(size > 64 ? 16 : 10),
          child: image == null
              ? fallback
              : Image(
                  image: ResizeImage.resizeIfNeeded(
                    (size * MediaQuery.devicePixelRatioOf(context)).round(),
                    null,
                    image,
                  ),
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => fallback,
                ),
        ),
      ),
    );
  }
}
