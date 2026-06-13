import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/event_model.dart';
import '../core/services/firebase_service.dart';

class EventsState {
  final bool isLoading;
  final List<EventModel> events;
  final String? error;

  EventsState({
    this.isLoading = false,
    this.events = const [],
    this.error,
  });

  EventsState copyWith({
    bool? isLoading,
    List<EventModel>? events,
    String? error,
  }) {
    return EventsState(
      isLoading: isLoading ?? this.isLoading,
      events: events ?? this.events,
      error: error ?? this.error,
    );
  }
}

class EventsNotifier extends StateNotifier<EventsState> {
  final FirebaseService _firebaseService;

  EventsNotifier(this._firebaseService) : super(EventsState());

  Future<void> createEvent(EventModel event) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _firebaseService.createEvent(event);
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

final firebaseServiceProvider = Provider((ref) => FirebaseService());

final eventsProvider = StateNotifierProvider<EventsNotifier, EventsState>((ref) {
  return EventsNotifier(ref.watch(firebaseServiceProvider));
});

final myEventsProvider = StreamProvider.family<List<EventModel>, String>((ref, organiserId) {
  return ref.watch(firebaseServiceProvider).myEventsStream(organiserId);
});
