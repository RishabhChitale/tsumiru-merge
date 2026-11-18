// Copyright (c) 2026 Contributors to the Suwayomi project
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

/// One chapter of a merged series, tagged with the entry it came from.
class MergedChapter<C, M> {
  const MergedChapter(this.chapter, this.entry);
  final C chapter;
  final M entry;
}

/// Orders chapters by chapter number, ties by upload date (older first).
/// Chapters without a number (<= 0 or null) sort last, in upload order.
List<MergedChapter<C, M>> sortMergedChapters<C, M>(
  List<MergedChapter<C, M>> chapters, {
  required double? Function(C chapter) number,
  required int Function(C chapter) uploadDate,
}) {
  int cmp(MergedChapter<C, M> a, MergedChapter<C, M> b) {
    final na = number(a.chapter);
    final nb = number(b.chapter);
    final ha = na != null && na > 0;
    final hb = nb != null && nb > 0;
    if (ha != hb) return ha ? -1 : 1;
    if (ha && hb) {
      final c = na.compareTo(nb);
      if (c != 0) return c;
    }
    return uploadDate(a.chapter).compareTo(uploadDate(b.chapter));
  }

  return [...chapters]..sort(cmp);
}
