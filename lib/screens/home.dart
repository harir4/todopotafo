import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'package:todopotafo/db/db_services.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final Box<Todo> _todoBox = Hive.box<Todo>('todoBox');
  List<Todo> _todos = [];
  String _filter = 'All';

  @override
  void initState() {
    super.initState();
    _loadTodos();
  }

  void _loadTodos() {
    setState(() {
      _todos = _todoBox.values.toList();
    });
  }

  void _addTodo() async {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    DateTime selectedDate = DateTime.now();
    final _formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Add Todo'),
          content: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: titleController,
                    decoration: InputDecoration(labelText: 'Title'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a title';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: descriptionController,
                    decoration: InputDecoration(labelText: 'Description'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a description';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 20),
                  TextButton(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                            'Date: ${DateFormat.yMMMd().format(selectedDate)}'),
                        Icon(Icons.calendar_today)
                      ],
                    ),
                    onPressed: () async {
                      DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: selectedDate,
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2101),
                      );
                      if (pickedDate != null) {
                        selectedDate = pickedDate;
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  final newTodo = Todo(
                    title: titleController.text,
                    description: descriptionController.text,
                    date: selectedDate,
                  );
                  _todoBox.add(newTodo);
                  _loadTodos();
                  Navigator.of(context).pop();
                }
              },
              child: Text('Add'),
            ),
          ],
        );
      },
    );
  }

  void _editTodo(int index) async {
    final todo = _todos[index];
    final titleController = TextEditingController(text: todo.title);
    final descriptionController = TextEditingController(text: todo.description);
    DateTime selectedDate = todo.date;
    final _formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit Todo'),
          content: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: titleController,
                    decoration: InputDecoration(labelText: 'Title'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a title';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: descriptionController,
                    decoration: InputDecoration(labelText: 'Description'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a description';
                      }
                      return null;
                    },
                  ),
                  TextButton(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                            'Select Date: ${DateFormat.yMMMd().format(selectedDate)}'),
                        Icon(Icons.calendar_today)
                      ],
                    ),
                    onPressed: () async {
                      DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: selectedDate,
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2101),
                      );
                      if (pickedDate != null) {
                        selectedDate = pickedDate;
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  todo.title = titleController.text;
                  todo.description = descriptionController.text;
                  todo.date = selectedDate;
                  _todoBox.putAt(index, todo);
                  _loadTodos();
                  Navigator.of(context).pop();
                }
              },
              child: Text('Update'),
            ),
          ],
        );
      },
    );
  }

  void _deleteTodo(int index) {
    _todoBox.deleteAt(index);
    _loadTodos();
  }

  void _filterTodos(String status) {
    setState(() {
      _filter = status;
    });
  }

  @override
  Widget build(BuildContext context) {
    List<Todo> displayedTodos = _filter == 'All'
        ? _todos
        : _todos
            .where((todo) => todo.isCompleted == (_filter == 'Completed'))
            .toList();

    return Scaffold(
      appBar: AppBar(
        title: Text('Notes'),
        actions: [
          DropdownButton<String>(
            borderRadius: BorderRadius.circular(10),
            elevation: 3,
            value: _filter,
            icon: Icon(Icons.filter_list),
            dropdownColor: Colors.white,
            onChanged: (String? newValue) {
              if (newValue != null) {
                _filterTodos(newValue);
              }
            },
            items: <String>['All', 'Completed', 'Pending']
                .map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: displayedTodos.length,
        itemBuilder: (context, index) {
          final todo = displayedTodos[index];
          return Card(
            margin: EdgeInsets.all(8.0),
            elevation: 5,
            child: ListTile(
              title: Text(todo.title,
                  style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(
                  '${todo.description}\n${DateFormat.yMMMd().format(todo.date)}'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(Icons.edit),
                    onPressed: () => _editTodo(index),
                  ),
                  IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () => _deleteTodo(index),
                  ),
                  Checkbox(
                    value: todo.isCompleted,
                    onChanged: (bool? value) {
                      setState(() {
                        todo.isCompleted = value ?? false;
                        _todoBox.putAt(index, todo);
                      });
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addTodo,
        child: Icon(Icons.add),
      ),
    );
  }
}
