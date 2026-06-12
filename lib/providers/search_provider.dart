import 'package:flutter_riverpod/flutter_riverpod.dart';

final searchQueryProvider = StateProvider<String>((ref) => '');

final selectedCategoryFilterProvider = StateProvider<String?>((ref) => null);

final hasPhotoFilterProvider = StateProvider<bool>((ref) => false);

final hasGpsFilterProvider = StateProvider<bool>((ref) => false);

final hasReminderFilterProvider = StateProvider<bool>((ref) => false);

final sortByProvider = StateProvider<String>((ref) => 'newest');
