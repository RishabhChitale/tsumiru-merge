// Copyright (c) 2026 Contributors to the Suwayomi project
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../routes/router_config.dart';
import '../../../../utils/extensions/custom_extensions.dart';
import '../../../manga_book/domain/chapter/chapter_model.dart';
import '../../../manga_book/domain/manga/manga_model.dart';
import '../../../manga_book/presentation/manga_details/controller/manga_details_controller.dart';
import '../../domain/merged_chapters.dart';

/// Read-only view of several library entries that share a title, with all of
/// their chapters in one list. Display grouping only; nothing changes on the
/// server.
class MergedSeriesScreen extends ConsumerWidget {
  const MergedSeriesScreen({super.key, required this.members});

  final List<MangaDto> members;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chapters = <MergedChapter<ChapterDto, MangaDto>>[];
    var loading = false;
    Object? error;
    for (final manga in members) {
      final async = ref.watch(mangaChapterListProvider(mangaId: manga.id));
      async.when(
        data: (list) {
          for (final c in list ?? const <ChapterDto>[]) {
            chapters.add(MergedChapter(c, manga));
          }
        },
        loading: () => loading = true,
        error: (e, _) => error = e,
      );
    }
    final sorted = sortMergedChapters<ChapterDto, MangaDto>(
      chapters,
      number: (c) => c.chapterNumber,
      uploadDate: (c) => int.tryParse('${c.uploadDate}') ?? 0,
    );
    final title = members.first.title;
    return Scaffold(
      appBar: AppBar(
        title: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis),
      ),
      body: sorted.isEmpty
          ? Center(
              child: loading
                  ? const CircularProgressIndicator()
                  : Text(error == null ? '—' : '$error'),
            )
          : ListView.builder(
              itemCount: sorted.length + 1,
              itemBuilder: (context, i) {
                if (i == 0) {
                  return ListTile(
                    dense: true,
                    title: Text(
                      '${context.l10n.mergedSeries} · '
                      '${context.l10n.mergedEntries(members.length)}',
                    ),
                  );
                }
                final item = sorted[i - 1];
                final c = item.chapter;
                final read = c.user.isRead;
                return ListTile(
                  title: Text(
                    c.name,
                    style: read
                        ? TextStyle(color: Theme.of(context).disabledColor)
                        : null,
                  ),
                  subtitle: Text(
                    item.entry.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  trailing: c.user.isBookmarked
                      ? const Icon(Icons.bookmark, size: 18)
                      : null,
                  onTap: () => ReaderRoute(
                    mangaId: item.entry.id,
                    chapterId: c.id,
                  ).push(context),
                );
              },
            ),
    );
  }
}
