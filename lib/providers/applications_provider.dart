import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/application_model.dart';
import '../core/services/firebase_service.dart';

class ApplicationsState {
  final bool isLoading;
  final List<ApplicationModel> applications;
  final String? error;

  ApplicationsState({
    this.isLoading = false,
    this.applications = const [],
    this.error,
  });

  ApplicationsState copyWith({
    bool? isLoading,
    List<ApplicationModel>? applications,
    String? error,
  }) {
    return ApplicationsState(
      isLoading: isLoading ?? this.isLoading,
      applications: applications ?? this.applications,
      error: error ?? this.error,
    );
  }
}

class ApplicationsNotifier extends StateNotifier<ApplicationsState> {
  final FirebaseService _firebaseService;

  ApplicationsNotifier(this._firebaseService) : super(ApplicationsState());

  Future<void> respondToApplication(String applicationId, String status, {String? rejectionReason}) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _firebaseService.respondToApplication(applicationId, status, rejectionReason: rejectionReason);
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

final firebaseServiceProvider = Provider((ref) => FirebaseService());

final applicationsProvider = StateNotifierProvider<ApplicationsNotifier, ApplicationsState>((ref) {
  return ApplicationsNotifier(ref.watch(firebaseServiceProvider));
});

final applicationsStreamProvider = StreamProvider.family<List<ApplicationModel>, String>((ref, organiserId) {
  return ref.watch(firebaseServiceProvider).applicationsStream(organiserId);
});
