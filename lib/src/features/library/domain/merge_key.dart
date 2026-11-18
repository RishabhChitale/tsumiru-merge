// Copyright (c) 2026 Contributors to the Suwayomi project
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import 'package:diacritic/diacritic.dart';

import 'title_fold.dart';

// [tags] and (tags) such as [Eng] or (Digital).
final _bracketTags = RegExp(r'\[[^\]]*\]|\([^)]*\)|【[^】]*】');

// Cut points between a series name and the author, only a spaced dash or bar.
final _authorSeparator = RegExp(r' [-–—|] ');

// A trailing chapter marker with an explicit keyword: "ch 3", "chapter 4.5",
// "ep. 12", "episode 2", "#7", "c12", "vol 2", "v3b".
final _keywordMarker = RegExp(
  r'(?:^|\s)(?:chapter|ch|episode|ep|vol|v|c)\.?\s*\d+(?:\.\d+)?[a-z]?$'
  r'|(?:^|\s)#\s*\d+(?:\.\d+)?[a-z]?$',
);

// A bare trailing number such as "3", "12.5" or "3a".
final _bareNumber = RegExp(r'(?:^|\s)\d+(?:\.\d+)?[a-z]?$');

// A keyword with no number after it never counts as a marker on its own.
final _punctuation = RegExp(r'[^\p{L}\p{N}\s]', unicode: true);
final _whitespace = RegExp(r'\s+');

String _clean(String s) =>
    s.replaceAll(_punctuation, ' ').replaceAll(_whitespace, ' ').trim();

/// Key that groups library entries of one series published a chapter at a
/// time, such as `Cool Story 3 - Some Author` and `Cool Story Chapter 4`.
///
/// Matches by title only, never by author. A bare trailing number is kept
/// unless an author suffix or a chapter keyword shows it is a chapter number,
/// so `Mob Psycho 100` and `Re:Zero - Starting Life` stay as they are.
String normalizeMergeKey(String title) {
  var s = removeDiacritics(foldTitleCompat(title)).toLowerCase();
  s = s.replaceAll(_bracketTags, ' ');
  s = s.replaceAll(_whitespace, ' ').trim();

  // Drop an author suffix only when what precedes it ends in a chapter number
  // or a chapter keyword; the separator sits after the first such match.
  var hadAuthorSuffix = false;
  for (final m in _authorSeparator.allMatches(s)) {
    final before = s.substring(0, m.start).trim();
    if (_keywordMarker.hasMatch(before) || _bareNumber.hasMatch(before)) {
      s = before;
      hadAuthorSuffix = true;
      break;
    }
  }

  final keyword = _keywordMarker.firstMatch(s);
  if (keyword != null) {
    s = s.substring(0, keyword.start);
  } else if (hadAuthorSuffix) {
    final bare = _bareNumber.firstMatch(s);
    if (bare != null) s = s.substring(0, bare.start);
  }
  return _clean(s);
}
