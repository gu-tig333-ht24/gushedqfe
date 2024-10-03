import 'dart:convert';
import 'package:http/http.dart' as http;
import 'models/todo.dart';

const String apiUrl = 'https://todoapp-api.apps.k8s.gu.se/todos';
const String apiKey = '0aadd983-d67c-4049-a1f3-6754bbda46e2';

class TodoService {
  static Future<List<Todo>> fetchTodos() async {
    final response = await http.get(Uri.parse('$apiUrl?key=$apiKey'));
    if (response.statusCode == 200) {
      List<dynamic> todosFromApi = jsonDecode(response.body);
      return todosFromApi.map((data) => Todo.fromJson(data)).toList();
    } else {
      throw Exception('Failed to load todos');
    }
  }

  static Future<List<Todo>> addTodo(String title) async {
    final response = await http.post(
      Uri.parse('$apiUrl?key=$apiKey'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({"title": title, "done": false}),
    );
    if (response.statusCode == 201 || response.statusCode == 200) {
      List<dynamic> todosFromApi = jsonDecode(response.body);
      return todosFromApi.map((data) => Todo.fromJson(data)).toList();
    } else {
      throw Exception('Failed to add todo');
    }
  }

  static Future<void> updateTodoStatus(Todo todo) async {
    final response = await http.put(
      Uri.parse('$apiUrl/${todo.id}?key=$apiKey'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'title': todo.title, 'done': !todo.done}),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to update todo');
    }
  }

  static Future<void> deleteTodo(String id) async {
    final response = await http.delete(Uri.parse('$apiUrl/$id?key=$apiKey'));
    if (response.statusCode != 200) {
      throw Exception('Failed to delete todo');
    }
  }
}
