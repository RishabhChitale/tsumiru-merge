// Copyright (c) 2026 Contributors to the Suwayomi project
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import 'package:flutter_test/flutter_test.dart';
import 'package:tsumiru/src/features/library/domain/merge_key.dart';

void main() {
  group('normalizeMergeKey', () {
    test('strips number and author suffix', () {
      expect(normalizeMergeKey('Cool Story 3 - Some Author'), 'cool story');
    });
    test('strips chapter keyword and author suffix', () {
      expect(
        normalizeMergeKey('Cool Story Chapter 4 - Another Name'),
        'cool story',
      );
    });
    test('same title by different authors merges', () {
      expect(
        normalizeMergeKey('Cool Story 3 - Alice'),
        normalizeMergeKey('Cool Story 9 – Bob'),
      );
    });
    test('bare trailing number without suffix is kept', () {
      expect(normalizeMergeKey('Cool Story 2'), 'cool story 2');
      expect(normalizeMergeKey('Mob Psycho 100'), 'mob psycho 100');
    });
    test('dash not after a chapter marker is kept', () {
      expect(
        normalizeMergeKey('Re:Zero - Starting Life'),
        're zero starting life',
      );
    });
    test('chapter keywords and decimals', () {
      expect(normalizeMergeKey('Cool Story ch. 12.5'), 'cool story');
      expect(normalizeMergeKey('Cool Story Ep 3a'), 'cool story');
      expect(normalizeMergeKey('Cool Story #7'), 'cool story');
      expect(normalizeMergeKey('Cool Story Vol 2'), 'cool story');
      expect(normalizeMergeKey('Cool Story c12'), 'cool story');
    });
    test('tags, diacritics, case and spacing', () {
      expect(normalizeMergeKey('[Eng] Café   Story (Digital) 3'), 'cafe story 3');
      expect(normalizeMergeKey('CAFÉ Story Chapter 3 | Me'), 'cafe story');
    });
    test('removes only one chapter marker', () {
      expect(normalizeMergeKey('Cool Story 3 Chapter 4'), 'cool story 3');
    });
    test('empty and number-only titles do not crash', () {
      expect(normalizeMergeKey(''), '');
      expect(normalizeMergeKey('12'), '12');
    });
  });
}
