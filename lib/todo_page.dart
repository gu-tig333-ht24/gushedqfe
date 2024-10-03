import 'package:flutter/material.dart';
import 'add_todo_page.dart';
import 'todo_api.dart';
import 'models/todo.dart';

class TodoPage extends StatefulWidget {
  const TodoPage({super.key});

  @override
  TodoPageState createState() => TodoPageState();
}

class TodoPageState extends State<TodoPage> {
  List<Todo> todos = [];
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
      List<Todo> fetchedTodos = await TodoService.fetchTodos();
      setState(() {
        todos = fetchedTodos;
        isLoading = false;
      });
    } catch (e) {
      _showErrorMessage('Error fetching todos: $e');
    }
  }

  Future<void> _toggleStatus(Todo todo) async {
    try {
      await TodoService.updateTodoStatus(todo);
      setState(() {
        todo.done = !todo.done;
      });
    } catch (e) {
      _showErrorMessage('Error updating todo: $e');
    }
  }

  Future<void> _addTodoItem(String task) async {
    if (task.isNotEmpty) {
      try {
        List<Todo> updatedTodos = await TodoService.addTodo(task);
        setState(() {
          todos = updatedTodos;
        });
      } catch (e) {
        _showErrorMessage('Error adding todo: $e');
      }
    } else {
      _showErrorMessage('Todo cannot be empty!');
    }
  }

  Future<void> _removeTodoItem(Todo todo) async {
    try {
      await TodoService.deleteTodo(todo.id);
      setState(() {
        todos.remove(todo);
      });
    } catch (e) {
      _showErrorMessage('Error deleting todo: $e');
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
      MaterialPageRoute(builder: (context) => const AddTodoPage()),
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
        title: const Text('Todo List'),
        centerTitle: true,
        backgroundColor: Colors.orange,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
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
                        .map((todo) => _buildTodoItem(context, todo))
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

  Widget _buildTodoItem(BuildContext context, Todo todo) {
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
                    decoration: todo.done
                        ? TextDecoration.lineThrough
                        : null,
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
