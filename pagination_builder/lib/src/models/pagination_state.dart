import 'package:flutter/foundation.dart';

/// Model class representing the state of pagination.
@immutable
class PaginationState<T> {
  /// The current list of items.
  final List<T> items;

  /// The current page number.
  final int currentPage;

  /// Whether all items have been loaded.
  final bool hasReachedEnd;

  /// Whether items are currently being loaded.
  final bool isLoading;

  /// The current error, if any.
  final dynamic error;

  /// Creates a [PaginationState] instance.
  const PaginationState({
    required this.items,
    required this.currentPage,
    required this.hasReachedEnd,
    required this.isLoading,
    this.error,
  });

  /// Creates an initial state with default values.
  factory PaginationState.initial() {
    return PaginationState<T>(
      items: [],
      currentPage: 1,
      hasReachedEnd: false,
      isLoading: false,
      error: null,
    );
  }

  /// Creates a copy of this state with the given fields replaced with new values.
  PaginationState<T> copyWith({
    List<T>? items,
    int? currentPage,
    bool? hasReachedEnd,
    bool? isLoading,
    dynamic error,
    bool clearError = false,
  }) {
    return PaginationState<T>(
      items: items ?? this.items,
      currentPage: currentPage ?? this.currentPage,
      hasReachedEnd: hasReachedEnd ?? this.hasReachedEnd,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}
