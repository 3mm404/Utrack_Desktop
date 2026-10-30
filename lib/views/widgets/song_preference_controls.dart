import 'accessible_controls.dart';

import 'package:flutter/material.dart';

import '../state/audio_view_state.dart';
import '../design/ui_palette.dart';

class SongPreferenceControls extends StatelessWidget {
  const SongPreferenceControls({
    super.key,
    required this.state,
    required this.zoneId,
    required this.songId,
    this.compact = false,
  });
  final AudioViewState state;
  final String zoneId, songId;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final zone = state.zones.where((zone) => zone.id == zoneId).firstOrNull;
    final current = zone?.songPreferences[songId];
    final palette = UiPalette.of(context);
    if (compact && MediaQuery.sizeOf(context).width < 600) {
      return AccessiblePopupMenuButton<String>(
        tooltip: 'Preferencias de esta canción',
        enabled: state.canSetSongPreference,
        icon: Icon(
          current == 'like'
              ? Icons.favorite_rounded
              : current == 'dislike'
              ? Icons.thumb_down_rounded
              : Icons.more_horiz,
          color: current == 'like'
              ? palette.accent
              : current == 'dislike'
              ? palette.error
              : palette.muted,
        ),
        onSelected: (value) => state.setSongPreference(zoneId, songId, value),
        itemBuilder: (_) => [
          PopupMenuItem(
            value: current == 'like' ? 'neutral' : 'like',
            child: Text(
              current == 'like'
                  ? 'Quitar Me gusta'
                  : 'Me gusta · +20 % en aleatorio continuo',
            ),
          ),
          PopupMenuItem(
            value: current == 'dislike' ? 'neutral' : 'dislike',
            child: Text(
              current == 'dislike'
                  ? 'Volver a permitir'
                  : 'No me gusta · excluir en esta zona',
            ),
          ),
        ],
      );
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        AccessibleIconButton(
          tooltip: current == 'like'
              ? 'Quitar Me gusta en esta zona'
              : 'Me gusta: +20 % en aleatorio continuo',
          icon: Icon(
            current == 'like'
                ? Icons.favorite_rounded
                : Icons.favorite_border_rounded,
            size: 20,
          ),
          style: IconButton.styleFrom(
            minimumSize: const Size(32, 36),
            padding: const EdgeInsets.all(6),
            foregroundColor: current == 'like' ? palette.accent : palette.muted,
          ),
          onPressed: state.canSetSongPreference
              ? () => state.setSongPreference(
                  zoneId,
                  songId,
                  current == 'like' ? 'neutral' : 'like',
                )
              : null,
        ),
        AccessibleIconButton(
          tooltip: current == 'dislike'
              ? 'Volver a permitir esta canción'
              : 'No me gusta: excluir en esta zona',
          icon: Icon(
            current == 'dislike'
                ? Icons.thumb_down_rounded
                : Icons.thumb_down_outlined,
            size: 19,
          ),
          style: IconButton.styleFrom(
            minimumSize: const Size(32, 36),
            padding: const EdgeInsets.all(6),
            foregroundColor: current == 'dislike'
                ? palette.error
                : palette.muted,
          ),
          onPressed: state.canSetSongPreference
              ? () => state.setSongPreference(
                  zoneId,
                  songId,
                  current == 'dislike' ? 'neutral' : 'dislike',
                )
              : null,
        ),
      ],
    );
  }
}
