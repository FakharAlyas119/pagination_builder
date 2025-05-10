import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pagination_builder/pagination_builder.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pagination Builder Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pagination Builder Examples'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildExampleCard(
            context,
            title: 'Basic Example',
            description: 'Simple list with automatic pagination',
            screen: const BasicExampleScreen(),
          ),
          _buildExampleCard(
            context,
            title: 'Advanced Example',
            description: 'Custom controller with more control options',
            screen: const AdvancedExampleScreen(),
          ),
          _buildExampleCard(
            context,
            title: 'API Example',
            description: 'Integration with a REST API',
            screen: const ApiExampleScreen(),
          ),
          _buildExampleCard(
            context,
            title: 'State Handling Example',
            description: 'Demonstration of different pagination states',
            screen: const StateHandlingExampleScreen(),
          ),
          _buildExampleCard(
            context,
            title: 'Database Example',
            description: 'Integration with a local database',
            screen: const DatabaseExampleScreen(),
          ),
        ],
      ),
    );
  }

  Widget _buildExampleCard(
    BuildContext context, {
    required String title,
    required String description,
    required Widget screen,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      child: InkWell(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => screen),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8.0),
              Text(description),
              const SizedBox(height: 8.0),
              Align(
                alignment: Alignment.centerRight,
                child: Icon(
                  Icons.arrow_forward,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// 1. Basic Example
class BasicExampleScreen extends StatelessWidget {
  const BasicExampleScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Basic Example')),
      body: PaginationBuilder<String>.create(
        // Function to fetch items for a specific page
        fetchItems: (int page) async {
          // Simulate API call
          await Future.delayed(const Duration(seconds: 1));

          // Return items for this page
          return List.generate(
              10, (index) => 'Item ${(page - 1) * 10 + index + 1}');
        },

        // Build each item in the list
        itemBuilder: (context, item, index) => ListTile(
          leading: CircleAvatar(child: Text('${index + 1}')),
          title: Text(item),
        ),
      ),
    );
  }
}

// 2. Advanced Example
class AdvancedExampleScreen extends StatefulWidget {
  const AdvancedExampleScreen({Key? key}) : super(key: key);

  @override
  State<AdvancedExampleScreen> createState() => _AdvancedExampleScreenState();
}

class _AdvancedExampleScreenState extends State<AdvancedExampleScreen> {
  late final PaginationController<String> _controller;

  @override
  void initState() {
    super.initState();
    // Create a data provider
    final dataProvider = FunctionPaginationProvider<String>((page) async {
      await Future.delayed(const Duration(seconds: 1));
      return List.generate(
          20, (index) => 'Item ${(page - 1) * 20 + index + 1}');
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
        title: const Text('Advanced Example'),
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

// 3. API Example
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

class ApiUserProvider implements PaginationDataProvider<User> {
  final String baseUrl;
  final int perPage;

  ApiUserProvider({required this.baseUrl, this.perPage = 10});

  @override
  Future<List<User>> fetchItems(int page) async {
    // For demo purposes, we're using JSONPlaceholder API
    // In a real app, you would use pagination parameters
    final response = await http.get(
      Uri.parse('$baseUrl?_limit=$perPage&_page=$page'),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => User.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load users');
    }
  }
}

class ApiExampleScreen extends StatefulWidget {
  const ApiExampleScreen({Key? key}) : super(key: key);

  @override
  State<ApiExampleScreen> createState() => _ApiExampleScreenState();
}

class _ApiExampleScreenState extends State<ApiExampleScreen> {
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
      appBar: AppBar(title: const Text('API Example')),
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

// 4. State Handling Example
class StateHandlingExampleScreen extends StatefulWidget {
  const StateHandlingExampleScreen({Key? key}) : super(key: key);

  @override
  State<StateHandlingExampleScreen> createState() =>
      _StateHandlingExampleScreenState();
}

class _StateHandlingExampleScreenState
    extends State<StateHandlingExampleScreen> {
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

      return List.generate(
          10, (index) => 'Item ${(page - 1) * 10 + index + 1}');
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
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
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

// 5. Database Example
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
      await db.insert(
        'tasks',
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

class DatabaseTaskProvider implements PaginationDataProvider<Task> {
  final int limit;

  DatabaseTaskProvider({this.limit = 10});

  @override
  Future<List<Task>> fetchItems(int page) async {
    return await DatabaseHelper.instance.getTasks(page, limit);
  }
}

class DatabaseExampleScreen extends StatefulWidget {
  const DatabaseExampleScreen({Key? key}) : super(key: key);

  @override
  State<DatabaseExampleScreen> createState() => _DatabaseExampleScreenState();
}

class _DatabaseExampleScreenState extends State<DatabaseExampleScreen> {
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
        title: const Text('Database Example'),
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
