import 'package:flutter/material.dart';

class AddTodoPage extends StatelessWidget {
  const AddTodoPage({super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController todoController = TextEditingController();

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
