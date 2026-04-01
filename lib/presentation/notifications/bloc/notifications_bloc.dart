import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/entities.dart';
import '../../../domain/repositories/repositories.dart';
import '../../../domain/usecases/other_usecases.dart';
import '../../../core/utils/result.dart';

// ─── Events ───────────────────────────────────────────────────────────────

abstract class NotificationsEvent {}

class NotificationsLoadRequested extends NotificationsEvent {}

class NotificationMarkedAsRead extends NotificationsEvent {
  final String notificationId;
  NotificationMarkedAsRead(this.notificationId);
}

// ─── State ────────────────────────────────────────────────────────────────

enum NotificationsStatus { initial, loading, loaded, error }

class NotificationsState {
  final NotificationsStatus status;
  final List<NotificationEntity> notifications;
  final String? errorMessage;

  const NotificationsState({
    this.status = NotificationsStatus.initial,
    this.notifications = const [],
    this.errorMessage,
  });

  int get unreadCount => notifications.where((n) => !n.isRead).length;

  NotificationsState copyWith({
    NotificationsStatus? status,
    List<NotificationEntity>? notifications,
    String? errorMessage,
  }) =>
      NotificationsState(
        status: status ?? this.status,
        notifications: notifications ?? this.notifications,
        errorMessage: errorMessage,
      );
}

// ─── BLoC ─────────────────────────────────────────────────────────────────

class NotificationsBloc extends Bloc<NotificationsEvent, NotificationsState> {
  final GetNotificationsUseCase _getNotifications;
  final NotificationRepository _repo;

  NotificationsBloc({
    required GetNotificationsUseCase getNotifications,
    required NotificationRepository repo,
  })  : _getNotifications = getNotifications,
        _repo = repo,
        super(const NotificationsState()) {
    on<NotificationsLoadRequested>(_onLoad);
    on<NotificationMarkedAsRead>(_onMarkRead);
  }

  Future<void> _onLoad(
    NotificationsLoadRequested event,
    Emitter<NotificationsState> emit,
  ) async {
    emit(state.copyWith(status: NotificationsStatus.loading));
    final result = await _getNotifications();
    result.fold(
      onSuccess: (notifications) => emit(state.copyWith(
        status: NotificationsStatus.loaded,
        notifications: notifications,
      )),
      onFailure: (msg) => emit(state.copyWith(
        status: NotificationsStatus.error,
        errorMessage: msg,
      )),
    );
  }

  Future<void> _onMarkRead(
    NotificationMarkedAsRead event,
    Emitter<NotificationsState> emit,
  ) async {
    // Optimistic update
    final updated = state.notifications.map((n) {
      if (n.id == event.notificationId) {
        return NotificationEntity(
          id: n.id,
          title: n.title,
          message: n.message,
          type: n.type,
          createdAt: n.createdAt,
          isRead: true,
        );
      }
      return n;
    }).toList();
    emit(state.copyWith(notifications: updated));
    await _repo.markAsRead(event.notificationId);
  }
}