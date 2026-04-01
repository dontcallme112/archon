part of 'feed_bloc.dart';

abstract class FeedEvent {}

class FeedLoadRequested extends FeedEvent {}

class FeedCategoryChanged extends FeedEvent {
  final String category;
  FeedCategoryChanged(this.category);
}

class FeedFormatChanged extends FeedEvent {
  final String format;
  FeedFormatChanged(this.format);
}

class FeedSearchChanged extends FeedEvent {
  final String query;
  FeedSearchChanged(this.query);
}

class FeedFavoriteToggled extends FeedEvent {
  final String projectId;
  FeedFavoriteToggled(this.projectId);
}

class FeedRefreshRequested extends FeedEvent {}
