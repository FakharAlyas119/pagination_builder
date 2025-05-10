import 'dart:async';

import '../interfaces/pagination_data_provider.dart';
import '../models/pagination_state.dart';

/// Controller that manages pagination logic and state.
class PaginationController<T> {
  /// The data provider that fetches items.
  final PaginationDataProvider<T> _dataProvider;

  /// The current state of pagination.
  PaginationState<T> _state = PaginationState<T>.initial();

  /// Stream controller for broadcasting state changes.
  final _stateController = StreamController<PaginationState<T>>.broadcast();

  /// Stream of pagination state changes.
  Stream<PaginationState<T>> get stateStream => _stateController.stream;

  /// The current pagination state.
  PaginationState<T> get state => _state;

  /// The number of items to load per page.
  final int itemsPerPage;

  /// Creates a [PaginationController] with the given data provider.
  PaginationController({
    required PaginationDataProvider<T> dataProvider,
    this.itemsPerPage = 10,
    List<T>? initialItems,
  }) : _dataProvider = dataProvider {
    if (initialItems != null && initialItems.isNotEmpty) {
      _state = _state.copyWith(items: List.from(initialItems));
      _emitState();
    }
  }

  /// Loads the next page of items.
  Future<void> loadNextPage() async {
    if (_state.isLoading || _state.hasReachedEnd) return;

    _updateState(_state.copyWith(isLoading: true, clearError: true));

    try {
      final newItems = await _dataProvider.fetchItems(_state.currentPage);

      if (newItems.isEmpty) {
        _updateState(_state.copyWith(hasReachedEnd: true, isLoading: false));
      } else {
        final updatedItems = List<T>.from(_state.items)..addAll(newItems);
        _updateState(
          _state.copyWith(
            items: updatedItems,
            currentPage: _state.currentPage + 1,
            isLoading: false,
          ),
        );
      }
    } catch (e) {
      _updateState(_state.copyWith(error: e, isLoading: false));
    }
  }

  /// Refreshes the list by clearing all items and loading the first page again.
  Future<void> refresh() async {
    _updateState(PaginationState<T>.initial());
    await loadNextPage();
  }

  /// Updates the state and emits the new state to listeners.
  void _updateState(PaginationState<T> newState) {
    _state = newState;
    _emitState();
  }

  /// Emits the current state to listeners.
  void _emitState() {
    if (!_stateController.isClosed) {
      _stateController.add(_state);
    }
  }

  /// Returns the current list of items.
  List<T> get items => _state.items;

  /// Returns whether all items have been loaded.
  bool get hasReachedEnd => _state.hasReachedEnd;

  /// Returns whether items are currently being loaded.
  bool get isLoading => _state.isLoading;

  /// Disposes of resources.
  void dispose() {
    _stateController.close();
  }
}
