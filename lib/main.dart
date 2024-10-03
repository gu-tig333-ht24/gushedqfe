import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

const String apiUrl = 'https://todoapp-api.apps.k8s.gu.se/todos';
const String apiKey = '0aadd983-d67c-4049-a1f3-6754bbda46e2';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Todo List',
      theme: ThemeData(
        primarySwatch: Colors.orange,
      ),
      home: const MyHomePage(),
    );
  }
}

class Todo {
  final String id;
  final String title;
  bool done;

  Todo({
    required this.id,
    required this.title,
    required this.done,
  });
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  MyHomePageState createState() => MyHomePageState();
}

class MyHomePageState extends State<MyHomePage> {
  List<Todo> todos = [];
  final TextEditingController todoController = TextEditingController();
  String filter = 'alla';
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchTodos();
  }

  Future<void> _fetchTodos() async {
    setState(() {
      isLoading = true;
    });

    try {
      final response = await http.get(Uri.parse('$apiUrl?key=$apiKey'));

      if (response.statusCode == 200) {
        List<dynamic> todosFromApi = jsonDecode(response.body);
        setState(() {
          todos = todosFromApi.map((data) {
            return Todo(
              id: data['id'],
              title: data['title'],
              done: data['done'],
            );
          }).toList();
          isLoading = false;
        });
      } else {
        _showErrorMessage('Misslyckades med att hämta sysslor från server');
      }
    } catch (e) {
      _showErrorMessage('Ett fel inträffade: $e');
    }
  }

  Future<void> _toggleStatus(Todo todo) async {
    bool newStatus = !todo.done;

    try {
      final response = await http.put(
        Uri.parse('$apiUrl/${todo.id}?key=$apiKey'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'title': todo.title, 'done': newStatus}),
      );

      if (response.statusCode == 200) {
        setState(() {
          todo.done = newStatus;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Status uppdaterad')),
        );
      } else {
        _showErrorMessage('Misslyckades med att uppdatera syssla');
      }
    } catch (e) {
      _showErrorMessage('Ett fel inträffade: $e');
    }
  }

  Future<void> _addTodoItem(String task) async {
    if (task.isNotEmpty) {
      try {
        final response = await http.post(
          Uri.parse('$apiUrl?key=$apiKey'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({"title": task, "done": false}),
        );

        if (response.statusCode == 201 || response.statusCode == 200) {
          List<dynamic> todosFromApi = jsonDecode(response.body);
          setState(() {
            todos = todosFromApi.map((data) {
              return Todo(
                id: data['id'],
                title: data['title'],
                done: data['done'],
              );
            }).toList();
          });
          todoController.clear();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Syssla tillagd!')),
          );
        } else {
          _showErrorMessage('Misslyckades med att lägga till syssla');
        }
      } catch (e) {
        _showErrorMessage('Ett fel inträffade: $e');
      }
    } else {
      _showErrorMessage('Uppgiften kan inte vara tom!');
    }
  }

  Future<void> _removeTodoItem(Todo todo) async {
    try {
      final response = await http.delete(
        Uri.parse('$apiUrl/${todo.id}?key=$apiKey'),
      );

      if (response.statusCode == 200) {
        setState(() {
          todos.remove(todo);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Syssla borttagen!')),
        );
      } else {
        _showErrorMessage('Misslyckades med att ta bort syssla');
      }
    } catch (e) {
      _showErrorMessage('Ett fel inträffade: $e');
    }
  }

  void _showErrorMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  List<Todo> getFilteredTodos() {
    if (filter == 'klar') {
      return todos.where((todo) => todo.done).toList();
    } else if (filter == 'ej klar') {
      return todos.where((todo) => !todo.done).toList();
    } else {
      return todos;
    }
  }

  void _navigateToAddTodoPage() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddTodoPage()),
    );

    if (result != null && result is String) {
      _addTodoItem(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    List<Todo> filteredTodos = getFilteredTodos();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Att göra lista'),
        centerTitle: true,
        backgroundColor: Colors.orange,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: DropdownButton<String>(
                    value: filter,
                    onChanged: (String? newValue) {
                      setState(() {
                        filter = newValue ?? 'alla';
                      });
                    },
                    items: <String>['alla', 'klar', 'ej klar']
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                ),
                Expanded(
                  child: ListView(
                    children: filteredTodos
                        .map((todo) => _item(context, todo))
                        .toList(),
                  ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAddTodoPage,
        child: const Icon(Icons.add),
        backgroundColor: Colors.orange,
      ),
    );
  }

  Widget _item(BuildContext context, Todo todo) {
    return GestureDetector(
      onTap: () {
        _toggleStatus(todo);
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(10),
            child: Checkbox(
              value: todo.done,
              onChanged: (bool? newValue) {
                _toggleStatus(todo);
              },
            ),
          ),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  todo.title,
                  style: TextStyle(
                    fontSize: 20,
                    decoration: todo.done ? TextDecoration.lineThrough : null,
                    color: todo.done ? Colors.green : Colors.black,
                  ),
                ),
                Text(todo.done ? 'klar' : 'ej klar')
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 15),
            child: IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () {
                _removeTodoItem(todo);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class AddTodoPage extends StatelessWidget {
  final TextEditingController todoController = TextEditingController();

  AddTodoPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lägg till syssla'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              'Skriv in din syssla:',
              style: TextStyle(fontSize: 20),
            ),
            TextField(
              controller: todoController,
              autofocus: true,
              decoration: const InputDecoration(
                labelText: 'Syssla',
              ),
              onSubmitted: (value) {
                Navigator.pop(context, value);
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, todoController.text);
              },
              child: const Text('Lägg till'),
            ),
          ],
        ),
      ),
    );
  }
}
