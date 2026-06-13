import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/organiser_model.dart';
import '../core/services/firebase_service.dart';
import '../core/services/storage_service.dart';

class OrganiserState {
  final bool isLoading;
  final OrganiserModel? organiser;
  final String? error;

  OrganiserState({
    this.isLoading = false,
    this.organiser,
    this.error,
  });

  OrganiserState copyWith({
    bool? isLoading,
    OrganiserModel? organiser,
    String? error,
  }) {
    return OrganiserState(
      isLoading: isLoading ?? this.isLoading,
      organiser: organiser ?? this.organiser,
      error: error ?? this.error,
    );
  }
}

class OrganiserNotifier extends StateNotifier<OrganiserState> {
  final FirebaseService _firebaseService;
  final StorageService _storageService;

  OrganiserNotifier(this._firebaseService, this._storageService) : super(OrganiserState());

  Future<void> loadOrganiser(String uid) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final org = await _firebaseService.getOrganiser(uid);
      state = state.copyWith(isLoading: false, organiser: org);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> updateProfile(String uid, Map<String, dynamic> data) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _firebaseService.updateOrganiserProfile(uid, data);
      final org = await _firebaseService.getOrganiser(uid);
      state = state.copyWith(isLoading: false, organiser: org);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> completeOnboarding(String uid, {
    required String contactName,
    required String companyName,
    required String city,
    String? logoUrl,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _firebaseService.completeOnboarding(
        uid,
        contactName: contactName,
        companyName: companyName,
        city: city,
        logoUrl: logoUrl,
      );
      final org = await _firebaseService.getOrganiser(uid);
      state = state.copyWith(isLoading: false, organiser: org);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<String?> uploadLogo(String uid, File file) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final url = await _storageService.uploadOrgLogo(uid, file);
      state = state.copyWith(isLoading: false);
      return url;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return null;
    }
  }
}

final firebaseServiceProvider = Provider((ref) => FirebaseService());
final storageServiceProvider = Provider((ref) => StorageService());

final organiserProvider = StateNotifierProvider<OrganiserNotifier, OrganiserState>((ref) {
  return OrganiserNotifier(
    ref.watch(firebaseServiceProvider),
    ref.watch(storageServiceProvider),
  );
});

final organiserStreamProvider = StreamProvider.family<OrganiserModel?, String>((ref, uid) {
  return ref.watch(firebaseServiceProvider).organiserStream(uid);
});
