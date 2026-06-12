import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/models/user_profile.dart';
import '../core/constants.dart';

final userProfileProvider =
    StateNotifierProvider<UserProfileNotifier, UserProfile>((ref) {
  return UserProfileNotifier();
});

class UserProfileNotifier extends StateNotifier<UserProfile> {
  UserProfileNotifier() : super(const UserProfile()) {
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(AppConstants.prefUserProfile);
    if (jsonStr != null) {
      state = UserProfile.fromJsonString(jsonStr);
    }
  }

  Future<void> updateProfile(UserProfile profile) async {
    state = profile;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.prefUserProfile, profile.toJsonString());
  }

  Future<void> updatePhotoPath(String? photoPath) async {
    await updateProfile(state.copyWith(photoPath: photoPath));
  }
}
