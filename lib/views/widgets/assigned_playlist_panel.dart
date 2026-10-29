import 'package:flutter/material.dart';
import '../../models/engine_status.dart';
import '../state/audio_view_state.dart';
import '../design/ui_palette.dart';
import 'cover_artwork.dart';
import 'playlist_catalog.dart';
import 'song_preference_controls.dart';

/// Browse independently of the selected zone's observed playback.
class AssignedPlaylistPanel extends StatefulWidget {
  const AssignedPlaylistPanel({super.key, required this.state});
  final AudioViewState state;
  @override
  State<AssignedPlaylistPanel> createState() => _AssignedPlaylistPanelState();
}

class _AssignedPlaylistPanelState extends State<AssignedPlaylistPanel> {
  final _search = TextEditingController();
  String? _openedId;
  bool _onlyAssigned = false;
  AudioViewState get state => widget.state;

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  PlaylistInfo get _assigned => PlaylistInfo(
    id: state.selected.playlistId ?? '__assigned__',
    name: state.selected.source,
    coverPath: state.selected.coverPath,
    songs: {
      for (final id in state.selected.songs)
        id: SongMetadata(
          title: state.selected.songMetadata[id]?.title ?? 'Canción $id',
          artist: state.selected.songMetadata[id]?.artist,
          coverPath:
              state.selected.songMetadata[id]?.coverPath ??
              state.selected.coverPath,
        ),
    },
  );

  void _open(PlaylistInfo playlist) => setState(() {
    _openedId = playlist.id;
    _search.clear();
  });

  Widget _zonePicker() => SizedBox(
    width: 260,
    child: DropdownButtonFormField<int>(
      key: ValueKey(
        '${state.selected.id}-${state.zones.map((zone) => zone.id).join(',')}',
      ),
      initialValue: state.hasSelection ? state.selectedIndex : null,
      isExpanded: true,
      decoration: const InputDecoration(
        labelText: 'Reproducir en',
        prefixIcon: Icon(Icons.speaker_group_outlined),
      ),
      items: [
        for (var i = 0; i < state.zones.length; i++)
          DropdownMenuItem(
            value: i,
            child: Text(state.zones[i].name, overflow: TextOverflow.ellipsis),
          ),
      ],
      onChanged: (index) {
        if (index == null) return;
        setState(() {
          _openedId = null;
          _search.clear();
        });
        state.select(index);
      },
    ),
  );

  Widget _empty(IconData icon, String title, String message) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 16),
    child: Center(
      child: Column(
        children: [
          Icon(icon, size: 44, color: UiPalette.of(context).muted),
          const SizedBox(height: 16),
          Text(
            title,
            style: UiText.of(context).title,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: UiText.of(context).caption,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    ),
  );

  Widget _searchField(bool detail) => TextField(
    controller: _search,
    onChanged: (_) => setState(() {}),
    decoration: InputDecoration(
      hintText: detail
          ? 'Buscar en esta playlist'
          : 'Buscar playlists, canciones o artistas',
      prefixIcon: const Icon(Icons.search_rounded),
      suffixIcon: _search.text.isEmpty
          ? null
          : IconButton(
              tooltip: 'Limpiar búsqueda',
              onPressed: () => setState(_search.clear),
              icon: const Icon(Icons.close),
            ),
    ),
  );

  Widget _browse() {
    final query = _search.text.trim().toLowerCase();
    final playlists = state.playlists.where((playlist) {
      if (_onlyAssigned && playlist.id != state.selected.playlistId) {
        return false;
      }
      return playlist.name.toLowerCase().contains(query) ||
          playlist.songs.values.any(
            (song) => '${song.title} ${song.artist ?? ''}'
                .toLowerCase()
                .contains(query),
          );
    }).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _searchField(false),
        const SizedBox(height: 20),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ChoiceChip(
              label: const Text(
                'Todas las playlists',
                style: TextStyle(fontFamily: 'Roboto'),
              ),
              selected: !_onlyAssigned,
              onSelected: (_) => setState(() => _onlyAssigned = false),
            ),
            ChoiceChip(
              label: Text('En ${state.selected.name}'),
              selected: _onlyAssigned,
              onSelected: (_) => setState(() => _onlyAssigned = true),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              child: Text('Tus playlists', style: UiText.of(context).title),
            ),
            Text(
              '${playlists.length} ${playlists.length == 1 ? 'playlist' : 'playlists'}',
              style: UiText.of(context).caption,
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (playlists.isEmpty)
          _empty(
            Icons.search_off_rounded,
            'No encontramos playlists',
            'Prueba otra búsqueda o muestra todas las playlists.',
          )
        else
          PlaylistCatalog(
            playlists: playlists,
            assignedId: state.selected.playlistId,
            onOpen: _open,
          ),
      ],
    );
  }

  Widget _detail(PlaylistInfo playlist, bool canGoBack) {
    final assigned = playlist.id == _assigned.id;
    final query = _search.text.trim().toLowerCase();
    final songs = playlist.songs.entries
        .where(
          (entry) => '${entry.value.title} ${entry.value.artist ?? ''}'
              .toLowerCase()
              .contains(query),
        )
        .toList();
    final positions = {
      for (final entry in playlist.songs.keys.indexed) entry.$2: entry.$1 + 1,
    };
    final palette = UiPalette.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (canGoBack)
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: () => setState(() {
                _openedId = null;
                _search.clear();
              }),
              icon: const Icon(Icons.arrow_back_rounded, size: 18),
              label: const Text(
                'Todas las playlists',
                style: TextStyle(fontFamily: 'Roboto'),
              ),
            ),
          ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [palette.accent.withValues(alpha: .18), palette.surface],
            ),
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final compact = constraints.maxWidth < 540;
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CoverArtwork(
                    path: playlist.coverPath,
                    label: playlist.name,
                    size: compact ? 88 : 160,
                  ),
                  SizedBox(width: compact ? 16 : 28),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          assigned ? 'Playlist asignada' : 'PLAYLIST',
                          style: UiText.of(context).caption,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          playlist.name,
                          style: UiText.of(
                            context,
                          ).heading.copyWith(fontSize: compact ? 22 : 34),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          '${playlist.songs.length} ${playlist.songs.length == 1 ? 'canción' : 'canciones'}',
                          style: UiText.of(context).caption,
                        ),
                        if (!compact) ...[
                          const SizedBox(height: 20),
                          _playButton(playlist, assigned),
                        ],
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
        LayoutBuilder(
          builder: (context, constraints) => constraints.maxWidth < 580
              ? Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: _playButton(playlist, assigned),
                  ),
                )
              : const SizedBox(),
        ),
        const SizedBox(height: 24),
        _searchField(true),
        const SizedBox(height: 10),
        Text(
          'Me gusta: +20 % en aleatorio continuo. No me gusta: excluida en esta zona.',
          style: UiText.of(context).caption,
        ),
        const SizedBox(height: 18),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: [
              SizedBox(
                width: 32,
                child: Text('#', style: UiText.of(context).caption),
              ),
              Expanded(
                child: Text(
                  'TÍTULO / ARTISTA',
                  style: UiText.of(context).caption,
                ),
              ),
              const SizedBox(width: 40),
            ],
          ),
        ),
        Divider(color: palette.border.withValues(alpha: .4), height: 1),
        if (songs.isEmpty)
          _empty(
            Icons.music_off_outlined,
            playlist.songs.isEmpty
                ? 'Esta playlist está vacía'
                : 'Sin resultados',
            playlist.songs.isEmpty
                ? 'Las canciones aparecerán aquí cuando se agreguen.'
                : 'Busca por título o artista.',
          ),
        for (final entry in songs)
          Material(
            color: assigned && state.selected.songId == entry.key
                ? palette.accent.withValues(alpha: .09)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            child: ListTile(
              selected: assigned && state.selected.songId == entry.key,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 4,
              ),
              leading: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 32,
                    child:
                        assigned &&
                            state.selected.songId == entry.key &&
                            state.selected.playing
                        ? Icon(
                            Icons.graphic_eq_rounded,
                            color: palette.accent,
                            size: 18,
                          )
                        : Text(
                            '${positions[entry.key]}',
                            style: UiText.of(context).caption,
                          ),
                  ),
                  CoverArtwork(
                    path: entry.value.coverPath ?? playlist.coverPath,
                    label: entry.value.title,
                    size: 40,
                  ),
                ],
              ),
              title: Text(
                entry.value.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: UiText.of(context).label.copyWith(
                  decoration:
                      state.selected.songPreferences[entry.key] == 'dislike'
                      ? TextDecoration.lineThrough
                      : null,
                  color: assigned && state.selected.songId == entry.key
                      ? palette.accent
                      : palette.text,
                ),
              ),
              subtitle: Text(
                entry.value.artist ?? 'Artista no reportado',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SongPreferenceControls(
                    compact: true,
                    state: state,
                    zoneId: state.selected.id,
                    songId: entry.key,
                  ),
                  IconButton(
                    tooltip: 'Reproducir ${entry.value.title}',
                    icon: const Icon(Icons.play_arrow_rounded),
                    onPressed:
                        state.selected.songPreferences[entry.key] == 'dislike'
                        ? null
                        : assigned
                        ? (state.canPlayback('play')
                              ? () => state.playSong(entry.key)
                              : null)
                        : (state.canPlayPlaylist
                              ? () => state.playPlaylist(
                                  playlist.id,
                                  songId: entry.key,
                                )
                              : null),
                  ),
                ],
              ),
            ),
          ),
        if (!assigned && playlist.songs.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 16),
            child: Text(
              'Usa el botón de reproducción de cada canción para escucharla en ${state.selected.name}.',
              style: UiText.of(context).caption,
            ),
          ),
      ],
    );
  }

  Widget _playButton(PlaylistInfo playlist, bool assigned) => FilledButton.icon(
    style: FilledButton.styleFrom(elevation: 0, shape: const StadiumBorder()),
    onPressed: playlist.songs.isEmpty
        ? null
        : assigned
        ? (state.canPlayback('play') ? state.playAssignedPlaylist : null)
        : (state.canPlayPlaylist
              ? () => state.playPlaylist(playlist.id)
              : null),
    icon: const Icon(Icons.play_arrow_rounded),
    label: Text(
      'Reproducir en ${state.selected.name}',
      style: const TextStyle(fontFamily: 'Roboto'),
      overflow: TextOverflow.ellipsis,
    ),
  );

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: state,
    builder: (context, _) {
      final opened = state.playlists
          .where((playlist) => playlist.id == _openedId)
          .firstOrNull;
      final detail = state.playlists.isEmpty && state.hasSelection
          ? _assigned
          : opened;
      return Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            LayoutBuilder(
              builder: (context, constraints) {
                final heading = Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Biblioteca',
                      style: UiText.of(context).heading.copyWith(fontSize: 30),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Tu música, en cada espacio.',
                      style: UiText.of(context).caption,
                    ),
                  ],
                );
                return constraints.maxWidth < 620
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          heading,
                          const SizedBox(height: 20),
                          _zonePicker(),
                        ],
                      )
                    : Row(
                        children: [
                          Expanded(child: heading),
                          _zonePicker(),
                        ],
                      );
              },
            ),
            const SizedBox(height: 28),
            if (!state.fresh && state.hasSelection)
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Text(
                  'Sin conexión reciente · mostrando la última biblioteca recibida',
                  style: UiText.of(context).caption,
                ),
              ),
            if (state.playbackPending)
              const Padding(
                padding: EdgeInsets.only(bottom: 16),
                child: LinearProgressIndicator(),
              ),
            if (state.error.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Text(
                  state.error,
                  style: TextStyle(color: UiPalette.of(context).error),
                ),
              ),
            if (!state.hasSelection)
              _empty(
                Icons.speaker_group_outlined,
                'Tu biblioteca está por llegar',
                'Conecta el equipo para ver sus zonas y playlists.',
              )
            else if (detail != null)
              _detail(detail, state.playlists.isNotEmpty)
            else
              _browse(),
          ],
        ),
      );
    },
  );
}
