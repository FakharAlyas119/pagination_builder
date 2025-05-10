import 'package:flutter/material.dart';

import '../controllers/pagination_controller.dart';
import '../implementations/function_pagination_provider.dart';
import '../models/pagination_state.dart';
import 'pagination_status_widgets.dart';

/// A widget that handles pagination for a list of items.
class PaginationBuilder<T> extends StatefulWidget {
  /// Function that builds a widget for each item in the list.
  final Widget Function(BuildContext context, T item, int index) itemBuilder;

  /// The pagination controller that manages the state and logic.
  final PaginationController<T> controller;

  /// Widgets for displaying different pagination states.
  final PaginationStatusWidgets statusWidgets;

  /// Whether to show a loading indicator at the bottom when loading more items.
  final bool showLoadingIndicator;

  /// Creates a [PaginationBuilder] widget.
  ///
  /// You can either provide a [controller] directly, or use the [create] factory
  /// constructor to create a controller with a [fetchItems] function.
  PaginationBuilder({
    super.key,
    required this.controller,
    required this.itemBuilder,
    PaginationStatusWidgets? statusWidgets,
    this.showLoadingIndicator = true,
  }) : statusWidgets = statusWidgets ?? PaginationStatusWidgets.defaults();

  /// Creates a [PaginationBuilder] widget with a new controller.
  ///
  /// This factory constructor creates a new [PaginationController] with the given
  /// [fetchItems] function and other parameters.
  factory PaginationBuilder.create({
    Key? key,
    required Future<List<T>> Function(int page) fetchItems,
    required Widget Function(BuildContext context, T item, int index)
    itemBuilder,
    PaginationStatusWidgets? statusWidgets,
    int itemsPerPage = 10,
    bool showLoadingIndicator = true,
    List<T>? initialItems,
  }) {
    // Create a data provider that implements the PaginationDataProvider interface
    final dataProvider = FunctionPaginationProvider<T>(fetchItems);

    // Create a controller with the data provider
    final controller = PaginationController<T>(
      dataProvider: dataProvider,
      itemsPerPage: itemsPerPage,
      initialItems: initialItems,
    );

    return PaginationBuilder<T>(
      key: key,
      controller: controller,
      itemBuilder: itemBuilder,
      statusWidgets: statusWidgets,
      showLoadingIndicator: showLoadingIndicator,
    );
  }

  @override
  State<PaginationBuilder<T>> createState() => _PaginationBuilderState<T>();
}

class _PaginationBuilderState<T> extends State<PaginationBuilder<T>> {
  /// The scroll controller used to detect when the user has scrolled to the bottom.
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);

    // Load the first page if the controller has no items yet
    if (widget.controller.items.isEmpty) {
      widget.controller.loadNextPage();
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  /// Listener for scroll events to detect when to load more items.
  void _scrollListener() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent * 0.8 &&
        !widget.controller.isLoading &&
        !widget.controller.hasReachedEnd) {
      widget.controller.loadNextPage();
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<PaginationState<T>>(
      stream: widget.controller.stateStream,
      initialData: widget.controller.state,
      builder: (context, snapshot) {
        final state = snapshot.data!;

        // Show error widget if there's an error and no items
        if (state.error != null && state.items.isEmpty) {
          return widget.statusWidgets.errorBuilder(context, state.error);
        }

        // Show empty widget if there are no items and not loading
        if (state.items.isEmpty && !state.isLoading) {
          return widget.statusWidgets.emptyBuilder(context);
        }

        // Show loading widget if loading the first page
        if (state.items.isEmpty && state.isLoading) {
          return widget.statusWidgets.loadingBuilder(context);
        }

        return RefreshIndicator(
          onRefresh: widget.controller.refresh,
          child: ListView.builder(
            controller: _scrollController,
            itemCount:
                state.items.length +
                (state.isLoading && widget.showLoadingIndicator ? 1 : 0),
            itemBuilder: (context, index) {
              // Show loading indicator at the bottom
              if (index == state.items.length &&
                  state.isLoading &&
                  widget.showLoadingIndicator) {
                return widget.statusWidgets.loadingBuilder(context);
              }

              // Show item
              return widget.itemBuilder(context, state.items[index], index);
            },
          ),
        );
      },
    );
  }
}
