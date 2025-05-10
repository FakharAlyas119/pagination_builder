import '../interfaces/pagination_data_provider.dart';

/// A simple implementation of [PaginationDataProvider] that wraps a function.
class FunctionPaginationProvider<T> implements PaginationDataProvider<T> {
  /// The function that fetches items for a specific page.
  final Future<List<T>> Function(int page) _fetchFunction;

  /// Creates a [FunctionPaginationProvider] with the given fetch function.
  FunctionPaginationProvider(this._fetchFunction);

  @override
  Future<List<T>> fetchItems(int page) => _fetchFunction(page);
}
