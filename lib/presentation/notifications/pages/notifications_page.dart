import 'package:flutter/material.dart';
import '../../../domain/entities/entities.dart';
import '../../common/widgets/common_widgets.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_typography.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  late List<NotificationEntity> _notifications;

  @override
  void initState() {
    super.initState();
    _notifications = _mockNotifications();
  }

  int get _unreadCount => _notifications.where((n) => !n.isRead).length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // ─── Header ──────────────────────────────────────────
            Container(
              color: AppColors.white,
              padding: const EdgeInsets.fromLTRB(AppSizes.md, AppSizes.md, AppSizes.sm, AppSizes.md),
              child: Row(
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Text('Уведомления', style: AppTypography.h2),
                        if (_unreadCount > 0) ...[
                          const SizedBox(width: AppSizes.sm),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(AppSizes.radiusFull),
                            ),
                            child: Text(
                              '$_unreadCount',
                              style: const TextStyle(
                                color: AppColors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (_unreadCount > 0)
                    TextButton(
                      onPressed: _markAllRead,
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: AppSizes.sm),
                        minimumSize: Size.zero,
                      ),
                      child: Text(
                        'Прочитать все',
                        style: AppTypography.label.copyWith(color: AppColors.primary),
                      ),
                    ),
                ],
              ),
            ),

            // ─── List ─────────────────────────────────────────────
            Expanded(
              child: _notifications.isEmpty
                  ? _EmptyNotifications()
                  : ListView.builder(
                      padding: const EdgeInsets.all(AppSizes.md),
                      itemCount: _notifications.length + (_hasUnread() ? 1 : 0),
                      itemBuilder: (context, i) {
                        // Insert "Older" separator after unread block
                        if (_hasUnread() && i == _unreadCount) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: AppSizes.sm),
                            child: Row(
                              children: [
                                const Expanded(child: Divider()),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: AppSizes.sm),
                                  child: Text('Ранее', style: AppTypography.caption),
                                ),
                                const Expanded(child: Divider()),
                              ],
                            ),
                          );
                        }
                        final index = _hasUnread() && i > _unreadCount ? i - 1 : i;
                        return _NotificationTile(
                          notification: _notifications[index],
                          onTap: () => _markOneRead(_notifications[index].id),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  bool _hasUnread() => _unreadCount > 0 && _unreadCount < _notifications.length;

  void _markAllRead() {
    setState(() {
      _notifications = _notifications
          .map((n) => NotificationEntity(
                id: n.id,
                title: n.title,
                message: n.message,
                type: n.type,
                createdAt: n.createdAt,
                isRead: true,
              ))
          .toList();
    });
  }

  void _markOneRead(String id) {
    setState(() {
      _notifications = _notifications.map((n) {
        if (n.id == id) {
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
    });
  }
}

// ─── Tile ─────────────────────────────────────────────────────────────────

class _NotificationTile extends StatelessWidget {
  final NotificationEntity notification;
  final VoidCallback onTap;

  const _NotificationTile({
    required this.notification,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final n = notification;

    final (icon, iconColor, iconBg) = switch (n.type) {
      NotificationType.applicationAccepted => (
          Icons.check_circle_rounded,
          AppColors.success,
          const Color(0xFFE8F5E9),
        ),
      NotificationType.applicationRejected => (
          Icons.cancel_rounded,
          AppColors.error,
          const Color(0xFFFFEBEE),
        ),
      NotificationType.newMessage => (
          Icons.chat_bubble_rounded,
          AppColors.primary,
          AppColors.primarySurface,
        ),
      NotificationType.newProject => (
          Icons.rocket_launch_rounded,
          AppColors.warning,
          const Color(0xFFFFF3E0),
        ),
    };

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: AppSizes.sm),
        padding: const EdgeInsets.all(AppSizes.md),
        decoration: BoxDecoration(
          color: n.isRead ? AppColors.white : AppColors.primarySurface,
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          border: n.isRead
              ? null
              : Border.all(color: AppColors.primaryLight, width: 1),
          boxShadow: [
            BoxShadow(
              color: AppColors.dark.withOpacity(n.isRead ? 0.03 : 0.06),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
              child: Icon(icon, color: iconColor, size: 22),
            ),
            const SizedBox(width: AppSizes.sm),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          n.title,
                          style: AppTypography.h4.copyWith(
                            fontWeight: n.isRead ? FontWeight.w500 : FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(_timeAgo(n.createdAt), style: AppTypography.caption),
                    ],
                  ),
                  if (n.message.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      n.message,
                      style: AppTypography.body.copyWith(color: AppColors.darkGrey),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),

            // Unread dot
            if (!n.isRead)
              Padding(
                padding: const EdgeInsets.only(left: 6, top: 4),
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'только что';
    if (diff.inMinutes < 60) return '${diff.inMinutes} мин';
    if (diff.inHours < 24) return '${diff.inHours} ч';
    return '${diff.inDays} дн';
  }
}

// ─── Empty state ──────────────────────────────────────────────────────────

class _EmptyNotifications extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: const BoxDecoration(
              color: AppColors.primarySurface,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.notifications_none_rounded,
                size: 36, color: AppColors.primary),
          ),
          const SizedBox(height: AppSizes.md),
          Text('Нет уведомлений', style: AppTypography.h3),
          const SizedBox(height: AppSizes.xs),
          Text(
            'Здесь появятся обновления\nпо твоим проектам и заявкам',
            style: AppTypography.body.copyWith(color: AppColors.grey),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// ─── Mock Data ────────────────────────────────────────────────────────────

List<NotificationEntity> _mockNotifications() => [
      NotificationEntity(
        id: 'n1',
        title: 'Заявка принята!',
        message: 'Тебя добавили в проект «Redesign фитнес-приложения»',
        type: NotificationType.applicationAccepted,
        createdAt: DateTime.now().subtract(const Duration(minutes: 5)),
        isRead: false,
      ),
      NotificationEntity(
        id: 'n2',
        title: 'Тебя приняли в проект: Fitness App',
        message: 'Иван Иванов одобрил твою заявку',
        type: NotificationType.applicationAccepted,
        createdAt: DateTime.now().subtract(const Duration(minutes: 30)),
        isRead: false,
      ),
      NotificationEntity(
        id: 'n3',
        title: 'Новое сообщение от Ивана Иванова',
        message: 'Привет! Когда сможешь выйти на связь?',
        type: NotificationType.newMessage,
        createdAt: DateTime.now().subtract(const Duration(hours: 1, minutes: 10)),
        isRead: false,
      ),
      NotificationEntity(
        id: 'n4',
        title: 'Новый проект: AI Startap (React)',
        message: 'Проект подходит под твои навыки',
        type: NotificationType.newProject,
        createdAt: DateTime.now().subtract(const Duration(hours: 3)),
        isRead: true,
      ),
      NotificationEntity(
        id: 'n5',
        title: 'Заявка отклонена',
        message: 'К сожалению, в проекте «E-commerce» закрыт набор',
        type: NotificationType.applicationRejected,
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        isRead: true,
      ),
      NotificationEntity(
        id: 'n6',
        title: 'Новый проект по маркетингу',
        message: 'Найдено 3 новых проекта по твоим навыкам',
        type: NotificationType.newProject,
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
        isRead: true,
      ),
    ];