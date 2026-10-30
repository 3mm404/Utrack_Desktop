import 'package:flutter/material.dart';
import '../../models/engine_status.dart';
import '../design/ui_palette.dart';
import 'cover_artwork.dart';
import 'app_surface.dart';
import 'playlist_download_control.dart';

/// A browsable album grid. Opening a playlist never changes playback.
class PlaylistCatalog extends StatelessWidget {
  const PlaylistCatalog({
    super.key,
    required this.playlists,
    required this.onOpen,
    this.assignedId,
    this.canDownload = false,
    this.downloadPending,
    this.onDownload,
  });
  final List<PlaylistInfo> playlists;
  final ValueChanged<PlaylistInfo> onOpen;
  final String? assignedId;
  final bool canDownload;
  final bool Function(String id)? downloadPending;
  final ValueChanged<PlaylistInfo>? onDownload;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final columns = (constraints.maxWidth / 190).floor().clamp(2, 6);
      final width = (constraints.maxWidth - (columns - 1) * 16) / columns;
      final palette = UiPalette.of(context);
      return Wrap(
        spacing: 16,
        runSpacing: 20,
        children: [
          for (final playlist in playlists)
            SizedBox(
              width: width,
              child: AppCard(
                child: Material(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(16),
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: () => onOpen(playlist),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CoverArtwork(
                            path: playlist.coverPath,
                            label: playlist.name,
                            size: width - 24,
                          ),
                          const SizedBox(height: 14),
                          Text(
                            playlist.name,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: UiText.of(context).label,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '${playlist.songs.length} ${playlist.songs.length == 1 ? 'canción' : 'canciones'}',
                            style: UiText.of(context).caption,
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(
                                assignedId == playlist.id
                                    ? Icons.speaker_rounded
                                    : Icons.queue_music_rounded,
                                size: 14,
                                color: assignedId == playlist.id
                                    ? palette.accent
                                    : palette.muted,
                              ),
                              const SizedBox(width: 5),
                              Expanded(
                                child: Text(
                                  assignedId == playlist.id
                                      ? 'En esta zona'
                                      : 'Ver playlist',
                                  style: UiText.of(context).caption.copyWith(
                                    color: assignedId == playlist.id
                                        ? palette.accent
                                        : palette.muted,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          PlaylistDownloadControl(
                            playlist: playlist,
                            enabled: canDownload,
                            pending:
                                downloadPending?.call(playlist.id) ?? false,
                            onAction: () => onDownload?.call(playlist),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      );
    },
  );
}
