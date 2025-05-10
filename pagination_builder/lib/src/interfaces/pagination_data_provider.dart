import 'package:flutter/foundation.dart';

/// Interface defining the contract for pagination data providers.
@immutable
abstract class PaginationDataProvider<T> {
  /// Fetches items for a specific page.
  ///
  /// The [page] parameter indicates which page to fetch (starting from 1).
  /// Returns a Future that resolves to a list of items of type [T].
  Future<List<T>> fetchItems(int page);
}
