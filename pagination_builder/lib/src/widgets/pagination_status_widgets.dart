import 'package:flutter/material.dart';

/// A collection of widgets for displaying different pagination states.
class PaginationStatusWidgets {
  /// Builds a widget to display when loading items.
  final Widget Function(BuildContext context) loadingBuilder;

  /// Builds a widget to display when an error occurs.
  final Widget Function(BuildContext context, dynamic error) errorBuilder;

  /// Builds a widget to display when the list is empty.
  final Widget Function(BuildContext context) emptyBuilder;

  /// Creates a [PaginationStatusWidgets] instance with the given builders.
  const PaginationStatusWidgets({
    required this.loadingBuilder,
    required this.errorBuilder,
    required this.emptyBuilder,
  });

  /// Creates a [PaginationStatusWidgets] instance with default builders.
  factory PaginationStatusWidgets.defaults() {
    return PaginationStatusWidgets(
      loadingBuilder:
          (context) => const Center(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: CircularProgressIndicator(),
            ),
          ),
      errorBuilder:
          (context, error) => Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error, color: Colors.red, size: 64),
                  const SizedBox(height: 16),
                  Text('Error: ${error.toString()}'),
                ],
              ),
            ),
          ),
      emptyBuilder:
          (context) => const Center(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.inbox, color: Colors.grey, size: 64),
                  SizedBox(height: 16),
                  Text('No items found'),
                ],
              ),
            ),
          ),
    );
  }
}
