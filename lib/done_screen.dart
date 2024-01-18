import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:todo/todo_screen.dart';

class DoneScreen extends StatelessWidget {
  final List completedItems;
  final Function()
      deleteAllCompletedTasks; // Callback function to delete all completed tasks

  DoneScreen(
      {required this.completedItems, required this.deleteAllCompletedTasks});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Done'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () {
              deleteAllCompletedTasks(); // Call the function to delete all completed tasks
            },
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: completedItems.length,
        itemBuilder: (context, index) {
          return Card(
            child: ListTile(
              title: Text(completedItems[index][0]),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(completedItems[index][1]),
                  Text(completedItems[index][2].toString()),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
