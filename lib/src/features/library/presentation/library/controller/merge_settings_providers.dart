// Copyright (c) 2026 Contributors to the Suwayomi project
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../../constants/db_keys.dart';
import '../../../../../utils/mixin/shared_preferences_client_mixin.dart';

/// Display-only grouping of library entries that share a normalized title.
class MergeByTitle extends Notifier<bool?>
    with SharedPreferenceClientMixin<bool> {
  @override
  bool? build() => initialize(DBKeys.mergeByTitle);
}

final mergeByTitleProvider = NotifierProvider<MergeByTitle, bool?>(
  MergeByTitle.new,
);

/// Entries with more chapters than this are never merged (0 = no limit).
class MergeMaxChapters extends Notifier<int?>
    with SharedPreferenceClientMixin<int> {
  @override
  int? build() => initialize(DBKeys.mergeMaxChapters);
}

final mergeMaxChaptersProvider = NotifierProvider<MergeMaxChapters, int?>(
  MergeMaxChapters.new,
);
