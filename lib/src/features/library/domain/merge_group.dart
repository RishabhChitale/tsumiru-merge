// Copyright (c) 2026 Contributors to the Suwayomi project
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import 'merge_key.dart';

/// Library entries shown as one poster. Display only: nothing is merged on the
/// server.
class MergeGroup<T> {
  const MergeGroup({
    required this.key,
    required this.representative,
    required this.members,
  });

  final String key;

  /// The newest member; its poster stands for the group.
  final T representative;

  /// Every member, in the order the library listed them.
  final List<T> members;

  bool get isMerged => members.length > 1;
}

/// Groups [items] by [normalizeMergeKey] of their title.
///
/// The group sits where its first member was listed, so the library's own sort
/// and filter order survive. Entries with more than [maxChapters] chapters
/// (when above 0) stay on their own, as do entries whose key is empty.
/// [recency] picks the newest member; larger is newer.
List<MergeGroup<T>> groupByMergeKey<T>(
  List<T> items, {
  required String Function(T item) title,
  required int Function(T item) chapterCount,
  required int Function(T item) recency,
  int maxChapters = 5,
}) {
  final order = <Object>[];
  final byKey = <String, List<T>>{};
  final singles = <Object, T>{};
  for (final item in items) {
    final key = normalizeMergeKey(title(item));
    final eligible =
        key.isNotEmpty && (maxChapters <= 0 || chapterCount(item) <= maxChapters);
    if (!eligible) {
      final token = Object();
      singles[token] = item;
      order.add(token);
      continue;
    }
    final bucket = byKey[key];
    if (bucket == null) {
      byKey[key] = [item];
      order.add(key);
    } else {
      bucket.add(item);
    }
  }
  return [
    for (final slot in order)
      if (slot is String)
        _group(slot, byKey[slot]!, recency)
      else
        MergeGroup<T>(
          key: '',
          representative: singles[slot] as T,
          members: [singles[slot] as T],
        ),
  ];
}

MergeGroup<T> _group<T>(String key, List<T> members, int Function(T) recency) {
  var newest = members.first;
  for (final m in members) {
    if (recency(m) > recency(newest)) newest = m;
  }
  return MergeGroup<T>(key: key, representative: newest, members: members);
}
