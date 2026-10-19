import 'package:flutter/material.dart';
import '../state/audio_view_state.dart';
import 'section_card.dart';

/// Only the playlist already assigned to each zone, never a fabricated catalog.
class AssignedPlaylistPanel extends StatelessWidget {
  const AssignedPlaylistPanel({super.key, required this.state});
  final AudioViewState state;
  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: state,
    builder: (context, _) => SectionCard(
      title: 'Playlist asignada',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (state.hasSelection) ...[
            DropdownButtonFormField<int>(
              key: ValueKey(
                '${state.selected.id}-${state.zones.map((z) => z.id).join(',')}',
              ),
              initialValue: state.selectedIndex,
              decoration: const InputDecoration(labelText: 'Zona'),
              items: [
                for (var i = 0; i < state.zones.length; i++)
                  DropdownMenuItem(value: i, child: Text(state.zones[i].name)),
              ],
              onChanged: (index) {
                if (index != null) state.select(index);
              },
            ),
            const SizedBox(height: 16),
            Text(state.selected.source),
            if (!state.fresh)
              const Text('Último estado recibido · sin actualización'),
            if (state.selected.songs.isEmpty)
              const Text('Sin canciones reportadas en la playlist asignada.'),
            for (final songId in state.selected.songs)
              ListTile(
                title: Text('Canción $songId'),
                subtitle: const Text('Título y artista no reportados'),
                trailing: IconButton(
                  tooltip: 'Reproducir canción $songId',
                  icon: const Icon(Icons.play_arrow),
                  onPressed: state.canPlayback('play')
                      ? () => state.playSong(songId)
                      : null,
                ),
              ),
          ] else
            const Text('Sin zonas recibidas del motor.'),
          const SizedBox(height: 12),
          const Text(
            'Se muestran las canciones asignadas por el servidor. El catálogo y las asignaciones se administran allí.',
          ),
        ],
      ),
    ),
  );
}
