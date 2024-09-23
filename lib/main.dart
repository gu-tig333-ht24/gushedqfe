import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Todo List', // App title
      theme: ThemeData(
        primarySwatch: Colors.orange,
      ),
      home: const MyHomePage(),
    );
  }
}

class Todo {
  final String syssla;
  String status;
  final String klar = 'är du verkligen klar med detta?';

  Todo(this.syssla, this.status);
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<Todo> todos = [];

  TextEditingController todoController = TextEditingController();
  String filter = 'alla';

  void _toggleStatus(Todo todo) {
    setState(() {
      if (todo.status == 'klar') {
        todo.status = 'ej klar';
      } else {
        todo.status = 'klar';
      }
    });
  }

  void _addTodoItem(String task) {
    if (task.isNotEmpty) {
      setState(() {
        todos.add(Todo(task, 'ej klar'));
      });
      todoController.clear();
    }
  }

  void _removeTodoItem(Todo todo) {
    setState(() {
      todos.remove(todo);
    });
  }

  List<Todo> getFilteredTodos() {
    if (filter == 'klar') {
      return todos.where((todo) => todo.status == 'klar').toList();
    } else if (filter == 'ej klar') {
      return todos.where((todo) => todo.status == 'ej klar').toList();
    } else {
      return todos;
    }
  }

  void _showAddTodoDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('lägga till en uppgift'),
          content: TextField(
            controller: todoController,
            decoration: const InputDecoration(hintText: 'ange uppgift'),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Avbryt'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Lägg till'),
              onPressed: () {
                _addTodoItem(todoController.text);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
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
      body: Column(
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
              children:
                  filteredTodos.map((todo) => _item(context, todo)).toList(),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddTodoDialog,
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
            padding: EdgeInsets.all(10),
            child: Checkbox(
              value: todo.status == 'klar',
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
                  todo.syssla,
                  style: TextStyle(
                    fontSize: 20,
                    decoration: todo.status == 'klar'
                        ? TextDecoration.lineThrough
                        : null,
                    color: todo.status == 'klar' ? Colors.green : Colors.black,
                  ),
                ),
                Text(todo.status)
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.only(right: 15),
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

class Time extends StatelessWidget {
  final Todo todo;
  Time(this.todo);

  @override
  Widget build(BuildContext) {
    return Scaffold(
      appBar: AppBar(title: Text(todo.syssla)),
      body: Text(todo.klar),
    );
  }
}
