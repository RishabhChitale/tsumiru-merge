// Copyright (c) 2026 Contributors to the Suwayomi project
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import 'package:flutter_test/flutter_test.dart';
import 'package:tsumiru/src/features/library/domain/merged_chapters.dart';

void main() {
  test('sorts by number, ties by upload date, unnumbered last', () {
    final input = [
      const MergedChapter<(double?, int), String>((2, 5), 'b'),
      const MergedChapter<(double?, int), String>((1, 9), 'a'),
      const MergedChapter<(double?, int), String>((-1, 1), 'c'),
      const MergedChapter<(double?, int), String>((2, 3), 'a'),
    ];
    final out = sortMergedChapters<(double?, int), String>(
      input,
      number: (c) => c.$1,
      uploadDate: (c) => c.$2,
    );
    expect(out.map((e) => e.chapter), [(1, 9), (2, 3), (2, 5), (-1, 1)]);
  });
}
