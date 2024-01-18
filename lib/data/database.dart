import 'package:hive_flutter/hive_flutter.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:todo/todo_screen.dart';

class tododatabase {
  final todobox = Hive.box("newbox");

  void loaddata() {
    todoitems = todobox.get(" TODOBOX");
  }

  void updatedata() async {
    await todobox.put(" TODOBOX", todoitems);
  }
}
