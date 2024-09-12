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
  final String status;
  final String klar = 'är du verkligen klar med detta?';

  Todo(this.syssla, this.status);
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    List<Todo> todos = [
      Todo('laga mat', 'ej klar'),
      Todo('laga mattan', 'klar'),
      Todo('tvätta', 'ej klar'),
      Todo('plugga', 'klar'),
    ];
    return Scaffold(
      appBar: AppBar(
        title: const Text('Att göra lista'),
        centerTitle: true,
        backgroundColor: Colors.orange,
      ),
      body: ListView(
        children: todos.map((todo) => _item(context, todo)).toList(),
      ),
    );
  }

  Widget _item(BuildContext context, Todo todo) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => Time(todo)));
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: EdgeInsets.all(10),
            child: Container(
              width: 40,
              height: 40,
              decoration:
                  BoxDecoration(shape: BoxShape.rectangle, color: Colors.blue),
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
                  style: TextStyle(fontSize: 20),
                ),
                Text(todo.status)
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.only(right: 15),
            child: Icon(Icons.chevron_right),
          )
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
