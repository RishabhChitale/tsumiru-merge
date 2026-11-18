// Copyright (c) 2026 Contributors to the Suwayomi project
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import 'package:flutter_test/flutter_test.dart';
import 'package:tsumiru/src/features/library/domain/merge_group.dart';

typedef _E = ({int id, String title, int chapters});

List<MergeGroup<_E>> _group(List<_E> items, {int max = 5}) => groupByMergeKey(
  items,
  title: (e) => e.title,
  chapterCount: (e) => e.chapters,
  recency: (e) => e.id,
  maxChapters: max,
);

void main() {
  const a1 = (id: 1, title: 'Cool Story 1 - Ann', chapters: 1);
  const b = (id: 2, title: 'Other Tale 7 - Bo', chapters: 1);
  const a2 = (id: 3, title: 'Cool Story Chapter 2 - Cy', chapters: 1);

  test('groups by title at first member position, newest is representative', () {
    final g = _group([a1, b, a2]);
    expect(g.length, 2);
    expect(g[0].members, [a1, a2]);
    expect(g[0].representative, a2);
    expect(g[0].isMerged, isTrue);
    expect(g[1].members, [b]);
    expect(g[1].isMerged, isFalse);
  });

  test('entries above the chapter limit stay single', () {
    const big = (id: 4, title: 'Cool Story 9 - Dee', chapters: 40);
    final g = _group([a1, big, a2]);
    expect(g.length, 2);
    expect(g.any((x) => x.members.contains(big) && x.members.length == 1), isTrue);
  });

  test('limit 0 means no limit', () {
    const big = (id: 4, title: 'Cool Story 9 - Dee', chapters: 40);
    expect(_group([a1, big], max: 0).single.members.length, 2);
  });

  test('empty list and empty key are safe', () {
    expect(_group([]), isEmpty);
    const blank = (id: 5, title: '', chapters: 1);
    expect(_group([blank, blank]).length, 2);
  });
}
