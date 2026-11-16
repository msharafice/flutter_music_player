import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../player/presentation/providers/player_provider.dart';
import '../../../player/presentation/widgets/mini_player.dart';
import '../../domain/entities/playlist.dart';
import '../../domain/entities/track.dart';
import '../providers/playlist_provider.dart';
import '../providers/track_provider.dart';

class PlaylistDetailPage extends ConsumerWidget {
  final String playlistId;

  const PlaylistDetailPage({super.key, required this.playlistId});

  Future<void> _addTracks(
    BuildContext context,
    WidgetRef ref,
    Playlist playlist,
    List<Track> allTracks,
  ) async {
    final availableTracks = allTracks
        .where((track) => !playlist.trackIds.contains(track.id))
        .toList();

    if (availableTracks.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No more songs available to add')),
      );
      return;
    }

    final selectedIds = <int>{};

    final result = await showDialog<List<int>>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: AppColors.darkSurface,
              title: const Text(
                'Add Songs',
                style: TextStyle(color: AppColors.darkTextPrimary),
              ),
              content: SizedBox(
                width: double.maxFinite,
                height: 350,
                child: ListView.builder(
                  itemCount: availableTracks.length,
                  itemBuilder: (context, index) {
                    final track = availableTracks[index];
                    final selected = selectedIds.contains(track.id);

                    return CheckboxListTile(
                      value: selected,
                      activeColor: AppColors.primary,
                      checkColor: Colors.white,
                      title: Text(
                        track.title.isEmpty ? 'Unknown track' : track.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.darkTextPrimary,
                        ),
                      ),
                      subtitle: Text(
                        track.artist.isEmpty ? 'Unknown artist' : track.artist,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.darkTextSecondary,
                        ),
                      ),
                      onChanged: (value) {
                        setDialogState(() {
                          if (value == true) {
                            selectedIds.add(track.id);
                          } else {
                            selectedIds.remove(track.id);
                          }
                        });
                      },
                    );
                  },
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(dialogContext, selectedIds.toList());
                  },
                  child: Text('Add (${selectedIds.length})'),
                ),
              ],
            );
          },
        );
      },
    );

    if (result == null || result.isEmpty || !context.mounted) return;

    try {
      await ref.read(playlistsProvider.notifier).addTracks(playlist.id, result);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Songs added to playlist')),
        );
      }
    } catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Could not add songs: $error')));
      }
    }
  }

  Future<void> _renamePlaylist(
    BuildContext context,
    WidgetRef ref,
    Playlist playlist,
  ) async {
    final controller = TextEditingController(text: playlist.name);

    final name = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: AppColors.darkSurface,
          title: const Text(
            'Rename Playlist',
            style: TextStyle(color: AppColors.darkTextPrimary),
          ),
          content: TextField(
            controller: controller,
            autofocus: true,
            style: const TextStyle(color: AppColors.darkTextPrimary),
            decoration: const InputDecoration(hintText: 'Playlist name'),
            onSubmitted: (value) {
              Navigator.pop(dialogContext, value);
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext, controller.text);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );

    controller.dispose();

    if (name == null || name.trim().isEmpty || !context.mounted) return;

    try {
      await ref
          .read(playlistsProvider.notifier)
          .renamePlaylist(playlist.id, name);
    } catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not rename playlist: $error')),
        );
      }
    }
  }

  Future<void> _deletePlaylist(
    BuildContext context,
    WidgetRef ref,
    Playlist playlist,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: AppColors.darkSurface,
          title: const Text(
            'Delete Playlist?',
            style: TextStyle(color: AppColors.darkTextPrimary),
          ),
          content: Text(
            'Are you sure you want to delete "${playlist.name}"?',
            style: const TextStyle(color: AppColors.darkTextSecondary),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text(
                'Delete',
                style: TextStyle(color: Colors.redAccent),
              ),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !context.mounted) return;

    try {
      await ref.read(playlistsProvider.notifier).deletePlaylist(playlist.id);

      if (context.mounted) {
        Navigator.pop(context);
      }
    } catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not delete playlist: $error')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playlistsAsync = ref.watch(playlistsProvider);
    final tracksAsync = ref.watch(tracksProvider);

    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: AppBar(
        backgroundColor: AppColors.darkBackground,
        foregroundColor: AppColors.darkTextPrimary,
        title: playlistsAsync.when(
          data: (playlists) {
            for (final playlist in playlists) {
              if (playlist.id == playlistId) {
                return Text(playlist.name);
              }
            }
            return const Text('Playlist');
          },
          loading: () => const Text('Playlist'),
          error: (_, _) => const Text('Playlist'),
        ),
        actions: [
          playlistsAsync.when(
            data: (playlists) {
              Playlist? playlist;

              for (final item in playlists) {
                if (item.id == playlistId) {
                  playlist = item;
                  break;
                }
              }

              if (playlist == null) return const SizedBox.shrink();

              return PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'rename') {
                    _renamePlaylist(context, ref, playlist!);
                  } else if (value == 'delete') {
                    _deletePlaylist(context, ref, playlist!);
                  }
                },
                itemBuilder: (context) => const [
                  PopupMenuItem(value: 'rename', child: Text('Rename')),
                  PopupMenuItem(value: 'delete', child: Text('Delete')),
                ],
              );
            },
            loading: () => const SizedBox.shrink(),
            error: (_, _) => const SizedBox.shrink(),
          ),
        ],
      ),
      body: playlistsAsync.when(
        data: (playlists) {
          Playlist? playlist;

          for (final item in playlists) {
            if (item.id == playlistId) {
              playlist = item;
              break;
            }
          }

          if (playlist == null) {
            return const Center(
              child: Text(
                'Playlist not found',
                style: TextStyle(color: AppColors.darkTextPrimary),
              ),
            );
          }

          return tracksAsync.when(
            data: (allTracks) {
              final tracksById = {
                for (final track in allTracks) track.id: track,
              };

              final playlistTracks = playlist!.trackIds
                  .map((id) => tracksById[id])
                  .whereType<Track>()
                  .toList();

              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            '${playlistTracks.length} songs',
                            style: AppTextStyles.subtitle,
                          ),
                        ),
                        OutlinedButton.icon(
                          onPressed: () {
                            _addTracks(context, ref, playlist!, allTracks);
                          },
                          icon: const Icon(Icons.add_rounded),
                          label: const Text('Add Songs'),
                        ),
                        const SizedBox(width: 8),
                        IconButton.filled(
                          onPressed: playlistTracks.isEmpty
                              ? null
                              : () {
                                  ref
                                      .read(playbackControllerProvider.notifier)
                                      .playTrack(
                                        playlistTracks.first,
                                        playlistTracks,
                                      );
                                },
                          icon: const Icon(Icons.play_arrow_rounded),
                          tooltip: 'Play all',
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: playlistTracks.isEmpty
                        ? Center(
                            child: Padding(
                              padding: const EdgeInsets.all(24),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.music_off_rounded,
                                    size: 64,
                                    color: AppColors.primaryLight,
                                  ),
                                  const SizedBox(height: 14),
                                  const Text(
                                    'This playlist is empty',
                                    style: AppTextStyles.sectionTitle,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Add songs from your music library.',
                                    style: AppTextStyles.subtitle,
                                  ),
                                ],
                              ),
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                            itemCount: playlistTracks.length,
                            itemBuilder: (context, index) {
                              final track = playlistTracks[index];

                              return Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: Material(
                                  color: AppColors.darkSurface,
                                  borderRadius: BorderRadius.circular(16),
                                  child: ListTile(
                                    onTap: () {
                                      ref
                                          .read(
                                            playbackControllerProvider.notifier,
                                          )
                                          .playTrack(track, playlistTracks);
                                    },
                                    leading: const CircleAvatar(
                                      backgroundColor: AppColors.primaryDark,
                                      child: Icon(
                                        Icons.music_note_rounded,
                                        color: Colors.white,
                                      ),
                                    ),
                                    title: Text(
                                      track.title.isEmpty
                                          ? 'Unknown track'
                                          : track.title,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        color: AppColors.darkTextPrimary,
                                      ),
                                    ),
                                    subtitle: Text(
                                      track.artist.isEmpty
                                          ? 'Unknown artist'
                                          : track.artist,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        color: AppColors.darkTextSecondary,
                                      ),
                                    ),
                                    trailing: IconButton(
                                      tooltip: 'Remove from playlist',
                                      onPressed: () async {
                                        try {
                                          await ref
                                              .read(playlistsProvider.notifier)
                                              .removeTrack(
                                                playlist!.id,
                                                track.id,
                                              );
                                        } catch (error) {
                                          if (context.mounted) {
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                  'Could not remove song: $error',
                                                ),
                                              ),
                                            );
                                          }
                                        }
                                      },
                                      icon: const Icon(
                                        Icons.remove_circle_outline_rounded,
                                        color: AppColors.darkTextSecondary,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              );
            },
            loading: () => const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
            error: (error, stackTrace) => Center(
              child: Text(
                'Unable to load songs: $error',
                style: const TextStyle(color: AppColors.darkTextPrimary),
              ),
            ),
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
        error: (error, stackTrace) => Center(
          child: Text(
            'Unable to load playlist: $error',
            style: const TextStyle(color: AppColors.darkTextPrimary),
          ),
        ),
      ),
      bottomNavigationBar: const MiniPlayer(),
    );
  }
}
