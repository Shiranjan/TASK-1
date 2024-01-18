import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:todo/data/database.dart';
import 'package:todo/done_screen.dart';
import 'package:intl/intl.dart';
import 'package:hive_flutter/adapters.dart';

List todoitems = [];
List completeditems = [];

class todo extends StatefulWidget {
  Function(String, String, String) ind;
  todo({super.key, required this.ind});

  @override
  State<todo> createState() => _todoState();
}

class _todoState extends State<todo> with SingleTickerProviderStateMixin {
  final todobox = Hive.box('newbox');
  late TabController _tabController;
  bool _showAppBar = true;

  final tododatabase db = tododatabase();

  @override
  void initState() {
    if (db.todobox.get("TODOBOX") != null) {
      db.loaddata();
    }
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _showAppBar = _tabController.index == 0;
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showAddTodoDialog(BuildContext context) {
    TextEditingController titleController = TextEditingController();
    TextEditingController descriptionController = TextEditingController();
    DateTime? selectedDate;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add Todo'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: InputDecoration(labelText: 'Title'),
              ),
              TextField(
                controller: descriptionController,
                decoration: InputDecoration(labelText: 'Description'),
              ),
              ElevatedButton(
                onPressed: () async {
                  DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );
                  if (pickedDate != null) {
                    setState(() {
                      selectedDate = pickedDate;
                    });
                  }
                },
                child:
                    Text(selectedDate != null ? 'Change Date' : 'Pick a Date'),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                if (titleController.text.isNotEmpty && selectedDate != null) {
                  setState(() {
                    List newtodo = [
                      titleController.text,
                      descriptionController.text,
                      selectedDate,
                      false
                    ];
                    todoitems.add(newtodo);
                    db.updatedata();
                  });
                  db.updatedata();
                  Navigator.of(context).pop();
                }
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _showAppBar
          ? AppBar(
              backgroundColor: Theme.of(context).colorScheme.primary,
              title: Text('ToDo'),
            )
          : null,
      body: TabBarView(
        controller: _tabController,
        physics: NeverScrollableScrollPhysics(),
        children: [
          Padding(
            padding: EdgeInsets.all(4),
            child: ListView.builder(
              itemCount: todoitems.length,
              itemBuilder: (context, index) {
                todo(ind: (t, d, s) {
                  setState(() {
                    todoitems[index][0] = t;
                    todoitems[index][1] = d;
                    todoitems[index][2] = s;
                  });
                });
                return Card(
                  elevation: 4,
                  child: ListTile(
                    title: CheckboxListTile(
                      title: Text(todoitems[index][0]),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(todoitems[index][1]),
                          Text(todoitems[index][2].toString()),
                        ],
                      ),
                      value: todoitems[index][3],
                      onChanged: (value) {
                        setState(() {
                          todoitems[index][3] = value!;
                          if (value) {
                            completeditems.add(
                                todoitems[index]); // Move to completed list
                            todoitems.removeAt(index); // Remove from todo list
                          }
                        });
                      },
                      controlAffinity: ListTileControlAffinity.leading,
                      secondary: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.edit),
                            onPressed: () {
                              // Implement edit functionality
                              _showEditTodoDialog(context, todoitems[index]);
                            },
                          ),
                          IconButton(
                            icon: Icon(Icons.delete),
                            onPressed: () {
                              // Implement delete functionality
                              _deleteTodoItem(index);
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          DoneScreen(
              completedItems: completeditems,
              deleteAllCompletedTasks: deleteAllCompletedTasks),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddTodoDialog(context);
        },
        child: Icon(Icons.add),
      ),
      bottomNavigationBar: Material(
        child: TabBar(
          tabs: [
            Tab(icon: Icon(Icons.square_rounded), text: 'ToDo'),
            Tab(icon: Icon(Icons.check_box_rounded), text: 'Done'),
          ],
          controller: _tabController,
        ),
      ),
    );
  }

  void deleteAllCompletedTasks() {
    setState(() {
      completeditems.clear(); // Clear the completedItems list
    });
    db.updatedata();
  }

  void _deleteTodoItem(int index) {
    setState(() {
      todoitems.removeAt(index);
    });
    db.updatedata();
  }

  void _showEditTodoDialog(BuildContext context, todoitems) {
    TextEditingController editedTitleController =
        TextEditingController(text: todoitems[0]);
    TextEditingController editedDescriptionController =
        TextEditingController(text: todoitems[1]);
    DateTime EselectedDate = todoitems[2];

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit Todo'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: editedTitleController,
                decoration: InputDecoration(labelText: 'Title'),
              ),
              TextField(
                controller: editedDescriptionController,
                decoration: InputDecoration(labelText: 'Description'),
              ),
              ElevatedButton(
                onPressed: () async {
                  DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate:
                        EselectedDate, // Set initial date to the current value
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );
                  if (pickedDate != null) {
                    setState(() {
                      EselectedDate = pickedDate; // Update the selected date
                    });
                  }
                },
                child: Text('Change Date'),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                setState(() {
                  todoitems[0] = editedTitleController.text;
                  todoitems[1] = editedDescriptionController.text;
                  todoitems[2] = EselectedDate;
                  db.updatedata();
                });
                Navigator.of(context).pop();
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }
}
