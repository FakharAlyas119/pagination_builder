# Pagination Builder

Customizable pagination widget for loading data in chunks without using any external state management service. This package handles loading data in pages, displaying items with proper loading states, and managing pagination logic internally.

## Features

- Load data in pages with automatic pagination
- Pull-to-refresh functionality
- Customizable loading, error, and empty state widgets
- Scroll-based automatic loading of next pages
- Manual control via optional controller
- No external state management dependencies
- Type-safe generic implementation

## Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  pagination_builder: ^0.0.1
```

Or install it directly from the command line:

```bash
flutter pub add pagination_builder
```

## Example

A complete example application is available in the [example](example) directory. It demonstrates:

- Basic pagination with the factory constructor
- Advanced pagination with custom controller
- Custom data providers (API, database)
- State handling and UI customization
- Pull-to-refresh functionality

To run the example:

```bash
cd example
flutter pub get
flutter run
```

## Usage

### Basic Example

The simplest way to use the package is with the factory constructor that creates a controller for you:

```dart
import 'package:flutter/material.dart';
import 'package:pagination_builder/pagination_builder.dart';

class MyListScreen extends StatelessWidget {
  const MyListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Paginated List')),
      body: PaginationBuilder<String>.create(
        // Function to fetch items for a specific page
        fetchItems: (int page) async {
          // Simulate API call
          await Future.delayed(const Duration(seconds: 1));
          
          // Return items for this page
          return List.generate(10, (index) => 'Item ${(page - 1) * 10 + index + 1}');
        },
        
        // Build each item in the list
        itemBuilder: (context, item, index) => ListTile(
          title: Text(item),
        ),
      ),
    );
  }
}
```

### Advanced Example with Custom Controller

For more control, you can create and manage your own controller:

```dart
import 'package:flutter/material.dart';
import 'package:pagination_builder/pagination_builder.dart';

class AdvancedListScreen extends StatefulWidget {
  const AdvancedListScreen({Key? key}) : super(key: key);

  @override
  State<AdvancedListScreen> createState() => _AdvancedListScreenState();
}

class _AdvancedListScreenState extends State<AdvancedListScreen> {
  late final PaginationController<String> _controller;

  @override
  void initState() {
    super.initState();
    // Create a data provider
    final dataProvider = FunctionPaginationProvider<String>((page) async {
      await Future.delayed(const Duration(seconds: 1));
      return List.generate(20, (index) => 'Item ${(page - 1) * 20 + index + 1}');
    });
    
    // Create the controller with the data provider
    _controller = PaginationController<String>(
      dataProvider: dataProvider,
      itemsPerPage: 20,
    );
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Advanced Pagination'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _controller.refresh(),
          ),
        ],
      ),
      body: PaginationBuilder<String>(
        controller: _controller,
        itemBuilder: (context, item, index) => ListTile(
          leading: CircleAvatar(child: Text('${index + 1}')),
          title: Text(item),
        ),
        statusWidgets: PaginationStatusWidgets(
          loadingBuilder: (context) => const Center(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: CircularProgressIndicator(),
            ),
          ),
          errorBuilder: (context, error) => Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error, color: Colors.red, size: 64),
                Text('Error: ${error.toString()}'),
                ElevatedButton(
                  onPressed: () => _controller.refresh(),
                  child: const Text('Try Again'),
                ),
              ],
            ),
          ),
          emptyBuilder: (context) => const Center(
            child: Text('No items found'),
          ),
        ),
        showLoadingIndicator: true,
      ),
    );
  }
}
```

## Examples

### Handling Different Pagination States

You can listen to the pagination state changes to show different UI based on the current state:

```dart
import 'package:flutter/material.dart';
import 'package:pagination_builder/pagination_builder.dart';

class StateHandlingExample extends StatefulWidget {
  const StateHandlingExample({Key? key}) : super(key: key);

  @override
  State<StateHandlingExample> createState() => _StateHandlingExampleState();
}

class _StateHandlingExampleState extends State<StateHandlingExample> {
  late final PaginationController<String> _controller;
  
  @override
  void initState() {
    super.initState();
    // Create a data provider
    final dataProvider = FunctionPaginationProvider<String>((page) async {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));
      
      // Simulate error on page 3
      if (page == 3) {
        throw Exception('Failed to load page 3');
      }
      
      // Return empty list on page 5 to simulate end of data
      if (page >= 5) {
        return [];
      }
      
      return List.generate(10, (index) => 'Item ${(page - 1) * 10 + index + 1}');
    });
    
    _controller = PaginationController<String>(dataProvider: dataProvider);
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('State Handling Example'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _controller.refresh(),
          ),
        ],
      ),
      body: Column(
        children: [
          // Status indicator
          StreamBuilder<PaginationState<String>>(
            stream: _controller.stateStream,
            builder: (context, snapshot) {
              final state = snapshot.data ?? _controller.state;
              
              return Container(
                padding: const EdgeInsets.all(8.0),
                color: _getStatusColor(state),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (state.isLoading)
                      const SizedBox(
                        height: 16,
                        width: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    const SizedBox(width: 8),
                    Text(
                      _getStatusText(state),
                      style: const TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              );
            },
          ),
          
          // List with pagination
          Expanded(
            child: PaginationBuilder<String>(
              controller: _controller,
              itemBuilder: (context, item, index) => ListTile(
                leading: CircleAvatar(child: Text('${index + 1}')),
                title: Text(item),
                subtitle: Text('Page ${(index ~/ 10) + 1}'),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Color _getStatusColor(PaginationState<String> state) {
    if (state.error != null) return Colors.red;
    if (state.isLoading) return Colors.blue;
    if (state.hasReachedEnd) return Colors.green;
    return Colors.grey;
  }
  
  String _getStatusText(PaginationState<String> state) {
    if (state.error != null) return 'Error: ${state.error}';
    if (state.isLoading) return 'Loading...';
    if (state.hasReachedEnd) return 'All items loaded';
    return 'Page ${state.currentPage - 1} loaded, scroll for more';
  }
}
```

### Custom Data Provider Implementation

You can create your own implementation of `PaginationDataProvider` to fetch data from any source:

```dart
import 'package:flutter/material.dart';
import 'package:pagination_builder/pagination_builder.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// Custom data model
class User {
  final int id;
  final String name;
  final String email;
  
  User({required this.id, required this.name, required this.email});
  
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      email: json['email'],
    );
  }
}

// Custom data provider that fetches users from an API
class ApiUserProvider implements PaginationDataProvider<User> {
  final String baseUrl;
  final int perPage;
  
  ApiUserProvider({required this.baseUrl, this.perPage = 10});
  
  @override
  Future<List<User>> fetchItems(int page) async {
    final response = await http.get(
      Uri.parse('$baseUrl?page=$page&per_page=$perPage'),
    );
    
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => User.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load users');
    }
  }
}

// Example usage
class ApiPaginationExample extends StatefulWidget {
  const ApiPaginationExample({Key? key}) : super(key: key);

  @override
  State<ApiPaginationExample> createState() => _ApiPaginationExampleState();
}

class _ApiPaginationExampleState extends State<ApiPaginationExample> {
  late final PaginationController<User> _controller;
  
  @override
  void initState() {
    super.initState();
    // Create a custom API data provider
    final dataProvider = ApiUserProvider(
      baseUrl: 'https://jsonplaceholder.typicode.com/users',
      perPage: 5,
    );
    
    _controller = PaginationController<User>(dataProvider: dataProvider);
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('API Pagination Example')),
      body: PaginationBuilder<User>(
        controller: _controller,
        itemBuilder: (context, user, index) => ListTile(
          leading: CircleAvatar(child: Text('${user.id}')),
          title: Text(user.name),
          subtitle: Text(user.email),
        ),
        statusWidgets: PaginationStatusWidgets(
          loadingBuilder: (context) => const Center(
            child: CircularProgressIndicator(),
          ),
          errorBuilder: (context, error) => Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.cloud_off, size: 48),
                  const SizedBox(height: 16),
                  Text('Error: ${error.toString()}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => _controller.refresh(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          ),
          emptyBuilder: (context) => const Center(
            child: Text('No users found'),
          ),
        ),
      ),
    );
  }
}
```

### Database Integration Example

Here's an example of integrating with a local database (using sqflite):

```dart
import 'package:flutter/material.dart';
import 'package:pagination_builder/pagination_builder.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

// Data model
class Task {
  final int? id;
  final String title;
  final bool isCompleted;
  
  Task({this.id, required this.title, this.isCompleted = false});
  
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'isCompleted': isCompleted ? 1 : 0,
    };
  }
  
  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'],
      title: map['title'],
      isCompleted: map['isCompleted'] == 1,
    );
  }
}

// Database helper
class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;
  
  DatabaseHelper._init();
  
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('tasks.db');
    return _database!;
  }
  
  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    
    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }
  
  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE tasks(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        isCompleted INTEGER NOT NULL
      )
    ''');
    
    // Insert some sample data
    for (int i = 1; i <= 50; i++) {
      await db.insert('tasks', 
        Task(title: 'Task $i', isCompleted: i % 3 == 0).toMap(),
      );
    }
  }
  
  Future<List<Task>> getTasks(int page, int limit) async {
    final db = await instance.database;
    final offset = (page - 1) * limit;
    
    final maps = await db.query(
      'tasks',
      limit: limit,
      offset: offset,
      orderBy: 'id ASC',
    );
    
    return List.generate(maps.length, (i) => Task.fromMap(maps[i]));
  }
}

// Custom data provider for database
class DatabaseTaskProvider implements PaginationDataProvider<Task> {
  final int limit;
  
  DatabaseTaskProvider({this.limit = 10});
  
  @override
  Future<List<Task>> fetchItems(int page) async {
    return await DatabaseHelper.instance.getTasks(page, limit);
  }
}

// Example usage
class DatabasePaginationExample extends StatefulWidget {
  const DatabasePaginationExample({Key? key}) : super(key: key);

  @override
  State<DatabasePaginationExample> createState() => _DatabasePaginationExampleState();
}

class _DatabasePaginationExampleState extends State<DatabasePaginationExample> {
  late final PaginationController<Task> _controller;
  
  @override
  void initState() {
    super.initState();
    // Create a database data provider
    final dataProvider = DatabaseTaskProvider(limit: 15);
    
    _controller = PaginationController<Task>(
      dataProvider: dataProvider,
      itemsPerPage: 15,
    );
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Database Pagination'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _controller.refresh(),
          ),
        ],
      ),
      body: PaginationBuilder<Task>(
        controller: _controller,
        itemBuilder: (context, task, index) => ListTile(
          leading: Checkbox(
            value: task.isCompleted,
            onChanged: null,
          ),
          title: Text(task.title),
          trailing: Text('ID: ${task.id}'),
        ),
      ),
    );
  }
}
```
```

## API Reference

### PaginationBuilder

The main widget that handles pagination.

```dart
// Default constructor
PaginationBuilder<T>({
  required PaginationController<T> controller,
  required Widget Function(BuildContext context, T item, int index) itemBuilder,
  PaginationStatusWidgets? statusWidgets,
  bool showLoadingIndicator = true,
})

// Factory constructor
PaginationBuilder.create({
  required Future<List<T>> Function(int page) fetchItems,
  required Widget Function(BuildContext context, T item, int index) itemBuilder,
  PaginationStatusWidgets? statusWidgets,
  int itemsPerPage = 10,
  bool showLoadingIndicator = true,
  List<T>? initialItems,
})
```

#### Parameters

- `controller`: A controller that manages pagination logic and state.
- `itemBuilder`: Function that builds a widget for each item in the list.
- `statusWidgets`: Collection of widgets for displaying different pagination states.
- `showLoadingIndicator`: Whether to show a loading indicator at the bottom when loading more items.
- `fetchItems`: (Factory constructor) Function that fetches a page of data.
- `itemsPerPage`: (Factory constructor) The number of items to load per page.
- `initialItems`: (Factory constructor) Initial items to display before the first page is loaded.

### PaginationController

Controller that manages pagination logic and state.

```dart
PaginationController<T>({
  required PaginationDataProvider<T> dataProvider,
  int itemsPerPage = 10,
  List<T>? initialItems,
})
```

#### Parameters

- `dataProvider`: The data provider that fetches items.
- `itemsPerPage`: The number of items to load per page.
- `initialItems`: Initial items to display before the first page is loaded.

#### Methods

- `loadNextPage()`: Loads the next page of items.
- `refresh()`: Refreshes the list by clearing all items and loading the first page again.
- `dispose()`: Disposes of resources.

#### Properties

- `stateStream`: Stream of pagination state changes.
- `state`: The current pagination state.
- `items`: The current list of items.
- `hasReachedEnd`: Whether all items have been loaded.
- `isLoading`: Whether items are currently being loaded.

### PaginationDataProvider

Interface defining the contract for pagination data providers.

```dart
abstract class PaginationDataProvider<T> {
  Future<List<T>> fetchItems(int page);
}
```

#### Methods

- `fetchItems(int page)`: Fetches items for a specific page.

### FunctionPaginationProvider

A simple implementation of `PaginationDataProvider` that wraps a function.

```dart
FunctionPaginationProvider<T>(Future<List<T>> Function(int page) fetchFunction)
```

### PaginationState

Model class representing the state of pagination.

```dart
PaginationState<T>({
  required List<T> items,
  required int currentPage,
  required bool hasReachedEnd,
  required bool isLoading,
  dynamic error,
})
```

#### Factory Constructors

- `PaginationState.initial()`: Creates an initial state with default values.

#### Methods

- `copyWith()`: Creates a copy of this state with the given fields replaced with new values.

### PaginationStatusWidgets

A collection of widgets for displaying different pagination states.

```dart
PaginationStatusWidgets({
  required Widget Function(BuildContext context) loadingBuilder,
  required Widget Function(BuildContext context, dynamic error) errorBuilder,
  required Widget Function(BuildContext context) emptyBuilder,
})
```

#### Factory Constructors

- `PaginationStatusWidgets.defaults()`: Creates a `PaginationStatusWidgets` instance with default builders.
