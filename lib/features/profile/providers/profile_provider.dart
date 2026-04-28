import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:assetflow_mobile/data/models/profile_models.dart';
import 'package:assetflow_mobile/data/services/profile_service.dart';

class ProfileState {
  final ProfileDto? profile;
  final bool isLoading;
  final bool isSaving;
  final String? error;
  final String? successMessage;

  const ProfileState({
    this.profile,
    this.isLoading = false,
    this.isSaving = false,
    this.error,
    this.successMessage,
  });

  ProfileState copyWith({
    ProfileDto? profile,
    bool? isLoading,
    bool? isSaving,
    String? error,
    String? successMessage,
    bool clearError = false,
    bool clearSuccess = false,
  }) => ProfileState(
    profile: profile ?? this.profile,
    isLoading: isLoading ?? this.isLoading,
    isSaving: isSaving ?? this.isSaving,
    error: clearError ? null : (error ?? this.error),
    successMessage: clearSuccess
        ? null
        : (successMessage ?? this.successMessage),
  );
}

class ProfileNotifier extends StateNotifier<ProfileState> {
  final ProfileService _service;

  ProfileNotifier(this._service) : super(const ProfileState());

  Future<void> load() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final profile = await _service.getMe();
      state = state.copyWith(isLoading: false, profile: profile);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<bool> updateProfile(UpdateProfileRequest request) async {
    state = state.copyWith(
      isSaving: true,
      clearError: true,
      clearSuccess: true,
    );
    try {
      final updated = await _service.updateMe(request);
      state = state.copyWith(
        isSaving: false,
        profile: updated,
        successMessage: 'Profil güncellendi.',
      );
      return true;
    } catch (e) {
      state = state.copyWith(isSaving: false, error: 'Profil güncellenemedi.');
      return false;
    }
  }

  Future<bool> changePassword(String current, String newPass) async {
    state = state.copyWith(
      isSaving: true,
      clearError: true,
      clearSuccess: true,
    );
    try {
      await _service.changePassword(current, newPass);
      state = state.copyWith(
        isSaving: false,
        successMessage: 'Şifre değiştirildi.',
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isSaving: false,
        error: 'Şifre değiştirilemedi. Mevcut şifrenizi kontrol edin.',
      );
      return false;
    }
  }

  Future<bool> uploadAvatar(File file) async {
    state = state.copyWith(isSaving: true, clearError: true);
    try {
      final url = await _service.uploadAvatar(file);
      if (state.profile != null) {
        state = state.copyWith(
          isSaving: false,
          profile: state.profile!.copyWith(avatarUrl: url),
          successMessage: 'Avatar güncellendi.',
        );
      }
      return true;
    } catch (e) {
      state = state.copyWith(isSaving: false, error: 'Avatar yüklenemedi.');
      return false;
    }
  }

  Future<void> deleteAccount() async {
    await _service.deleteAccount();
  }

  void clearMessages() {
    state = state.copyWith(clearError: true, clearSuccess: true);
  }
}

final profileServiceProvider = Provider<ProfileService>(
  (_) => ProfileService(),
);

final profileProvider = StateNotifierProvider<ProfileNotifier, ProfileState>((
  ref,
) {
  return ProfileNotifier(ref.read(profileServiceProvider));
});
