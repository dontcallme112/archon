part of 'feed_bloc.dart';

abstract class FeedEvent {}

class FeedLoadRequested extends FeedEvent {}

class FeedRefreshRequested extends FeedEvent {}

class FeedLoadMoreRequested extends FeedEvent {}

/// Переключение навыка (добавить/убрать из множества)
class FeedSkillToggled extends FeedEvent {
  final String skillId;
  FeedSkillToggled(this.skillId);
}

/// Сброс всех выбранных навыков
class FeedSkillsCleared extends FeedEvent {}

class FeedFormatChanged extends FeedEvent {
  final String? format;
  FeedFormatChanged(this.format);
}

class FeedLevelChanged extends FeedEvent {
  final String? level;
  FeedLevelChanged(this.level);
}

class FeedSearchChanged extends FeedEvent {
  final String query;
  FeedSearchChanged(this.query);
}

class FeedFiltersCleared extends FeedEvent {}
